import 'dart:async';
import 'dart:io';

import 'package:family_games/core/app_controllers.dart';
import 'package:family_games/core/auth/auth_refresh.dart';
import 'package:family_games/core/auth/auth_repository.dart';
import 'package:family_games/core/locale/app_locale_controller.dart';
import 'package:family_games/core/security/app_biometric_unlock_controller.dart';
import 'package:family_games/core/theme/app_theme_controller.dart';
import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/router.dart';
import 'package:family_games/theme/family_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dart's HttpClient (used by Supabase) has its own trust store, independent
// of the Android/iOS OS trust store. Debug-only: trust the corporate proxy
// root CA so local dev works behind a TLS-intercepting proxy.
Future<void> _trustDevProxyCertificateIfNeeded() async {
  if (!kDebugMode) return;
  try {
    final bytes = await rootBundle.load('assets/certs/zscaler_root_ca.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      bytes.buffer.asUint8List(),
    );
  } catch (e) {
    debugPrint('no dev proxy certificate to trust: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _trustDevProxyCertificateIfNeeded();

  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
      'Run with --dart-define-from-file=.env.json',
    );
  }

  await Supabase.initialize(url: url, publishableKey: anonKey);

  final locale = AppLocaleController();
  final theme = AppThemeController();
  final biometric = AppBiometricUnlockController();
  await Future.wait([locale.load(), theme.load(), biometric.load()]);

  runApp(
    FamilyGamesApp(
      locale: locale,
      theme: theme,
      biometric: biometric,
      authRefresh: AuthRefresh(),
    ),
  );
}

class FamilyGamesApp extends StatefulWidget {
  const FamilyGamesApp({
    super.key,
    required this.locale,
    required this.theme,
    required this.biometric,
    required this.authRefresh,
  });

  final AppLocaleController locale;
  final AppThemeController theme;
  final AppBiometricUnlockController biometric;
  final AuthRefresh authRefresh;

  static Locale _resolveDeviceLocale(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale == null) return supported.first;
    for (final loc in supported) {
      if (loc.languageCode == deviceLocale.languageCode) return loc;
    }
    return supported.first;
  }

  @override
  State<FamilyGamesApp> createState() => _FamilyGamesAppState();
}

class _FamilyGamesAppState extends State<FamilyGamesApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;
  bool _shouldUnlockOnNextResume = false;
  bool _biometricLockActive = false;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.authRefresh);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    widget.authRefresh.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _shouldUnlockOnNextResume = true;
    } else if (state == AppLifecycleState.resumed && _shouldUnlockOnNextResume) {
      _shouldUnlockOnNextResume = false;
      unawaited(_activateBiometricLockIfNeeded());
    }
  }

  Future<void> _activateBiometricLockIfNeeded() async {
    if (authRepository.currentSession == null) return;
    final bio = widget.biometric;
    await bio.refreshAuthenticatorAvailability();
    if (!bio.enabled || !bio.authenticatorAvailable) return;
    if (!mounted) return;
    setState(() => _biometricLockActive = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppControllers(
      locale: widget.locale,
      theme: widget.theme,
      biometric: widget.biometric,
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.locale, widget.theme]),
        builder: (context, _) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: widget.locale.materialAppLocale,
            localeResolutionCallback: (locale, supported) =>
                FamilyGamesApp._resolveDeviceLocale(locale, supported),
            theme: familyLightTheme(),
            darkTheme: familyDarkTheme(),
            themeMode: widget.theme.themeMode,
            routerConfig: _router,
            builder: (context, child) {
              if (_biometricLockActive) {
                return PopScope(
                  canPop: false,
                  child: _BiometricLockScreen(
                    onUnlocked: () {
                      if (_biometricLockActive) {
                        setState(() => _biometricLockActive = false);
                      }
                    },
                  ),
                );
              }
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _BiometricLockScreen extends StatefulWidget {
  const _BiometricLockScreen({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<_BiometricLockScreen> {
  bool _busy = false;
  bool _unlockInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attemptUnlock());
  }

  Future<void> _attemptUnlock() async {
    if (!mounted) return;
    if (authRepository.currentSession == null) {
      widget.onUnlocked();
      return;
    }
    if (_unlockInFlight) return;
    _unlockInFlight = true;
    setState(() => _busy = true);
    try {
      final bio = AppControllers.of(context).biometric;
      await bio.refreshAuthenticatorAvailability();
      if (!mounted) return;
      if (!bio.enabled || !bio.authenticatorAvailable) {
        widget.onUnlocked();
        return;
      }
      final l10n = AppLocalizations.of(context);
      final ok = await bio.localAuth.authenticate(
        localizedReason: l10n.settingsBiometricResumeReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (ok) widget.onUnlocked();
    } finally {
      _unlockInFlight = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 56, color: scheme.primary),
                const SizedBox(height: 20),
                Text(
                  l10n.biometricLockTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.biometricLockBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _busy ? null : _attemptUnlock,
                  icon: _busy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(l10n.biometricLockUnlockButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

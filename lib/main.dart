import 'dart:async';
import 'dart:io';

import 'package:family_games/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/locale/app_locale_controller.dart';
import 'core/logger/app_logger.dart';
import 'core/security/app_biometric_unlock_controller.dart';
import 'core/theme/app_theme_controller.dart';
import 'core/theme/family_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'router.dart';

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
    AppLogger.info('trusted dev proxy certificate');
  } catch (e) {
    AppLogger.info('no dev proxy certificate to trust: $e');
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

  AppLogger.info('initializing Supabase');
  await Supabase.initialize(url: url, publishableKey: anonKey);
  AppLogger.info('Supabase initialized');

  setupDi();
  AppLogger.info('DI setup complete');
  await getIt<AppLocaleController>().load();
  await getIt<AppThemeController>().load();
  await getIt<AppBiometricUnlockController>().load();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  /// True after [AppLifecycleState.paused]; cleared on resume so cold start does not lock.
  bool _shouldUnlockOnNextResume = false;

  /// Full-screen gate: no router navigation visible until cleared.
  bool _biometricLockActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _shouldUnlockOnNextResume = true;
    } else if (state == AppLifecycleState.resumed &&
        _shouldUnlockOnNextResume) {
      _shouldUnlockOnNextResume = false;
      unawaited(_activateBiometricLockIfNeeded());
    }
  }

  Future<void> _activateBiometricLockIfNeeded() async {
    if (!getIt<AuthRepository>().hasSession) return;
    final bio = getIt<AppBiometricUnlockController>();
    await bio.refreshAuthenticatorAvailability();
    if (!bio.enabled || !bio.authenticatorAvailable) return;
    if (!mounted) return;
    setState(() => _biometricLockActive = true);
  }

  void _clearBiometricLock() {
    if (_biometricLockActive) {
      setState(() => _biometricLockActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = getIt<AppLocaleController>();
    final appTheme = getIt<AppThemeController>();
    return ListenableBuilder(
      listenable: Listenable.merge([appLocale, appTheme]),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Family Games',
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appLocale.materialAppLocale,
          localeResolutionCallback: App._resolveDeviceLocale,
          theme: familyLightTheme(),
          darkTheme: familyDarkTheme(),
          themeMode: appTheme.themeMode,
          routerConfig: router,
          builder: (context, child) {
            if (_biometricLockActive) {
              return PopScope(
                canPop: false,
                child: _BiometricLockScreen(onUnlocked: _clearBiometricLock),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
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
    if (!getIt<AuthRepository>().hasSession) {
      widget.onUnlocked();
      return;
    }
    if (_unlockInFlight) return;
    _unlockInFlight = true;
    setState(() => _busy = true);
    try {
      final bio = getIt<AppBiometricUnlockController>();
      await bio.refreshAuthenticatorAvailability();
      if (!mounted) return;
      if (!bio.enabled || !bio.authenticatorAvailable) {
        widget.onUnlocked();
        return;
      }
      final l10n = AppLocalizations.of(context);
      final ok = await bio.localAuth
          .authenticate(
            localizedReason: l10n.settingsBiometricResumeReason,
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          )
          .catchError(
            (Object _) => false,
            test: (e) => e is LocalAuthException,
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
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: scheme.primary,
                ),
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

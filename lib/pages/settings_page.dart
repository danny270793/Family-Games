import 'package:family_games/core/app_controllers.dart';
import 'package:family_games/core/auth/auth_repository.dart';
import 'package:family_games/core/locale/app_locale_controller.dart';
import 'package:family_games/core/security/app_biometric_unlock_controller.dart';
import 'package:family_games/core/theme/app_theme_controller.dart';
import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/widgets/app_sheet.dart';
import 'package:family_games/widgets/bottom_sheet_pinned_title.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _languageOptionLabel(AppLocalizations l10n, AppLanguagePreference p) =>
    switch (p) {
      AppLanguagePreference.system => l10n.settingsLanguageSystem,
      AppLanguagePreference.en => l10n.settingsLanguageEnglish,
      AppLanguagePreference.es => l10n.settingsLanguageSpanish,
    };

String _themeOptionLabel(AppLocalizations l10n, AppThemePreference p) =>
    switch (p) {
      AppThemePreference.system => l10n.settingsThemeSystem,
      AppThemePreference.light => l10n.settingsThemeLight,
      AppThemePreference.dark => l10n.settingsThemeDark,
    };

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppControllers.of(context).biometric.refreshAuthenticatorAvailability();
    });
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await authRepository.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).unexpectedError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.settingsProfileSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Icons.person_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.settingsChangeEmail),
              subtitle: Text(
                authRepository.currentUser?.email ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await _showChangeEmailSheet(context, l10n);
                if (mounted) setState(() {});
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.settingsChangePassword),
              subtitle: Text(
                l10n.settingsChangePasswordSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePasswordSheet(context, l10n),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.settingsSecuritySection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: AppControllers.of(context).biometric,
              builder: (context, _) {
                final bio = AppControllers.of(context).biometric;
                return SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  secondary: Icon(
                    Icons.fingerprint_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(l10n.settingsBiometricUnlockTitle),
                  subtitle: Text(
                    bio.authenticatorAvailable
                        ? l10n.settingsBiometricUnlockSubtitle
                        : l10n.settingsBiometricUnavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  value: bio.enabled,
                  onChanged: bio.authenticatorAvailable
                      ? (v) => _setBiometricUnlockEnabled(context, l10n, bio, v)
                      : null,
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.settingsAppearance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: AppControllers.of(context).locale,
              builder: (context, _) {
                final ctrl = AppControllers.of(context).locale;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(
                    Icons.language_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(l10n.settingsLanguage),
                  subtitle: Text(_languageOptionLabel(l10n, ctrl.preference)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePickerSheet(context, l10n, ctrl),
                );
              },
            ),
            ListenableBuilder(
              listenable: AppControllers.of(context).theme,
              builder: (context, _) {
                final ctrl = AppControllers.of(context).theme;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(l10n.settingsTheme),
                  subtitle: Text(_themeOptionLabel(l10n, ctrl.preference)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePickerSheet(context, l10n, ctrl),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.settingsAboutSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.settingsAboutApp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/about'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.settingsPrivacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/privacy'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.settingsTermsOfUse),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/terms'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _signingOut ? null : _signOut,
                icon: _signingOut
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onError,
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(l10n.signOut),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLanguagePickerSheet(
  BuildContext context,
  AppLocalizations l10n,
  AppLocaleController ctrl,
) async {
  await showAppSheet<void>(
    context: context,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: l10n.settingsLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in AppLanguagePreference.values)
            ListTile(
              title: Text(_languageOptionLabel(l10n, option)),
              trailing: ctrl.preference == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ctrl.setPreference(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _showThemePickerSheet(
  BuildContext context,
  AppLocalizations l10n,
  AppThemeController ctrl,
) async {
  await showAppSheet<void>(
    context: context,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: l10n.settingsTheme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in AppThemePreference.values)
            ListTile(
              title: Text(_themeOptionLabel(l10n, option)),
              trailing: ctrl.preference == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ctrl.setPreference(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _setBiometricUnlockEnabled(
  BuildContext context,
  AppLocalizations l10n,
  AppBiometricUnlockController ctrl,
  bool enabled,
) async {
  if (!enabled) {
    await ctrl.setEnabled(false);
    return;
  }
  await ctrl.refreshAuthenticatorAvailability();
  if (!ctrl.authenticatorAvailable) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.settingsBiometricUnavailable)),
      );
    }
    return;
  }
  final ok = await ctrl.localAuth.authenticate(
    localizedReason: l10n.settingsBiometricAuthReason,
    options: const AuthenticationOptions(
      biometricOnly: true,
      stickyAuth: true,
    ),
  );
  if (!context.mounted) return;
  if (ok) await ctrl.setEnabled(true);
}

Future<void> _showChangeEmailSheet(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final email = authRepository.currentUser?.email ?? '';
  final ok = await showAppSheet<bool>(
    context: context,
    builder: (_) => BottomSheetPinnedTitleScrollView(
      title: l10n.settingsChangeEmailDialogTitle,
      child: _ChangeEmailSheetBody(currentEmail: email, l10n: l10n),
    ),
  );
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsChangeEmailSuccess)),
    );
  }
}

Future<void> _showChangePasswordSheet(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final ok = await showAppSheet<bool>(
    context: context,
    builder: (_) => BottomSheetPinnedTitleScrollView(
      title: l10n.settingsChangePasswordDialogTitle,
      child: _ChangePasswordSheetBody(l10n: l10n),
    ),
  );
  if (ok == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsChangePasswordSuccess)),
    );
  }
}

class _ChangeEmailSheetBody extends StatefulWidget {
  const _ChangeEmailSheetBody({required this.currentEmail, required this.l10n});

  final String currentEmail;
  final AppLocalizations l10n;

  @override
  State<_ChangeEmailSheetBody> createState() => _ChangeEmailSheetBodyState();
}

class _ChangeEmailSheetBodyState extends State<_ChangeEmailSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final next = _controller.text.trim();
    if (next == widget.currentEmail.trim()) {
      _snack(widget.l10n.settingsChangeEmailSameAsCurrent);
      return;
    }
    setState(() => _loading = true);
    try {
      await authRepository.updateEmail(newEmail: next);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack(e.message);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      _snack(widget.l10n.unexpectedError);
    }
  }

  void _snack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.settingsNewEmailLabel),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                return l10n.settingsChangeEmailInvalid;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.settingsChangeEmailSubmit),
          ),
        ],
      ),
    );
  }
}

const int _kMinPasswordLength = 6;

class _ChangePasswordSheetBody extends StatefulWidget {
  const _ChangePasswordSheetBody({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_ChangePasswordSheetBody> createState() =>
      _ChangePasswordSheetBodyState();
}

class _ChangePasswordSheetBodyState extends State<_ChangePasswordSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await authRepository.updatePassword(newPassword: _newController.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _snack(e.message);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      _snack(widget.l10n.unexpectedError);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _newController,
            obscureText: _obscureNew,
            textInputAction: TextInputAction.next,
            autofocus: true,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsNewPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.fieldRequired;
              if (v.length < _kMinPasswordLength) {
                return l10n.settingsPasswordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsConfirmNewPasswordLabel,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            enabled: !_loading,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.fieldRequired;
              if (v != _newController.text) return l10n.settingsPasswordsDoNotMatch;
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.settingsChangePasswordSubmit),
          ),
        ],
      ),
    );
  }
}

import 'package:family_games/core/locale/app_locale_controller.dart';
import 'package:family_games/core/security/app_biometric_unlock_controller.dart';
import 'package:family_games/core/theme/app_theme_controller.dart';
import 'package:flutter/widgets.dart';

class AppControllers extends InheritedWidget {
  const AppControllers({
    super.key,
    required this.locale,
    required this.theme,
    required this.biometric,
    required super.child,
  });

  final AppLocaleController locale;
  final AppThemeController theme;
  final AppBiometricUnlockController biometric;

  static AppControllers of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppControllers>();
    assert(scope != null, 'AppControllers not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppControllers oldWidget) {
    return locale != oldWidget.locale ||
        theme != oldWidget.theme ||
        biometric != oldWidget.biometric;
  }
}

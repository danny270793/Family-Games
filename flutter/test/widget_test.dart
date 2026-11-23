import 'package:family_games/core/locale/app_locale_controller.dart';
import 'package:family_games/core/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('language preference defaults to system', () {
    expect(
      AppLanguagePreference.fromStorage(null),
      AppLanguagePreference.system,
    );
    expect(
      AppLanguagePreference.fromStorage('en').materialLocale,
      const Locale('en'),
    );
    expect(AppLanguagePreference.es.storageValue, 'es');
  });

  test('theme preference maps to ThemeMode', () {
    expect(
      AppThemePreference.fromStorage('dark').themeMode,
      ThemeMode.dark,
    );
    expect(
      AppThemePreference.fromStorage('light').themeMode,
      ThemeMode.light,
    );
    expect(
      AppThemePreference.fromStorage(null).themeMode,
      ThemeMode.system,
    );
  });
}

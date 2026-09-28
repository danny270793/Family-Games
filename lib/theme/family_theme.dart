import 'package:family_games/l10n/app_localizations.dart';
import 'package:family_games/models/family_game.dart';
import 'package:family_games/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData familyLightTheme() {
  const seed = Color(0xFF7A3142);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xFFFFFBF6),
  );
  return _theme(
    scheme,
    const Color(0xFFF3EBE1),
  );
}

ThemeData familyDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFE2B15A),
    brightness: Brightness.dark,
    surface: const Color(0xFF1C1814),
  );
  return _theme(scheme, const Color(0xFF12100E));
}

ThemeData _theme(ColorScheme scheme, Color scaffold) {
  final textTheme = GoogleFonts.outfitTextTheme().apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
  final title = GoogleFonts.frauncesTextTheme(textTheme);
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
    useMaterial3: true,
    textTheme: textTheme.copyWith(
      headlineMedium: title.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      headlineSmall: title.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: title.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scaffold,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: title.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: appSheetShape,
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

String gameTypeLabel(AppLocalizations l10n, GameType type) => switch (type) {
  GameType.sevenWonders => l10n.gameTypeSevenWonders,
  GameType.other => l10n.gameTypeOther,
};

String wonderCategoryLabel(AppLocalizations l10n, WonderCategory category) =>
    switch (category) {
      WonderCategory.maravilla => l10n.categoryWonder,
      WonderCategory.monedas => l10n.categoryCoins,
      WonderCategory.rojo => l10n.categoryRed,
      WonderCategory.azul => l10n.categoryBlue,
      WonderCategory.amarillo => l10n.categoryYellow,
      WonderCategory.verde => l10n.categoryGreen,
      WonderCategory.morado => l10n.categoryPurple,
    };

Color wonderCategoryColor(WonderCategory category) => switch (category) {
  WonderCategory.maravilla => const Color(0xFF8D6E63),
  WonderCategory.monedas => const Color(0xFFC4A15A),
  WonderCategory.rojo => const Color(0xFFC44536),
  WonderCategory.azul => const Color(0xFF3D6F9C),
  WonderCategory.amarillo => const Color(0xFFC49212),
  WonderCategory.verde => const Color(0xFF3E7C59),
  WonderCategory.morado => const Color(0xFF6E4B8A),
};

String gamesErrorMessage(AppLocalizations l10n, String code) => switch (code) {
  'user_not_found' => l10n.playerNotFound,
  'already_member' => l10n.playerAlreadyAdded,
  'at_least_two_players' => l10n.atLeastTwoPlayers,
  'name_required' => l10n.fieldRequired,
  _ => l10n.unexpectedError,
};

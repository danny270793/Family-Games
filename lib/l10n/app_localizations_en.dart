// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Games';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle => 'Keep score with the people you play with.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fieldRequired => 'Required';

  @override
  String get unexpectedError => 'An unexpected error occurred';

  @override
  String homeWelcome(String email) {
    return 'Signed in as $email';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settingsProfileSection => 'Profile';

  @override
  String get settingsChangeEmail => 'Change email';

  @override
  String get settingsChangeEmailDialogTitle => 'Change email';

  @override
  String get settingsNewEmailLabel => 'New email';

  @override
  String get settingsChangeEmailSubmit => 'Update';

  @override
  String get settingsChangeEmailSuccess =>
      'Check your new email to confirm the change.';

  @override
  String get settingsChangeEmailInvalid => 'Enter a valid email address.';

  @override
  String get settingsChangeEmailSameAsCurrent => 'That is already your email.';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Updates the password you use to sign in.';

  @override
  String get settingsChangePasswordDialogTitle => 'Change password';

  @override
  String get settingsNewPasswordLabel => 'New password';

  @override
  String get settingsConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get settingsChangePasswordSubmit => 'Update password';

  @override
  String get settingsChangePasswordSuccess => 'Your password was updated.';

  @override
  String get settingsPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get settingsPasswordTooShort => 'Use at least 6 characters.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get settingsBiometricUnlockTitle => 'Face ID & fingerprint';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Use biometrics to unlock the app.';

  @override
  String get settingsBiometricUnavailable =>
      'Biometric unlock is not available on this device.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirm to enable biometric unlock.';

  @override
  String get settingsBiometricResumeReason => 'Authenticate to continue.';

  @override
  String get biometricLockTitle => 'App locked';

  @override
  String get biometricLockBody => 'Use Face ID or fingerprint to continue.';

  @override
  String get biometricLockUnlockButton => 'Unlock';

  @override
  String get signOut => 'Sign out';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsRateApp => 'Rate on Google Play';

  @override
  String get settingsAboutApp => 'About';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsPrivacyTagline => 'Sign-in uses Supabase.';

  @override
  String get settingsPrivacyDataTitle => 'Account';

  @override
  String get settingsPrivacyDataBody =>
      'Authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.';

  @override
  String get settingsPrivacyInfraTitle => 'What stays on this device';

  @override
  String get settingsPrivacyInfraBody =>
      'Language, theme, and biometric unlock preferences are stored on this device. Your account is stored with Supabase. Use a strong password.';

  @override
  String get settingsPrivacySharingTitle => 'Sharing and ads';

  @override
  String get settingsPrivacySharingBody =>
      'We do not sell your personal information. Apart from sign-in with Supabase, this app is not designed to send your data to brokers or advertisers.';

  @override
  String get settingsPrivacyNoticeTitle => 'Before you ship';

  @override
  String get settingsPrivacyNoticeBody =>
      'This text is a simple placeholder, not legal advice. Before production or an app store release, publish a privacy policy that matches your jurisdiction and how you actually process data.';

  @override
  String get settingsTermsOfUse => 'Terms of use';

  @override
  String get settingsTermsTagline => 'Rules for using this app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Acceptance';

  @override
  String get settingsTermsAcceptanceBody =>
      'By accessing or using Family Games, you agree to these terms. If you do not agree, do not use the app. Sign-in is handled by Supabase.';

  @override
  String get settingsTermsDisclaimerTitle => 'Not professional advice';

  @override
  String get settingsTermsDisclaimerBody =>
      'Family Games is a personal app. Nothing in the app or these terms is legal advice. You use the app at your own risk.';

  @override
  String get settingsTermsLiabilityTitle => 'Limitation of liability';

  @override
  String get settingsTermsLiabilityBody =>
      'To the fullest extent permitted by law, the authors are not liable for any indirect, incidental, or consequential damages. The app is provided as-is without warranties of any kind.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Your responsibilities';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'You are responsible for protecting your account, credentials, and devices. You must comply with laws that apply to you.';

  @override
  String get settingsTermsNoticeTitle => 'Changes and before you ship';

  @override
  String get settingsTermsNoticeBody =>
      'These terms may be updated from time to time. If you continue to use the app after changes are posted, that indicates your acceptance of the updated terms. This text is a simple placeholder, not legal advice.';

  @override
  String get settingsAboutTagline =>
      'Keep score with the people you play with.';

  @override
  String get settingsAboutVersionLabel => 'Version';

  @override
  String get settingsAboutFeaturesHeading => 'What you can do';

  @override
  String get settingsAboutBulletSignIn =>
      'Create a game, invite players by email, and record every match.';

  @override
  String get settingsAboutBulletAppearance =>
      'Score 7 Wonders by category, or any other game with a single total.';

  @override
  String get settingsAboutBulletSecurity =>
      'See who has more wins and who has more losses.';

  @override
  String get settingsAboutDataHeading => 'Your data';

  @override
  String get settingsAboutDataBody =>
      'Games and scores are stored with Supabase and shared with the players in each game. Language, theme, and biometric preferences stay on this device.';

  @override
  String get settingsAboutDeveloperHeading => 'Developer';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Website';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get gamesEmptyTitle => 'No games yet';

  @override
  String get gamesEmptyBody =>
      'Create a game, invite your family, and start keeping score.';

  @override
  String get newGame => 'New game';

  @override
  String get editGame => 'Edit game';

  @override
  String get deleteGame => 'Delete game';

  @override
  String get deleteGameBody =>
      'This removes the game, its players, and every match.';

  @override
  String get createGame => 'Create game';

  @override
  String get gameName => 'Name';

  @override
  String get gameType => 'Type';

  @override
  String get gameTypeSevenWonders => '7 Wonders';

  @override
  String get gameTypeOther => 'Other';

  @override
  String get gameDescription => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Try again';

  @override
  String get players => 'Players';

  @override
  String get addPlayer => 'Add player';

  @override
  String get playerHelp => 'Use the email they use to sign in to Family Games.';

  @override
  String get playerNotFound => 'No Family Games account uses that email.';

  @override
  String get playerAlreadyAdded => 'That player is already in this game.';

  @override
  String get removePlayer => 'Remove player';

  @override
  String removePlayerBody(String email) {
    return 'Remove $email from this game?';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String matchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get matches => 'Matches';

  @override
  String get newMatch => 'New match';

  @override
  String get editMatch => 'Edit match';

  @override
  String get deleteMatch => 'Delete match';

  @override
  String get deleteMatchBody => 'This removes the scores for this match.';

  @override
  String get matchDate => 'Date';

  @override
  String get statistics => 'Statistics';

  @override
  String get dateFrom => 'From';

  @override
  String get dateTo => 'To';

  @override
  String get noMatchesInRange => 'No matches in this range.';

  @override
  String get winsOverTime => 'Wins over time';

  @override
  String get chartStart => 'Start';

  @override
  String get records => 'Records';

  @override
  String get longestWinStreak => 'Longest win streak';

  @override
  String get currentWinStreak => 'Current streak';

  @override
  String get highestScore => 'Highest score';

  @override
  String get bestWinRate => 'Best win rate';

  @override
  String get longestLosingStreak => 'Longest losing streak';

  @override
  String get currentLosingStreak => 'Current losing streak';

  @override
  String get lowestScore => 'Lowest score';

  @override
  String get worstWinRate => 'Worst win rate';

  @override
  String get standings => 'Standings';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get noStandings => 'Play a match to see who is ahead.';

  @override
  String get noPlayers => 'Add at least two players before you record a match.';

  @override
  String get noMatches => 'No matches yet.';

  @override
  String get points => 'Points';

  @override
  String get pointsMustBeWhole => 'Use whole numbers for scores.';

  @override
  String get winner => 'Winner';

  @override
  String get tie => 'Tie';

  @override
  String get leader => 'Leading';

  @override
  String get you => 'You';

  @override
  String get atLeastTwoPlayers => 'Pick at least two players.';

  @override
  String get scoringRuleOther =>
      'The highest score wins. Everyone with fewer points takes a loss. A tie for first is a win for each tied player.';

  @override
  String get scoringRuleSeven =>
      'Maravilla, coins, and the five colors add up. The highest total wins. Everyone else takes a loss.';

  @override
  String get categoryWonder => 'Wonder';

  @override
  String get categoryCoins => 'Coins';

  @override
  String get categoryRed => 'Red';

  @override
  String get categoryBlue => 'Blue';

  @override
  String get categoryYellow => 'Yellow';

  @override
  String get categoryGreen => 'Green';

  @override
  String get categoryPurple => 'Purple';
}

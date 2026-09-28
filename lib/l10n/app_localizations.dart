import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Family\'s Game'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep score with the people you play with.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String homeWelcome(String email);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileSection;

  /// No description provided for @settingsChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmail;

  /// No description provided for @settingsChangeEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get settingsChangeEmailDialogTitle;

  /// No description provided for @settingsNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get settingsNewEmailLabel;

  /// No description provided for @settingsChangeEmailSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsChangeEmailSubmit;

  /// No description provided for @settingsChangeEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check your new email to confirm the change.'**
  String get settingsChangeEmailSuccess;

  /// No description provided for @settingsChangeEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get settingsChangeEmailInvalid;

  /// No description provided for @settingsChangeEmailSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'That is already your email.'**
  String get settingsChangeEmailSameAsCurrent;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates the password you use to sign in.'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @settingsChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePasswordDialogTitle;

  /// No description provided for @settingsNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingsNewPasswordLabel;

  /// No description provided for @settingsConfirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settingsConfirmNewPasswordLabel;

  /// No description provided for @settingsChangePasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get settingsChangePasswordSubmit;

  /// No description provided for @settingsChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password was updated.'**
  String get settingsChangePasswordSuccess;

  /// No description provided for @settingsPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get settingsPasswordsDoNotMatch;

  /// No description provided for @settingsPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get settingsPasswordTooShort;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecuritySection;

  /// No description provided for @settingsBiometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Face ID & fingerprint'**
  String get settingsBiometricUnlockTitle;

  /// No description provided for @settingsBiometricUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to unlock the app.'**
  String get settingsBiometricUnlockSubtitle;

  /// No description provided for @settingsBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock is not available on this device.'**
  String get settingsBiometricUnavailable;

  /// No description provided for @settingsBiometricAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometric unlock.'**
  String get settingsBiometricAuthReason;

  /// No description provided for @settingsBiometricResumeReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to continue.'**
  String get settingsBiometricResumeReason;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockBody.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint to continue.'**
  String get biometricLockBody;

  /// No description provided for @biometricLockUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricLockUnlockButton;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutApp;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyTagline.
  ///
  /// In en, this message translates to:
  /// **'Sign-in uses Supabase.'**
  String get settingsPrivacyTagline;

  /// No description provided for @settingsPrivacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsPrivacyDataTitle;

  /// No description provided for @settingsPrivacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Authentication is provided by Supabase. Your email and credentials are processed by Supabase; this app does not store your password.'**
  String get settingsPrivacyDataBody;

  /// No description provided for @settingsPrivacyInfraTitle.
  ///
  /// In en, this message translates to:
  /// **'What stays on this device'**
  String get settingsPrivacyInfraTitle;

  /// No description provided for @settingsPrivacyInfraBody.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, and biometric unlock preferences are stored on this device. Your account is stored with Supabase. Use a strong password.'**
  String get settingsPrivacyInfraBody;

  /// No description provided for @settingsPrivacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing and ads'**
  String get settingsPrivacySharingTitle;

  /// No description provided for @settingsPrivacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal information. Apart from sign-in with Supabase, this app is not designed to send your data to brokers or advertisers.'**
  String get settingsPrivacySharingBody;

  /// No description provided for @settingsPrivacyNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you ship'**
  String get settingsPrivacyNoticeTitle;

  /// No description provided for @settingsPrivacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'This text is a simple placeholder, not legal advice. Before production or an app store release, publish a privacy policy that matches your jurisdiction and how you actually process data.'**
  String get settingsPrivacyNoticeBody;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsTermsTagline.
  ///
  /// In en, this message translates to:
  /// **'Rules for using this app.'**
  String get settingsTermsTagline;

  /// No description provided for @settingsTermsAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance'**
  String get settingsTermsAcceptanceTitle;

  /// No description provided for @settingsTermsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using Family\'s Game, you agree to these terms. If you do not agree, do not use the app. Sign-in is handled by Supabase.'**
  String get settingsTermsAcceptanceBody;

  /// No description provided for @settingsTermsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not professional advice'**
  String get settingsTermsDisclaimerTitle;

  /// No description provided for @settingsTermsDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Family\'s Game is a personal app. Nothing in the app or these terms is legal advice. You use the app at your own risk.'**
  String get settingsTermsDisclaimerBody;

  /// No description provided for @settingsTermsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Limitation of liability'**
  String get settingsTermsLiabilityTitle;

  /// No description provided for @settingsTermsLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'To the fullest extent permitted by law, the authors are not liable for any indirect, incidental, or consequential damages. The app is provided as-is without warranties of any kind.'**
  String get settingsTermsLiabilityBody;

  /// No description provided for @settingsTermsResponsibilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your responsibilities'**
  String get settingsTermsResponsibilitiesTitle;

  /// No description provided for @settingsTermsResponsibilitiesBody.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for protecting your account, credentials, and devices. You must comply with laws that apply to you.'**
  String get settingsTermsResponsibilitiesBody;

  /// No description provided for @settingsTermsNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes and before you ship'**
  String get settingsTermsNoticeTitle;

  /// No description provided for @settingsTermsNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated from time to time. If you continue to use the app after changes are posted, that indicates your acceptance of the updated terms. This text is a simple placeholder, not legal advice.'**
  String get settingsTermsNoticeBody;

  /// No description provided for @settingsAboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Keep score with the people you play with.'**
  String get settingsAboutTagline;

  /// No description provided for @settingsAboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersionLabel;

  /// No description provided for @settingsAboutFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get settingsAboutFeaturesHeading;

  /// No description provided for @settingsAboutBulletSignIn.
  ///
  /// In en, this message translates to:
  /// **'Create a game, invite players by email, and record every match.'**
  String get settingsAboutBulletSignIn;

  /// No description provided for @settingsAboutBulletAppearance.
  ///
  /// In en, this message translates to:
  /// **'Score 7 Wonders by category, or any other game with a single total.'**
  String get settingsAboutBulletAppearance;

  /// No description provided for @settingsAboutBulletSecurity.
  ///
  /// In en, this message translates to:
  /// **'See who has more wins and who has more losses.'**
  String get settingsAboutBulletSecurity;

  /// No description provided for @settingsAboutDataHeading.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsAboutDataHeading;

  /// No description provided for @settingsAboutDataBody.
  ///
  /// In en, this message translates to:
  /// **'Games and scores are stored with Supabase and shared with the players in each game. Language, theme, and biometric preferences stay on this device.'**
  String get settingsAboutDataBody;

  /// No description provided for @settingsAboutDeveloperHeading.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsAboutDeveloperHeading;

  /// No description provided for @settingsAboutDeveloperGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get settingsAboutDeveloperGithub;

  /// No description provided for @settingsAboutDeveloperWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingsAboutDeveloperWebsite;

  /// No description provided for @settingsAboutDeveloperYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get settingsAboutDeveloperYoutube;

  /// No description provided for @settingsAboutDeveloperLinkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get settingsAboutDeveloperLinkedin;

  /// No description provided for @gamesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get gamesEmptyTitle;

  /// No description provided for @gamesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a game, invite your family, and start keeping score.'**
  String get gamesEmptyBody;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @editGame.
  ///
  /// In en, this message translates to:
  /// **'Edit game'**
  String get editGame;

  /// No description provided for @deleteGame.
  ///
  /// In en, this message translates to:
  /// **'Delete game'**
  String get deleteGame;

  /// No description provided for @deleteGameBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the game, its players, and every match.'**
  String get deleteGameBody;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create game'**
  String get createGame;

  /// No description provided for @gameName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get gameName;

  /// No description provided for @gameType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get gameType;

  /// No description provided for @gameTypeSevenWonders.
  ///
  /// In en, this message translates to:
  /// **'7 Wonders'**
  String get gameTypeSevenWonders;

  /// No description provided for @gameTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gameTypeOther;

  /// No description provided for @gameDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get gameDescription;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayer;

  /// No description provided for @playerHelp.
  ///
  /// In en, this message translates to:
  /// **'Use the email they use to sign in to Family\'s Game.'**
  String get playerHelp;

  /// No description provided for @playerNotFound.
  ///
  /// In en, this message translates to:
  /// **'No Family\'s Game account uses that email.'**
  String get playerNotFound;

  /// No description provided for @playerAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'That player is already in this game.'**
  String get playerAlreadyAdded;

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove player'**
  String get removePlayer;

  /// No description provided for @removePlayerBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {email} from this game?'**
  String removePlayerBody(String email);

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 player} other{{count} players}}'**
  String playersCount(int count);

  /// No description provided for @matchesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 match} other{{count} matches}}'**
  String matchesCount(int count);

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @newMatch.
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get newMatch;

  /// No description provided for @editMatch.
  ///
  /// In en, this message translates to:
  /// **'Edit match'**
  String get editMatch;

  /// No description provided for @deleteMatch.
  ///
  /// In en, this message translates to:
  /// **'Delete match'**
  String get deleteMatch;

  /// No description provided for @deleteMatchBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the scores for this match.'**
  String get deleteMatchBody;

  /// No description provided for @matchDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get matchDate;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get dateTo;

  /// No description provided for @noMatchesInRange.
  ///
  /// In en, this message translates to:
  /// **'No matches in this range.'**
  String get noMatchesInRange;

  /// No description provided for @winsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Wins over time'**
  String get winsOverTime;

  /// No description provided for @chartStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get chartStart;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @longestWinStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest win streak'**
  String get longestWinStreak;

  /// No description provided for @currentWinStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentWinStreak;

  /// No description provided for @highestScore.
  ///
  /// In en, this message translates to:
  /// **'Highest score'**
  String get highestScore;

  /// No description provided for @bestWinRate.
  ///
  /// In en, this message translates to:
  /// **'Best win rate'**
  String get bestWinRate;

  /// No description provided for @longestLosingStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest losing streak'**
  String get longestLosingStreak;

  /// No description provided for @currentLosingStreak.
  ///
  /// In en, this message translates to:
  /// **'Current losing streak'**
  String get currentLosingStreak;

  /// No description provided for @lowestScore.
  ///
  /// In en, this message translates to:
  /// **'Lowest score'**
  String get lowestScore;

  /// No description provided for @worstWinRate.
  ///
  /// In en, this message translates to:
  /// **'Worst win rate'**
  String get worstWinRate;

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standings;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @noStandings.
  ///
  /// In en, this message translates to:
  /// **'Play a match to see who is ahead.'**
  String get noStandings;

  /// No description provided for @noPlayers.
  ///
  /// In en, this message translates to:
  /// **'Add at least two players before you record a match.'**
  String get noPlayers;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches yet.'**
  String get noMatches;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @pointsMustBeWhole.
  ///
  /// In en, this message translates to:
  /// **'Use whole numbers for scores.'**
  String get pointsMustBeWhole;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get tie;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leading'**
  String get leader;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @atLeastTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'Pick at least two players.'**
  String get atLeastTwoPlayers;

  /// No description provided for @scoringRuleOther.
  ///
  /// In en, this message translates to:
  /// **'The highest score wins. Everyone with fewer points takes a loss. A tie for first is a win for each tied player.'**
  String get scoringRuleOther;

  /// No description provided for @scoringRuleSeven.
  ///
  /// In en, this message translates to:
  /// **'Maravilla, coins, and the five colors add up. The highest total wins. Everyone else takes a loss.'**
  String get scoringRuleSeven;

  /// No description provided for @categoryWonder.
  ///
  /// In en, this message translates to:
  /// **'Wonder'**
  String get categoryWonder;

  /// No description provided for @categoryCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get categoryCoins;

  /// No description provided for @categoryRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get categoryRed;

  /// No description provided for @categoryBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get categoryBlue;

  /// No description provided for @categoryYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get categoryYellow;

  /// No description provided for @categoryGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get categoryGreen;

  /// No description provided for @categoryPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get categoryPurple;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

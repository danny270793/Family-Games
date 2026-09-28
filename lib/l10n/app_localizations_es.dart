// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Family\'s Game';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInSubtitle =>
      'Lleva el marcador de las partidas que juegan juntos.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String homeWelcome(String email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsProfileSection => 'Perfil';

  @override
  String get settingsChangeEmail => 'Cambiar correo';

  @override
  String get settingsChangeEmailDialogTitle => 'Cambiar correo';

  @override
  String get settingsNewEmailLabel => 'Correo nuevo';

  @override
  String get settingsChangeEmailSubmit => 'Actualizar';

  @override
  String get settingsChangeEmailSuccess =>
      'Revisa tu correo nuevo para confirmar el cambio.';

  @override
  String get settingsChangeEmailInvalid => 'Introduce un correo válido.';

  @override
  String get settingsChangeEmailSameAsCurrent => 'Ese ya es tu correo.';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsChangePasswordSubtitle =>
      'Actualiza la contraseña con la que inicias sesión.';

  @override
  String get settingsChangePasswordDialogTitle => 'Cambiar contraseña';

  @override
  String get settingsNewPasswordLabel => 'Contraseña nueva';

  @override
  String get settingsConfirmNewPasswordLabel => 'Confirmar contraseña';

  @override
  String get settingsChangePasswordSubmit => 'Actualizar contraseña';

  @override
  String get settingsChangePasswordSuccess => 'Tu contraseña se actualizó.';

  @override
  String get settingsPasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get settingsPasswordTooShort => 'Usa al menos 6 caracteres.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Predeterminado del sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsSecuritySection => 'Seguridad';

  @override
  String get settingsBiometricUnlockTitle => 'Face ID y huella dactilar';

  @override
  String get settingsBiometricUnlockSubtitle =>
      'Usa la biometría para desbloquear la app.';

  @override
  String get settingsBiometricUnavailable =>
      'El desbloqueo biométrico no está disponible en este dispositivo.';

  @override
  String get settingsBiometricAuthReason =>
      'Confirma para activar el desbloqueo biométrico.';

  @override
  String get settingsBiometricResumeReason => 'Autentícate para continuar.';

  @override
  String get biometricLockTitle => 'App bloqueada';

  @override
  String get biometricLockBody => 'Usa Face ID o la huella para continuar.';

  @override
  String get biometricLockUnlockButton => 'Desbloquear';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsAboutApp => 'Acerca de';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsPrivacyTagline => 'El inicio de sesión usa Supabase.';

  @override
  String get settingsPrivacyDataTitle => 'Cuenta';

  @override
  String get settingsPrivacyDataBody =>
      'La autenticación la proporciona Supabase. Tu correo y credenciales los procesa Supabase; esta app no guarda tu contraseña.';

  @override
  String get settingsPrivacyInfraTitle => 'Qué se queda en este dispositivo';

  @override
  String get settingsPrivacyInfraBody =>
      'El idioma, el tema y el desbloqueo biométrico se guardan en este dispositivo. Tu cuenta se guarda en Supabase. Usa una contraseña fuerte.';

  @override
  String get settingsPrivacySharingTitle => 'Compartir y publicidad';

  @override
  String get settingsPrivacySharingBody =>
      'No vendemos tu información personal. Salvo el inicio de sesión con Supabase, la app no está pensada para enviar tus datos a intermediarios ni anunciantes.';

  @override
  String get settingsPrivacyNoticeTitle => 'Antes de publicar';

  @override
  String get settingsPrivacyNoticeBody =>
      'Este texto es un resumen orientativo, no asesoramiento legal. Antes de producción o de publicar en una tienda de apps, publica una política de privacidad acorde a tu jurisdicción y a cómo tratas los datos.';

  @override
  String get settingsTermsOfUse => 'Términos de uso';

  @override
  String get settingsTermsTagline => 'Normas para usar esta app.';

  @override
  String get settingsTermsAcceptanceTitle => 'Aceptación';

  @override
  String get settingsTermsAcceptanceBody =>
      'Al acceder o usar Family\'s Game aceptas estos términos. Si no estás de acuerdo, no uses la app. El inicio de sesión lo gestiona Supabase.';

  @override
  String get settingsTermsDisclaimerTitle => 'No es asesoramiento profesional';

  @override
  String get settingsTermsDisclaimerBody =>
      'Family\'s Game es una app personal. Nada en la app ni en estos términos constituye asesoramiento legal. Usas la app bajo tu propio riesgo.';

  @override
  String get settingsTermsLiabilityTitle => 'Limitación de responsabilidad';

  @override
  String get settingsTermsLiabilityBody =>
      'En la medida máxima permitida por la ley, los autores no serán responsables de daños indirectos, incidentales o consecuenciales. La app se ofrece «tal cual», sin garantías de ningún tipo.';

  @override
  String get settingsTermsResponsibilitiesTitle => 'Tus responsabilidades';

  @override
  String get settingsTermsResponsibilitiesBody =>
      'Eres responsable de proteger tu cuenta, credenciales y dispositivos. Debes cumplir las leyes que te apliquen.';

  @override
  String get settingsTermsNoticeTitle => 'Cambios y antes de publicar';

  @override
  String get settingsTermsNoticeBody =>
      'Estos términos pueden actualizarse ocasionalmente. Si sigues usando la app tras publicarse cambios, ello implica que aceptas los términos actualizados. Este texto es un resumen orientativo, no asesoramiento legal.';

  @override
  String get settingsAboutTagline => 'Lleva el marcador con quienes juegas.';

  @override
  String get settingsAboutVersionLabel => 'Versión';

  @override
  String get settingsAboutFeaturesHeading => 'Qué puedes hacer';

  @override
  String get settingsAboutBulletSignIn =>
      'Crea un juego, invita jugadores por correo y registra cada partida.';

  @override
  String get settingsAboutBulletAppearance =>
      'Anota 7 Wonders por categoría, u otro juego con un solo total.';

  @override
  String get settingsAboutBulletSecurity =>
      'Mira quién suma más victorias y quién más derrotas.';

  @override
  String get settingsAboutDataHeading => 'Tus datos';

  @override
  String get settingsAboutDataBody =>
      'Los juegos y los puntajes se guardan en Supabase y se comparten con los jugadores de cada juego. El idioma, el tema y la biometría se quedan en este dispositivo.';

  @override
  String get settingsAboutDeveloperHeading => 'Desarrollador';

  @override
  String get settingsAboutDeveloperGithub => 'GitHub';

  @override
  String get settingsAboutDeveloperWebsite => 'Sitio web';

  @override
  String get settingsAboutDeveloperYoutube => 'YouTube';

  @override
  String get settingsAboutDeveloperLinkedin => 'LinkedIn';

  @override
  String get gamesEmptyTitle => 'Todavía no hay juegos';

  @override
  String get gamesEmptyBody =>
      'Crea un juego, invita a tu familia y empieza a anotar.';

  @override
  String get newGame => 'Nuevo juego';

  @override
  String get editGame => 'Editar juego';

  @override
  String get deleteGame => 'Eliminar juego';

  @override
  String get deleteGameBody =>
      'Esto elimina el juego, sus jugadores y todas las partidas.';

  @override
  String get createGame => 'Crear juego';

  @override
  String get gameName => 'Nombre';

  @override
  String get gameType => 'Tipo';

  @override
  String get gameTypeSevenWonders => '7 Wonders';

  @override
  String get gameTypeOther => 'Otro';

  @override
  String get gameDescription => 'Descripción';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get retry => 'Reintentar';

  @override
  String get players => 'Jugadores';

  @override
  String get addPlayer => 'Agregar jugador';

  @override
  String get playerHelp =>
      'Usa el correo con el que inicia sesión en Family\'s Game.';

  @override
  String get playerNotFound =>
      'Ninguna cuenta de Family\'s Game usa ese correo.';

  @override
  String get playerAlreadyAdded => 'Ese jugador ya está en este juego.';

  @override
  String get removePlayer => 'Quitar jugador';

  @override
  String removePlayerBody(String email) {
    return '¿Quitar a $email de este juego?';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores',
      one: '1 jugador',
    );
    return '$_temp0';
  }

  @override
  String matchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String get matches => 'Partidas';

  @override
  String get newMatch => 'Nueva partida';

  @override
  String get editMatch => 'Editar partida';

  @override
  String get deleteMatch => 'Eliminar partida';

  @override
  String get deleteMatchBody => 'Esto elimina los puntajes de esta partida.';

  @override
  String get matchDate => 'Fecha';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get dateFrom => 'Desde';

  @override
  String get dateTo => 'Hasta';

  @override
  String get noMatchesInRange => 'No hay partidas en este rango.';

  @override
  String get winsOverTime => 'Victorias en el tiempo';

  @override
  String get chartStart => 'Inicio';

  @override
  String get records => 'Récords';

  @override
  String get longestWinStreak => 'Mayor racha';

  @override
  String get currentWinStreak => 'Racha actual';

  @override
  String get highestScore => 'Mayor puntaje';

  @override
  String get bestWinRate => 'Mejor porcentaje';

  @override
  String get longestLosingStreak => 'Mayor racha de derrotas';

  @override
  String get currentLosingStreak => 'Racha de derrotas';

  @override
  String get lowestScore => 'Menor puntaje';

  @override
  String get worstWinRate => 'Peor porcentaje';

  @override
  String get standings => 'Clasificación';

  @override
  String get wins => 'Victorias';

  @override
  String get losses => 'Derrotas';

  @override
  String get noStandings => 'Juega una partida para ver quién va adelante.';

  @override
  String get noPlayers =>
      'Agrega al menos dos jugadores antes de anotar una partida.';

  @override
  String get noMatches => 'Todavía no hay partidas.';

  @override
  String get points => 'Puntos';

  @override
  String get pointsMustBeWhole => 'Usa números enteros para los puntajes.';

  @override
  String get winner => 'Ganador';

  @override
  String get tie => 'Empate';

  @override
  String get leader => 'Va ganando';

  @override
  String get you => 'Tú';

  @override
  String get atLeastTwoPlayers => 'Elige al menos dos jugadores.';

  @override
  String get scoringRuleOther =>
      'Gana quien tiene más puntos. Quien tiene menos suma una derrota. Si empatan en el primer lugar, todos empatados ganan.';

  @override
  String get scoringRuleSeven =>
      'Maravilla, monedas y los cinco colores se suman. Gana el total más alto. Los demás suman una derrota.';

  @override
  String get categoryWonder => 'Maravilla';

  @override
  String get categoryCoins => 'Monedas';

  @override
  String get categoryRed => 'Rojo';

  @override
  String get categoryBlue => 'Azul';

  @override
  String get categoryYellow => 'Amarillo';

  @override
  String get categoryGreen => 'Verde';

  @override
  String get categoryPurple => 'Morado';
}

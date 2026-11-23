import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../locale/app_locale_controller.dart';
import '../security/app_biometric_unlock_controller.dart';
import '../theme/app_theme_controller.dart';
import '../../features/auth/data/datasources/auth_refresh.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/update_email_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/cubit/settings_cubit.dart';
import '../../features/games/data/datasources/games_remote_datasource.dart';
import '../../features/games/data/repositories/games_repository_impl.dart';
import '../../features/games/domain/repositories/games_repository.dart';
import '../../features/games/domain/usecases/add_member_usecase.dart';
import '../../features/games/domain/usecases/create_game_usecase.dart';
import '../../features/games/domain/usecases/delete_game_usecase.dart';
import '../../features/games/domain/usecases/delete_match_usecase.dart';
import '../../features/games/domain/usecases/get_game_usecase.dart';
import '../../features/games/domain/usecases/get_games_usecase.dart';
import '../../features/games/domain/usecases/remove_member_usecase.dart';
import '../../features/games/domain/usecases/save_match_usecase.dart';
import '../../features/games/domain/usecases/update_game_usecase.dart';
import '../../features/games/presentation/cubit/game_cubit.dart';
import '../../features/games/presentation/cubit/games_cubit.dart';

final getIt = GetIt.instance;

void setupDi() {
  getIt.registerLazySingleton<AppLocaleController>(AppLocaleController.new);
  getIt.registerLazySingleton<AppThemeController>(AppThemeController.new);
  getIt.registerLazySingleton<AppBiometricUnlockController>(
    AppBiometricUnlockController.new,
  );

  // auth
  getIt.registerLazySingleton<AuthRefresh>(AuthRefresh.new);
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthSupabaseDatasource(Supabase.instance.client),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDatasource>()),
  );
  getIt.registerFactory<GetCurrentUserUsecase>(
    () => GetCurrentUserUsecase(getIt()),
  );
  getIt.registerFactory<SignInUsecase>(() => SignInUsecase(getIt()));
  getIt.registerFactory<SignOutUsecase>(() => SignOutUsecase(getIt()));
  getIt.registerFactory<UpdateEmailUsecase>(() => UpdateEmailUsecase(getIt()));
  getIt.registerFactory<UpdatePasswordUsecase>(
    () => UpdatePasswordUsecase(getIt()),
  );
  getIt.registerFactory<LoginBloc>(() => LoginBloc(signIn: getIt()));
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit(signOut: getIt()));

  // games
  getIt.registerLazySingleton<GamesRemoteDatasource>(
    () => GamesSupabaseDatasource(Supabase.instance.client),
  );
  getIt.registerLazySingleton<GamesRepository>(
    () => GamesRepositoryImpl(getIt<GamesRemoteDatasource>()),
  );
  getIt.registerFactory<GetGamesUsecase>(() => GetGamesUsecase(getIt()));
  getIt.registerFactory<GetGameUsecase>(() => GetGameUsecase(getIt()));
  getIt.registerFactory<CreateGameUsecase>(() => CreateGameUsecase(getIt()));
  getIt.registerFactory<UpdateGameUsecase>(() => UpdateGameUsecase(getIt()));
  getIt.registerFactory<DeleteGameUsecase>(() => DeleteGameUsecase(getIt()));
  getIt.registerFactory<AddMemberUsecase>(() => AddMemberUsecase(getIt()));
  getIt.registerFactory<RemoveMemberUsecase>(
    () => RemoveMemberUsecase(getIt()),
  );
  getIt.registerFactory<SaveMatchUsecase>(() => SaveMatchUsecase(getIt()));
  getIt.registerFactory<DeleteMatchUsecase>(() => DeleteMatchUsecase(getIt()));
  getIt.registerFactory<GamesCubit>(() => GamesCubit(getGames: getIt()));
  getIt.registerFactory<GameCubit>(
    () => GameCubit(
      getGame: getIt(),
      deleteGame: getIt(),
      removeMember: getIt(),
      saveMatch: getIt(),
      deleteMatch: getIt(),
    ),
  );
}

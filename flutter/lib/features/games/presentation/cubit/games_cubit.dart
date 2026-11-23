import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/family_game.dart';
import '../../domain/usecases/get_games_usecase.dart';
import 'games_state.dart';

class GamesCubit extends Cubit<GamesState> {
  final GetGamesUsecase _getGames;

  GamesCubit({required this._getGames}) : super(const GamesInitial());

  List<FamilyGame> get _current => switch (state) {
    GamesLoaded(:final games) => games,
    GamesError(:final games) => games,
    _ => const [],
  };

  Future<void> load() async {
    AppLogger.debug('loading games');
    final current = _current;
    if (current.isEmpty) emit(const GamesLoading());
    try {
      final games = await _getGames();
      if (isClosed) return;
      AppLogger.info('games loaded: ${games.length}');
      emit(GamesLoaded(games));
    } catch (e, s) {
      AppLogger.error('failed to load games', e, s);
      if (isClosed) return;
      emit(GamesError(current));
    }
  }
}

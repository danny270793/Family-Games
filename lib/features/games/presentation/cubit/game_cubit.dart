import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/family_game.dart';
import '../../domain/entities/games_exception.dart';
import '../../domain/entities/score_draft.dart';
import '../../domain/usecases/delete_game_usecase.dart';
import '../../domain/usecases/delete_match_usecase.dart';
import '../../domain/usecases/get_game_usecase.dart';
import '../../domain/usecases/remove_member_usecase.dart';
import '../../domain/usecases/save_match_usecase.dart';
import 'game_state.dart';

/// Loads a single game and runs actions on it. Action methods return `null`
/// on success, or an error code (see `gamesErrorMessage`) on failure.
class GameCubit extends Cubit<GameState> {
  final GetGameUsecase _getGame;
  final DeleteGameUsecase _deleteGame;
  final RemoveMemberUsecase _removeMember;
  final SaveMatchUsecase _saveMatch;
  final DeleteMatchUsecase _deleteMatch;

  GameCubit({
    required this._getGame,
    required this._deleteGame,
    required this._removeMember,
    required this._saveMatch,
    required this._deleteMatch,
  }) : super(const GameInitial());

  int _revision = 0;

  FamilyGame? get game => switch (state) {
    GameLoaded(:final game) => game,
    GameError(:final game) => game,
    _ => null,
  };

  Future<void> load(String gameId) async {
    AppLogger.debug('loading game: $gameId');
    final current = game;
    if (current == null) emit(const GameLoading());
    try {
      final loaded = await _getGame(id: gameId);
      if (isClosed) return;
      AppLogger.info('game loaded: ${loaded.id}');
      emit(GameLoaded(loaded, revision: ++_revision));
    } catch (e, s) {
      AppLogger.error('failed to load game', e, s);
      if (isClosed) return;
      emit(GameError(current));
    }
  }

  Future<String?> deleteGame(String gameId) =>
      _run('delete game', () => _deleteGame(id: gameId));

  Future<String?> removeMember({
    required String gameId,
    required String memberId,
  }) async {
    final error = await _run(
      'remove member',
      () => _removeMember(memberId: memberId),
    );
    if (error == null && !isClosed) await load(gameId);
    return error;
  }

  Future<String?> saveMatch({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  }) => _run(
    'save match',
    () => _saveMatch(
      gameId: gameId,
      matchId: matchId,
      playedAt: playedAt,
      scores: scores,
    ),
  );

  Future<String?> deleteMatch(String matchId) =>
      _run('delete match', () => _deleteMatch(matchId: matchId));

  Future<String?> _run(String label, Future<Object?> Function() action) async {
    AppLogger.debug(label);
    try {
      await action();
      AppLogger.info('$label success');
      return null;
    } on GamesException catch (e) {
      AppLogger.warn('$label failed — ${e.code}');
      return e.code;
    } catch (e, s) {
      AppLogger.error('$label failed', e, s);
      return 'unexpected';
    }
  }
}

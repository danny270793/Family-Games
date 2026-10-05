import '../entities/score_draft.dart';
import '../repositories/games_repository.dart';

class SaveMatchUsecase {
  final GamesRepository _repository;

  const SaveMatchUsecase(this._repository);

  Future<String> call({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  }) => _repository.saveMatch(
    gameId: gameId,
    matchId: matchId,
    playedAt: playedAt,
    scores: scores,
  );
}

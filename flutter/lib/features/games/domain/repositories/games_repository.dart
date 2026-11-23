import '../entities/family_game.dart';
import '../entities/score_draft.dart';

abstract class GamesRepository {
  Future<List<FamilyGame>> listGames();
  Future<FamilyGame> getGame(String id);
  Future<String> createGame({
    required String name,
    required GameType type,
    required String description,
  });
  Future<void> updateGame({
    required String id,
    required String name,
    required GameType type,
    required String description,
  });
  Future<void> deleteGame(String id);
  Future<void> addMember({required String gameId, required String email});
  Future<void> removeMember(String memberId);
  Future<String> saveMatch({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  });
  Future<void> deleteMatch(String matchId);
}

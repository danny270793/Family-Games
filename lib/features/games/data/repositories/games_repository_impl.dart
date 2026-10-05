import '../../domain/entities/family_game.dart';
import '../../domain/entities/score_draft.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_remote_datasource.dart';

class GamesRepositoryImpl implements GamesRepository {
  final GamesRemoteDatasource _datasource;

  const GamesRepositoryImpl(this._datasource);

  @override
  Future<List<FamilyGame>> listGames() => _datasource.listGames();

  @override
  Future<FamilyGame> getGame(String id) => _datasource.getGame(id);

  @override
  Future<String> createGame({
    required String name,
    required GameType type,
    required String description,
  }) =>
      _datasource.createGame(name: name, type: type, description: description);

  @override
  Future<void> updateGame({
    required String id,
    required String name,
    required GameType type,
    required String description,
  }) => _datasource.updateGame(
    id: id,
    name: name,
    type: type,
    description: description,
  );

  @override
  Future<void> deleteGame(String id) => _datasource.deleteGame(id);

  @override
  Future<void> addMember({required String gameId, required String email}) =>
      _datasource.addMember(gameId: gameId, email: email);

  @override
  Future<void> removeMember(String memberId) =>
      _datasource.removeMember(memberId);

  @override
  Future<String> saveMatch({
    required String gameId,
    String? matchId,
    required DateTime playedAt,
    required List<ScoreDraft> scores,
  }) => _datasource.saveMatch(
    gameId: gameId,
    matchId: matchId,
    playedAt: playedAt,
    scores: scores,
  );

  @override
  Future<void> deleteMatch(String matchId) => _datasource.deleteMatch(matchId);
}

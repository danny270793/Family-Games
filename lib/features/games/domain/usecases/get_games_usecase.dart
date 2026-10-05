import '../entities/family_game.dart';
import '../repositories/games_repository.dart';

class GetGamesUsecase {
  final GamesRepository _repository;

  const GetGamesUsecase(this._repository);

  Future<List<FamilyGame>> call() => _repository.listGames();
}

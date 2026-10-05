import '../entities/family_game.dart';
import '../repositories/games_repository.dart';

class CreateGameUsecase {
  final GamesRepository _repository;

  const CreateGameUsecase(this._repository);

  Future<String> call({
    required String name,
    required GameType type,
    required String description,
  }) =>
      _repository.createGame(name: name, type: type, description: description);
}

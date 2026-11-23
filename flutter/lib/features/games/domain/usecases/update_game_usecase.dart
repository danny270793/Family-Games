import '../entities/family_game.dart';
import '../repositories/games_repository.dart';

class UpdateGameUsecase {
  final GamesRepository _repository;

  const UpdateGameUsecase(this._repository);

  Future<void> call({
    required String id,
    required String name,
    required GameType type,
    required String description,
  }) => _repository.updateGame(
    id: id,
    name: name,
    type: type,
    description: description,
  );
}

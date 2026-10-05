import '../repositories/games_repository.dart';

class DeleteGameUsecase {
  final GamesRepository _repository;

  const DeleteGameUsecase(this._repository);

  Future<void> call({required String id}) => _repository.deleteGame(id);
}

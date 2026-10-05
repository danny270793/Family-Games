import '../entities/family_game.dart';
import '../repositories/games_repository.dart';

class GetGameUsecase {
  final GamesRepository _repository;

  const GetGameUsecase(this._repository);

  Future<FamilyGame> call({required String id}) => _repository.getGame(id);
}

import '../repositories/games_repository.dart';

class AddMemberUsecase {
  final GamesRepository _repository;

  const AddMemberUsecase(this._repository);

  Future<void> call({required String gameId, required String email}) =>
      _repository.addMember(gameId: gameId, email: email);
}

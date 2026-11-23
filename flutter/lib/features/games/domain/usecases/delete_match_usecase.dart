import '../repositories/games_repository.dart';

class DeleteMatchUsecase {
  final GamesRepository _repository;

  const DeleteMatchUsecase(this._repository);

  Future<void> call({required String matchId}) =>
      _repository.deleteMatch(matchId);
}

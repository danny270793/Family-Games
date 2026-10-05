import '../repositories/games_repository.dart';

class RemoveMemberUsecase {
  final GamesRepository _repository;

  const RemoveMemberUsecase(this._repository);

  Future<void> call({required String memberId}) =>
      _repository.removeMember(memberId);
}

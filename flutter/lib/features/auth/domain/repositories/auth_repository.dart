import '../entities/user_entity.dart';

abstract class AuthRepository {
  UserEntity? get currentUser;
  bool get hasSession;
  Future<UserEntity> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> updateEmail({required String newEmail});
  Future<void> updatePassword({required String newPassword});
}

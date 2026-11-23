import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDatasource {
  UserEntity? get currentUser;
  bool get hasSession;
  Future<UserEntity> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> updateEmail({required String newEmail});
  Future<void> updatePassword({required String newPassword});
}

class AuthSupabaseDatasource implements AuthRemoteDatasource {
  final SupabaseClient _client;

  const AuthSupabaseDatasource(this._client);

  @override
  UserEntity? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.debug('signIn called');
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw const AuthException('Sign in failed');
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  @override
  Future<void> signOut() {
    AppLogger.debug('signOut called');
    return _client.auth.signOut();
  }

  @override
  Future<void> updateEmail({required String newEmail}) async {
    AppLogger.debug('updateEmail called');
    await _client.auth.updateUser(UserAttributes(email: newEmail));
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    AppLogger.debug('updatePassword called');
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}

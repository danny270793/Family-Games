import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const AuthException('Sign in failed');
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> updateEmail({required String newEmail}) {
    return _client.auth.updateUser(UserAttributes(email: newEmail.trim()));
  }

  Future<void> updatePassword({required String newPassword}) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}

final authRepository = AuthRepository();

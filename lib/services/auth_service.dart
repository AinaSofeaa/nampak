import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    } catch (_) {
      throw const AppException('Could not sign in. Check your connection.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw const AppException('Could not sign out.');
    }
  }
}

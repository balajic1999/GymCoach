import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Authentication service providing sign-up, sign-in, sign-out,
/// and password reset via Supabase Auth.
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign in with OAuth provider (Google, Apple).
  Future<bool> signInWithProvider(OAuthProvider provider) async {
    final response = await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.gym3d.app://callback',
    );
    return response;
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Update user metadata (e.g. display name).
  Future<UserResponse> updateUser({String? fullName}) async {
    return await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName}),
    );
  }

  /// Delete the current user's account.
  /// Requires server-side Edge Function for safety — placeholder.
  Future<void> deleteAccount() async {
    // Will be implemented via Supabase Edge Function for security
    throw UnimplementedError(
      'Account deletion requires server-side Edge Function implementation',
    );
  }
}

/// Provider for the AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

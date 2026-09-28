import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(Supabase.instance.client);
}

/// Watches the Supabase auth state — emits User? on change.
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
}

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google OAuth.
  Future<AuthResponse?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Google sign-in failed: missing tokens');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Sign out.
  Future<void> signOut() => _client.auth.signOut();

  /// Send password reset email.
  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  /// Returns the current user's display name.
  String get displayName {
    final meta = currentUser?.userMetadata;
    return (meta?['full_name'] as String?) ??
        (meta?['name'] as String?) ??
        currentUser?.email?.split('@').first ??
        'there';
  }
}

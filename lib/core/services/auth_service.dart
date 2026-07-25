import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth — every method here is what the
/// founder spec's Technical Requirements ask for: Google, Apple, Email.
/// Apple sign-in wiring is left as a documented follow-up (needs an Apple
/// Developer account + capability configuration outside code).
///
/// The `profiles` row for a new user is created by a database trigger
/// (`handle_new_user`, see supabase/migrations/0001_init.sql) — this
/// class never writes to `profiles` directly on sign-up.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<User?> authStateChanges() {
    return _client.auth.onAuthStateChange
        .map((AuthState state) => state.session?.user);
  }

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'display_name': displayName},
    );
  }

  /// Native Google sign-in, exchanged for a Supabase session via ID token
  /// — see docs/SETUP.md for the Google Cloud + Supabase provider config
  /// this needs (a web client ID shared between GoogleSignIn and Supabase).
  Future<AuthResponse> signInWithGoogle() async {
    final String? webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      serverClientId: webClientId,
    ).signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled.');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    if (idToken == null) {
      throw const AuthException('Google sign-in did not return an ID token.');
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _client.auth.signOut();
  }
}

final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (Ref ref) => AuthService(),
);

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref ref) => ref.watch(authServiceProvider).authStateChanges(),
);

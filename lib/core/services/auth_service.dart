import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

/// Thin wrapper around FirebaseAuth — every method here is what the
/// founder spec's Technical Requirements ask for: Google, Apple, Email.
/// Apple sign-in wiring is left as a documented follow-up (needs an Apple
/// Developer account + capability configuration outside code).
class AuthService {
  AuthService(this._firestore);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestore;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(displayName);
    await _firestore.upsertUserProfile(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
    );
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential result = await _firebaseAuth.signInWithCredential(
      credential,
    );
    if (result.additionalUserInfo?.isNewUser ?? false) {
      await _firestore.upsertUserProfile(
        uid: result.user!.uid,
        displayName: result.user!.displayName ?? '',
        email: result.user!.email ?? '',
        photoUrl: result.user!.photoURL,
      );
    }
    return result;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}

final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (Ref ref) => AuthService(ref.watch(firestoreServiceProvider)),
);

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref ref) => ref.watch(authServiceProvider).authStateChanges(),
);

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  static final AuthService authService = AuthService._();

  AuthService._();

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      print('DEBUG: No Firebase user');
      return null;
    }

    final token = await user.getIdToken(true);

    print('DEBUG: Firebase UID: ${user.uid}');
    print('DEBUG: ID token received: ${token != null}');

    return token;
  }

  /// Signup / create user with email and password
  Future<UserCredential> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    // Combine the first and last name for Firebase's display name.
    final fullName = '$firstName $lastName'.trim();

    await credential.user?.updateDisplayName(fullName);

    await credential.user?.reload();

    return credential;
  }

  /// Sing in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// User sign in with google
  Future<UserCredential> signInWithGoogle() async {
    // Initialize Google Sign-In before starting authentication.
    //
    // This is the Web OAuth client ID from Firebase.
    await _googleSignIn.initialize(
      serverClientId:
      '173883973257-a8t81j0em7v83msgnjdr71ihd4nph15h.apps.googleusercontent.com',
    );

    // Open the Google account selection screen.
    final GoogleSignInAccount googleUser =
    await _googleSignIn.authenticate();

    // Get the Google authentication information.
    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    // Create a Firebase credential using the Google ID token.
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase using the Google credential.
    return await _firebaseAuth.signInWithCredential(
      credential,
    );
  }

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign out user
  Future<void> signOut () async {
    await _firebaseAuth.signOut();
  }

}
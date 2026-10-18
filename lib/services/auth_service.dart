import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  static final AuthService authService = AuthService._();

  AuthService._();

  Stream<User?> get userChanges {
    return _firebaseAuth.userChanges();
  }

  Stream<User?> get authChanges {
    return _firebaseAuth.authStateChanges();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    final token = await user.getIdToken();

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

    final updatedUser = _firebaseAuth.currentUser;
    await updatedUser?.getIdToken();

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

  /// Update the authenticated user's display name in Firebase.
  ///
  /// After updating the name, refresh the ID token so the backend
  /// can receive the updated profile information.
  Future<void> updateUserDisplayName({
    required String firstName,
    required String lastName,
  }) async {
    // Get the currently authenticated Firebase user.
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to update your profile.');
    }

    // Combine the first and last names into Firebase's display name.
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    // Save the updated name to Firebase Authentication.
    await user.updateDisplayName(fullName);

    // Reload the user to retrieve the latest Firebase profile.
    await user.reload();

    // Get the refreshed current-user instance.
    final updatedUser = _firebaseAuth.currentUser;

    if (updatedUser == null) {
      throw Exception('Unable to reload the Firebase user.');
    }

    // Force a fresh ID token containing the updated profile claims.
    await updatedUser.getIdToken(true);
  }

  /// Update the profile photo URL in Firebase Authentication.
  Future<void> updateUserPhotoURL(String photoUrl) async {
    // Get the current Firebase user.
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to update your profile photo.');
    }

    // Update Firebase's profile URL.
    await user.updatePhotoURL(photoUrl);

    // Reload the user to obtain the updated profile.
    await user.reload();

    // Retrieve the refreshed Firebase user.
    final updatedUser = _firebaseAuth.currentUser;

    if (updatedUser == null) {
      throw Exception('Unable to reload the Firebase user.');
    }

    // Refresh the token so subsequent backend requests use the
    // freshest available Firebase profile claims.
    await updatedUser.getIdToken(true);
  }

}
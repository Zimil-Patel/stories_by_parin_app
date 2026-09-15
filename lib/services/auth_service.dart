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

  /// Signup / create user with email and password
  Future<UserCredential> signUpWithEmail({required String email, required String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Sing in with email and password
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// User sign in with google
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    return await _firebaseAuth.signInWithCredential(credential);

  }

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign out user
  Future<void> signOut () async {
    await _firebaseAuth.signOut();
  }

}
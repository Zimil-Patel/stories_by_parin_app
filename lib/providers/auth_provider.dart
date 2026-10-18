import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stories_by_parin/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // Firebase authentication operations.
  final AuthService _authService = AuthService.authService;

  // The currently authenticated Firebase user.
  User? _user;

  // Authentication operation state.
  bool _isLoading = false;
  bool _isInitializing = true;
  bool _isSigningUp = false;
  String? _error;

  // Listen for Firebase authentication changes.
  StreamSubscription<User?>? _authSubscription;

  // Public getters for the UI and other providers.
  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  bool get isSigningUp => _isSigningUp;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _listenToAuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Listen to Firebase sign-in and sign-out events.
  ///
  /// Profile loading is handled separately by ProfileProvider.
  void _listenToAuthState() {
    _authSubscription = _authService.authChanges.listen((user) {
      _user = user;
      _isInitializing = false;

      // Notify the UI and ProfileProvider about the auth state.
      notifyListeners();
    });
  }

  /// Create an account using email and password.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Set this before notifying listeners so they see the correct state.
    _isSigningUp = true;
    _startLoading();

    try {
      // AuthService creates the Firebase account and updates its name.
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _user = _authService.currentUser ?? credential.user;
      _error = null;

      // ProfileProvider will load the local profile after signup completes.
      return true;
    } on FirebaseAuthException catch (error) {
      _error = _firebaseErrorMessage(error);
      return false;
    } catch (error) {
      _error = error.toString();
      debugPrint('Signup failed: $error');
      return false;
    } finally {
      // Let ProfileProvider load only after signup/profile setup finishes.
      _isSigningUp = false;
      _stopLoading();
    }
  }

  /// Sign in using email and password.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _startLoading();

    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _user = credential.user;
      _error = null;

      return true;
    } on FirebaseAuthException catch (error) {
      _error = _firebaseErrorMessage(error);
      return false;
    } catch (error) {
      _error = error.toString();
      debugPrint('Email sign-in failed: $error');
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Sign in using Google.
  Future<bool> signInWithGoogle() async {
    _startLoading();

    try {
      final credential = await _authService.signInWithGoogle();

      _user = credential.user;
      _error = null;

      return true;
    } on FirebaseAuthException catch (error) {
      _error = _firebaseErrorMessage(error);
      debugPrint('Google sign-in failed: $_error');
      return false;
    } catch (error) {
      _error = 'Something went wrong';
      debugPrint('Google sign-in failed: $error');
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Sign out of Firebase.
  Future<void> signOutUser() async {
    try {
      await _authService.signOut();

      _user = null;
      _error = null;

      // ProfileProvider observes the authentication change and clears
      // the local profile.
      notifyListeners();
    } catch (error) {
      _error = 'Failed to sign out. Please try again.';
      debugPrint('Sign-out failed: $error');
      notifyListeners();
    }
  }

  /// Mark an authentication operation as active.
  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  /// Mark an authentication operation as finished.
  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Convert Firebase errors into user-friendly messages.
  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Please choose a stronger password.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'user-disabled':
        return 'This account has been disabled.';

      default:
        return error.message ??
            'Authentication failed. Please try again.';
    }
  }
}
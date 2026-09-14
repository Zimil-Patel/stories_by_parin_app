import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:stories_by_parin/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  /// Sign up user / create new user with email and password
  Future<bool> signUpWithEmail({required String email, required String password}) async {
    _startLoading();
    try {
      final credential = await _authService.signUpWithEmail(
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
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Sign in user by entering email and password
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
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Continue login with google option
  Future<bool> signInWithGoogle() async {
    _startLoading();
    try {
      final credential = await _authService.signInWithGoogle();

      _user = credential.user;
      _error = null;

      return true;
    } on FirebaseAuthException catch (error) {
      _error = _firebaseErrorMessage(error);
      return false;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _stopLoading();
    }
  }

  /// Log out user / Sign out user
  Future<void> signOutUser() async {
    await _authService.signOut();

    _user = null;
    _error = null;

    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _error = null;

    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;

    notifyListeners();
  }

  /// Convert firebase error message into suitable message
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
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

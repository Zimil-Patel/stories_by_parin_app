import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:stories_by_parin/models/user_model.dart';
import 'package:stories_by_parin/services/api_service.dart';
import 'package:stories_by_parin/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  StreamSubscription<User?>? _authSubscription;

  UserModel? _localUser;

  UserModel? get localUser => _localUser;

  bool _isInitializing= true;

  User? get user => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get isLoggedIn => _user != null;

  bool get isInitializing => _isInitializing;

  AuthProvider(){
    _listenToAuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalUser() async {
    // Ask FastAPI for the local user associated
    // with the currently authenticated Firebase account.
    final response =
    await ApiService.apiService.getCurrentUser();

    // Extract the local user from the API response.
    final userJson =
    response['user'] as Map<String, dynamic>;

    // Convert the API JSON into our UserModel.
    _localUser = UserModel.fromJson(userJson);

    print('Local user loaded successfully');
    print('Local user ID: ${_localUser?.id}');
    print('Local user name: ${_localUser?.fullName}');
  }

  /// listen to auth changes
  void _listenToAuthState() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      _user = user;


      if(user == null){
        _localUser = null;
        _isInitializing = false;
        notifyListeners();
        return;
      }

      try{
        await _loadLocalUser();
      } catch (error) {
        _localUser = null;

        print('Failed to load locl user during auth initialization');
        print('Error: $error');
      }

      _isInitializing = false;
      notifyListeners();
    });
  }

  /// Sign up user / create new user with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _startLoading();
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
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
        password: password
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
      print("=> $_error}");
      return false;
    } catch (error) {
      _error = "Something went wrong";
      print("=> $error}");
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

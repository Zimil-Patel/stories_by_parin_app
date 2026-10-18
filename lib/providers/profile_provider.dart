import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:stories_by_parin/models/user_model.dart';
import 'package:stories_by_parin/services/auth_service.dart';
import 'package:stories_by_parin/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  // Services used for fetching the application profile.
  final ProfileService _profileService = ProfileService.profileService;
  final AuthService _authService = AuthService.authService;

  // The profile returned by the FastAPI backend.
  UserModel? _profile;

  // Profile loading and error state.
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  // Firebase UID whose profile is currently stored.
  String? _loadedFirebaseUid;

  // Track an in-flight request so duplicate callers can share it.
  String? _loadingFirebaseUid;
  Future<void>? _loadingFuture;

  // Track which authentication state we have already handled.
  String? _lastObservedFirebaseUid;
  bool _hasObservedAuthState = false;

  // Tracks whether a profile update is in progress.
  bool _isUpdatingProfile = false;

  bool get isUpdatingProfile => _isUpdatingProfile;
  // Public getters expose profile state to widgets.
  UserModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isInitializing => _isInitializing;

  String? get error => _error;

  bool get hasProfile => _profile != null;

  /// Handle authentication changes provided by AuthProvider.
  ///
  /// This method does not itself verify Firebase tokens. AuthService
  /// and ProfileService handle authentication for backend requests.
  void handleAuthChanged(User? firebaseUser) {
    final firebaseUid = firebaseUser?.uid;

    // Multiple AuthProvider notifications for the same account
    // should not start additional profile requests.
    if (_hasObservedAuthState &&
        _lastObservedFirebaseUid == firebaseUid) {
      return;
    }

    _hasObservedAuthState = true;
    _lastObservedFirebaseUid = firebaseUid;

    if (firebaseUser == null) {
      // Sign-out: the profile is no longer needed.
      scheduleMicrotask(() {
        // Ignore stale callbacks if another account signed in.
        if (_lastObservedFirebaseUid != null) {
          return;
        }

        clearProfile();
      });

      return;
    }

    // Mark initial loading synchronously so AuthGate can wait.
    // We do not notify synchronously from the provider update callback.
    if (_loadedFirebaseUid != firebaseUid) {
      _isInitializing = true;
    }

    // Wait until the current provider update/build has completed.
    scheduleMicrotask(() {
      // Ignore this callback if another auth state arrived meanwhile.
      if (_lastObservedFirebaseUid != firebaseUid) {
        return;
      }

      // Confirm that Firebase still has the same account.
      if (_authService.currentUser?.uid != firebaseUid) {
        return;
      }

      // Don't display the previous account's profile after account changes.
      if (_loadedFirebaseUid != firebaseUid) {
        _profile = null;
        _loadedFirebaseUid = null;
        _error = null;
        _isInitializing = true;

        notifyListeners();
      }

      // loadProfile prevents duplicate requests for the same account.
      unawaited(loadProfile(force: true));
    });
  }

  /// Fetch the current user's local profile from FastAPI.
  ///
  /// If the same user's request is already running, other callers
  /// await that operation instead of making another API call.
  Future<void> loadProfile({bool force = false}) async {
    final firebaseUser = _authService.currentUser;

    // There is no profile to load when the user is signed out.
    if (firebaseUser == null) {
      clearProfile();
      return;
    }

    final firebaseUid = firebaseUser.uid;

    // Reuse the already loaded profile unless a refresh is requested.
    if (!force &&
        _loadedFirebaseUid == firebaseUid &&
        _profile != null) {
      if (_isInitializing) {
        _isInitializing = false;
        notifyListeners();
      }

      return;
    }

    // Share an existing request for the same Firebase account.
    final existingFuture = _loadingFuture;

    if (existingFuture != null &&
        _loadingFirebaseUid == firebaseUid) {
      await existingFuture;
      return;
    }

    // Create a Future that other calls can await.
    final completer = Completer<void>();
    final requestFuture = completer.future;

    _loadingFuture = requestFuture;
    _loadingFirebaseUid = firebaseUid;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      // ProfileService calls the authenticated /auth/me endpoint.
      final loadedProfile = await _profileService.fetchProfile();

      // Do not apply an old response if the account has changed.
      if (_authService.currentUser?.uid == firebaseUid) {
        _profile = loadedProfile;
        _loadedFirebaseUid = firebaseUid;
        _error = null;
      }
    } catch (error) {
      // Keep the error available for the UI or a retry action.
      if (_authService.currentUser?.uid == firebaseUid) {
        _error = error.toString();
      }

      debugPrint('Failed to load local profile: $error');
    } finally {
      // Only the request that still owns the loading slot can clear it.
      if (identical(_loadingFuture, requestFuture)) {
        _loadingFuture = null;
        _loadingFirebaseUid = null;
        _isLoading = false;

        // A request for an old account should not finish initialization
        // for a newer account that is waiting to load its own profile.
        if (_authService.currentUser?.uid == firebaseUid ||
            _authService.currentUser == null) {
          _isInitializing = false;
        }

        notifyListeners();
      }

      // Release every caller that was waiting for this operation.
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  /// Force a fresh profile request.
  ///
  /// Useful after profile details have been changed.
  Future<void> refreshProfile() {
    return loadProfile(force: true);
  }

  /// Clear profile data when a user signs out.
  void clearProfile() {
    _profile = null;
    _loadedFirebaseUid = null;
    _error = null;
    _isLoading = false;
    _isInitializing = false;

    // Invalidate any old loading request. Its response will not be
    // allowed to overwrite the profile for a later account.
    _loadingFirebaseUid = null;
    _loadingFuture = null;

    notifyListeners();
  }

  /// Update the user's first and last name.
  ///
  /// First updates Firebase Authentication, then fetches the profile
  /// from FastAPI so the updated name is synchronized with SQLite.
  Future<bool> updateProfileName({
    required String firstName,
    required String lastName,
  }) async {
    // Remove accidental whitespace from the entered names.
    final normalizedFirstName = firstName.trim();
    final normalizedLastName = lastName.trim();

    // At least one name must be provided.
    if ('$normalizedFirstName $normalizedLastName'.trim().isEmpty) {
      _error = 'Please enter your first or last name.';
      notifyListeners();
      return false;
    }

    // Prevent multiple profile updates from running simultaneously.
    if (_isUpdatingProfile) {
      return false;
    }

    // Make sure a Firebase account is currently signed in.
    final firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      _error = 'Please sign in to update your profile.';
      notifyListeners();
      return false;
    }

    // Remember which account this update belongs to.
    final firebaseUid = firebaseUser.uid;

    _isUpdatingProfile = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: update the Firebase Authentication display name.
      // AuthService also reloads the user and refreshes the ID token.
      await _authService.updateUserDisplayName(
        firstName: normalizedFirstName,
        lastName: normalizedLastName,
      );

      // Step 2: fetch the profile from FastAPI.
      // The refreshed token lets the backend synchronize the new name
      // through the existing /auth/me and syncUser() flow.
      final updatedProfile = await _profileService.fetchProfile();

      // Do not apply the response if the user switched accounts.
      if (_authService.currentUser?.uid != firebaseUid) {
        return false;
      }

      // Step 3: update the profile held in memory.
      _profile = updatedProfile;
      _loadedFirebaseUid = firebaseUid;
      _error = null;

      return true;
    } catch (error) {
      _error = error.toString();
      debugPrint('Failed to update profile name: $error');

      return false;
    } finally {
      // Always release the update state and refresh dependent widgets.
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  /// Upload a new profile picture and refresh the local profile.
  Future<bool> uploadProfilePhoto(Uint8List imageBytes) async {
    // Do not allow simultaneous profile updates.
    if (_isUpdatingProfile) {
      return false;
    }

    // Remember which Firebase account owns this operation.
    final firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      _error = 'Please sign in to change your profile photo.';
      notifyListeners();
      return false;
    }

    final firebaseUid = firebaseUser.uid;

    _isUpdatingProfile = true;
    _error = null;
    notifyListeners();

    // Retain the URL in case Firebase profile updating fails.
    String? uploadedPhotoUrl;

    try {
      // 1. Upload to our own FastAPI server.
      // The backend saves the image and updates users.photo_url.
      uploadedPhotoUrl =
      await _profileService.uploadProfilePhoto(imageBytes);

      // Avoid applying an old upload result to a different account.
      if (_authService.currentUser?.uid != firebaseUid) {
        return false;
      }

      // 2. Update Firebase Authentication's photoURL.
      await _authService.updateUserPhotoURL(uploadedPhotoUrl);

      // 3. Retrieve the latest profile from FastAPI and SQLite.
      final updatedProfile = await _profileService.fetchProfile();

      // Check the account again before changing provider state.
      if (_authService.currentUser?.uid != firebaseUid) {
        return false;
      }

      _profile = updatedProfile;
      _loadedFirebaseUid = firebaseUid;
      _error = null;

      return true;
    } catch (error) {
      debugPrint('Profile photo update failed: $error');

      // The server may have saved the photo before Firebase updating
      // failed. Reload the backend profile to avoid leaving the UI stale.
      if (uploadedPhotoUrl != null &&
          _authService.currentUser?.uid == firebaseUid) {
        try {
          _profile = await _profileService.fetchProfile();
          _loadedFirebaseUid = firebaseUid;
        } catch (refreshError) {
          debugPrint('Profile refresh failed: $refreshError');
        }
      }

      _error = 'Unable to update profile photo. Please try again.';

      return false;
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }
}
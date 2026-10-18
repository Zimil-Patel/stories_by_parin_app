import 'package:flutter/material.dart';

import '../models/gallery_member.dart';

import '../services/api_service.dart';

class GalleryMembersProvider extends ChangeNotifier {
  // Reuse the existing API service.
  final ApiService _apiService = ApiService.apiService;

  // Members and invitations returned by FastAPI.
  List<GalleryMember> _members = [];

  // State for loading and errors.
  bool _isLoading = false;
  String? _error;

  // The project whose members are currently stored.
  int? _projectId;

  // Remember which project has successfully loaded.
  int? _loadedProjectId;

  // Identify the currently active request.
  int _requestGeneration = 0;
  int? _loadingProjectId;

  // Public getters for the UI.
  List<GalleryMember> get members => List.unmodifiable(_members);

  bool get isLoading => _isLoading;

  String? get error => _error;

  int? get projectId => _projectId;

  /// Fetch members and pending invitations for a project.
  Future<void> fetchMembers(
      int projectId, {
        bool force = false,
      }) async {
    // Don't send another request when this project's request
    // is already running.
    if (_isLoading && _loadingProjectId == projectId) {
      return;
    }

    // Reuse data already loaded for this project unless refreshing.
    if (!force && _loadedProjectId == projectId) {
      return;
    }

    // A generation number prevents an older request from
    // overwriting a newer project's member list.
    final requestGeneration = ++_requestGeneration;

    _projectId = projectId;
    _loadingProjectId = projectId;
    _isLoading = true;
    _error = null;

    // Avoid showing the previous project's members while loading.
    _members = [];

    notifyListeners();

    try {
      // ApiService sends the Firebase ID token and parses the response.
      final members = await _apiService.getGalleryMembers(projectId);

      // Ignore the response if another request replaced this one.
      if (requestGeneration != _requestGeneration) {
        return;
      }

      _members = members;
      _loadedProjectId = projectId;
    } catch (error) {
      if (requestGeneration == _requestGeneration) {
        _error = error.toString();
      }

      debugPrint('Failed to load gallery members: $error');
    } finally {
      // Only the active request can release the loading state.
      if (requestGeneration == _requestGeneration) {
        _isLoading = false;
        _loadingProjectId = null;

        notifyListeners();
      }
    }
  }

  /// Clear cached data when needed, such as after sign-out.
  void clearMembers() {
    // Invalidate any request that is still running.
    _requestGeneration++;

    _members = [];
    _projectId = null;
    _loadedProjectId = null;
    _loadingProjectId = null;
    _isLoading = false;
    _error = null;

    notifyListeners();
  }
}
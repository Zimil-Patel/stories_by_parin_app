import 'package:flutter/material.dart';

import '../models/gallery_member.dart';

import '../models/project_model.dart';
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

  // Tracks a role update separately from initial list loading.
  bool _isUpdatingMemberRole = false;
  int? _updatingMemberId;
  String? _memberActionError;

  bool _isRemovingMember = false;
  int? _removingMemberId;

  bool get isRemovingMember => _isRemovingMember;
  int? get removingMemberId => _removingMemberId;

  bool get isUpdatingMemberRole => _isUpdatingMemberRole;
  int? get updatingMemberId => _updatingMemberId;
  String? get memberActionError => _memberActionError;

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

  /// Change a member's role and update the local list.
  Future<bool> changeMemberRole({
    required int projectId,
    required int memberId,
    required GalleryRole role,
  }) async {
    // Only allow one role update at a time.
    if (_isUpdatingMemberRole) {
      return false;
    }

    _isUpdatingMemberRole = true;
    _updatingMemberId = memberId;
    _memberActionError = null;

    notifyListeners();

    try {
      // Ask FastAPI to enforce permissions and update the database.
      await _apiService.updateGalleryMemberRole(
        projectId: projectId,
        memberId: memberId,
        role: role,
      );

      // Update the displayed member only after the server succeeds.
      final index = _members.indexWhere(
            (member) => member.id == memberId,
      );

      if (index != -1) {
        _members[index] = _members[index].copyWith(role: role);
      }

      return true;
    } catch (error) {
      // Keep role-update errors separate from list-loading errors.
      _memberActionError = error.toString();

      debugPrint('Failed to change gallery member role: $error');

      return false;
    } finally {
      _isUpdatingMemberRole = false;
      _updatingMemberId = null;

      notifyListeners();
    }
  }

  /// Remove a member after the backend confirms the operation.
  Future<bool> removeMember({
    required int projectId,
    required int memberId,
  }) async {
    // Don't overlap role changes and removal operations.
    if (_isUpdatingMemberRole || _isRemovingMember) {
      return false;
    }

    _isRemovingMember = true;
    _removingMemberId = memberId;
    _memberActionError = null;

    notifyListeners();

    try {
      // The backend checks permissions and performs the deletion.
      await _apiService.removeGalleryMember(
        projectId: projectId,
        memberId: memberId,
      );

      // Remove the member from the local list only after API success.
      if (_projectId == projectId) {
        _members.removeWhere((member) => member.id == memberId);
      }

      return true;
    } catch (error) {
      _memberActionError = error.toString();

      debugPrint('Failed to remove gallery member: $error');

      return false;
    } finally {
      _isRemovingMember = false;
      _removingMemberId = null;

      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:stories_by_parin/services/admin_service.dart';

import '../models/gallery_member.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService.adminService;

  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _users = [];

  bool _isLoading = false;
  bool _isLoadingUsers = false;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _actionMessage;
  List<GalleryMember> _galleryMembers = [];
  bool _isLoadingGalleryMembers = false;
  int? _galleryMembersProjectId;
  String? _galleryMembersError;

  List<Map<String, dynamic>> get projects => _projects;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String? get actionMessage => _actionMessage;
  List<GalleryMember> get galleryMembers =>
      List.unmodifiable(_galleryMembers);

  bool get isLoadingGalleryMembers => _isLoadingGalleryMembers;

  int? get galleryMembersProjectId => _galleryMembersProjectId;

  String? get galleryMembersError => _galleryMembersError;

  int get totalProjects => _projects.length;

  int get totalGalleries => _projects
      .where((project) => project['gallery_id'] != null)
      .length;

  int get enabledGalleries => _projects
      .where((project) => project['is_enabled'] == true)
      .length;

  Future<void> loadGalleryMembers(int projectId) async {
    if (_isLoadingGalleryMembers &&
        _galleryMembersProjectId == projectId) {
      return;
    }

    _isLoadingGalleryMembers = true;
    _galleryMembersProjectId = projectId;
    _galleryMembersError = null;
    _galleryMembers = [];
    notifyListeners();

    try {
      _galleryMembers = await _adminService.getAdminGalleryMembers(
        projectId,
      );
    } catch (error) {
      _galleryMembersError = _cleanError(error);
    } finally {
      _isLoadingGalleryMembers = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    if (_isLoadingUsers) return;

    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _adminService.getAdminUsers();
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  /// Load all projects and their gallery statuses.
  Future<void> loadProjects() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _adminService.getAdminProjects();
    } catch (error) {
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a gallery for an existing project.
  Future<bool> createGallery(int projectId) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _errorMessage = null;
    _actionMessage = null;
    notifyListeners();

    try {
      await _adminService.createAdminGallery(projectId);

      await _refreshProjectsAfterAction();

      _actionMessage = 'Gallery created successfully.';
      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Enable or disable a project's gallery.
  Future<bool> updateGalleryStatus({
    required int projectId,
    required bool isEnabled,
  }) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _errorMessage = null;
    _actionMessage = null;
    notifyListeners();

    try {
      await _adminService.updateAdminGalleryStatus(
        projectId: projectId,
        isEnabled: isEnabled,
      );

      await _refreshProjectsAfterAction();

      _actionMessage = isEnabled
          ? 'Gallery enabled successfully.'
          : 'Gallery disabled successfully.';

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Refresh the list without replacing the screen with a loader.
  Future<void> _refreshProjectsAfterAction() async {
    _projects = await _adminService.getAdminProjects();
  }

  /// Clear messages after they have been displayed by the UI.
  void clearMessages() {
    _errorMessage = null;
    _actionMessage = null;
    notifyListeners();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

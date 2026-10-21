
import 'package:flutter/foundation.dart';

import 'package:stories_by_parin/services/gallery_sharing_service.dart';

class GallerySharingProvider extends ChangeNotifier {
  GallerySharingProvider({
    GallerySharingService? service,
  }) : _service = service ?? GallerySharingService.instance;

  final GallerySharingService _service;

  // --------------------------------------------------
  // DATA
  // --------------------------------------------------

  List<Map<String, dynamic>> _shareLinks = [];
  List<Map<String, dynamic>> _accessRequests = [];
  List<Map<String, dynamic>> _invitations = [];

  List<Map<String, dynamic>> get shareLinks =>
      List.unmodifiable(_shareLinks);

  List<Map<String, dynamic>> get accessRequests =>
      List.unmodifiable(_accessRequests);

  List<Map<String, dynamic>> get invitations =>
      List.unmodifiable(_invitations);

  // --------------------------------------------------
  // LOADING STATES
  // --------------------------------------------------

  bool _isLoadingShareLinks = false;
  bool _isLoadingAccessRequests = false;
  bool _isLoadingInvitations = false;
  bool _isPerformingAction = false;

  bool get isLoadingShareLinks => _isLoadingShareLinks;
  bool get isLoadingAccessRequests => _isLoadingAccessRequests;
  bool get isLoadingInvitations => _isLoadingInvitations;
  bool get isPerformingAction => _isPerformingAction;

  // --------------------------------------------------
  // ERROR STATE
  // --------------------------------------------------

  String? _error;

  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _error = error.toString().replaceFirst('Exception: ', '');
  }

  // --------------------------------------------------
  // SHARE LINKS
  // --------------------------------------------------

  Future<bool> fetchShareLinks(int projectId) async {
    _isLoadingShareLinks = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getShareLinks(projectId);

      _shareLinks = result;
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isLoadingShareLinks = false;
      notifyListeners();
    }
  }

  Future<bool> createShareLink({
    required int projectId,
    required DateTime expiresAt,
  }) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      // Convert to UTC and use an ISO-8601 timestamp.
      final expiresAtUtc = expiresAt
          .toUtc()
          .toIso8601String();

      await _service.createShareLink(
        projectId: projectId,
        expiresAtUtc: expiresAtUtc,
      );

      // Reload so the list reflects the backend's saved record.
      final result = await _service.getShareLinks(projectId);
      _shareLinks = result;

      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> revokeShareLink({
    required int projectId,
    required int shareLinkId,
  }) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      await _service.revokeShareLink(
        projectId: projectId,
        shareLinkId: shareLinkId,
      );

      final index = _shareLinks.indexWhere(
            (link) => link['id'].toString() == shareLinkId.toString(),
      );

      if (index != -1) {
        _shareLinks[index] = {
          ..._shareLinks[index],
          'revoked_at_utc': DateTime.now().toUtc().toIso8601String(),
        };
      }

      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // ACCESS REQUESTS
  // --------------------------------------------------

  Future<bool> fetchAccessRequests({
    required int projectId,
    String? status = 'pending',
  }) async {
    _isLoadingAccessRequests = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getAccessRequests(
        projectId: projectId,
        status: status,
      );

      _accessRequests = result;
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isLoadingAccessRequests = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> requestAccess(
      String token,
      ) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      return await _service.requestAccess(token);
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> resolveAccessRequest({
    required int projectId,
    required int requestId,
    required bool approve,
  }) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      await _service.resolveAccessRequest(
        projectId: projectId,
        requestId: requestId,
        approve: approve,
      );

      final result = await _service.getAccessRequests(
        projectId: projectId,
        status: 'pending',
      );

      _accessRequests = result;
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // EMAIL INVITATIONS
  // --------------------------------------------------

  Future<bool> fetchInvitations(int projectId) async {
    _isLoadingInvitations = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getInvitations(projectId);

      _invitations = result;
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isLoadingInvitations = false;
      notifyListeners();
    }
  }

  Future<bool> inviteByEmail({
    required int projectId,
    required String email,
    required String role,
  }) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      await _service.inviteByEmail(
        projectId: projectId,
        email: email,
        role: role,
      );

      final result = await _service.getInvitations(projectId);
      _invitations = result;

      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> revokeInvitation({
    required int projectId,
    required int invitationId,
  }) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();

    try {
      await _service.revokeInvitation(
        projectId: projectId,
        invitationId: invitationId,
      );

      _invitations.removeWhere(
            (invitation) => invitation['id'] == invitationId,
      );

      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // RESET STATE
  // --------------------------------------------------

  void clearData() {
    _shareLinks = [];
    _accessRequests = [];
    _invitations = [];
    _error = null;

    notifyListeners();
  }
}

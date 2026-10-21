
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/services/auth_service.dart';

class GallerySharingService {
  GallerySharingService._();

  static final GallerySharingService instance =
  GallerySharingService._();

  // --------------------------------------------------
  // AUTHORIZATION
  // --------------------------------------------------

  Future<Map<String, String>> _authorizedHeaders({
    bool jsonContent = false,
  }) async {
    final token = await AuthService.authService.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to continue.');
    }

    return {
      'Authorization': 'Bearer $token',
      if (jsonContent) 'Content-Type': 'application/json',
    };
  }

  // --------------------------------------------------
  // RESPONSE HELPERS
  // --------------------------------------------------

  dynamic _decodeResponse(http.Response response) {
    dynamic data;

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        data = null;
      }
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final message = data is Map<String, dynamic>
          ? data['detail']?.toString()
          : null;

      throw Exception(
        message ?? 'Request failed (${response.statusCode}).',
      );
    }

    return data;
  }

  Map<String, dynamic> _decodeObject(
      http.Response response,
      ) {
    final data = _decodeResponse(response);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Unexpected server response.');
  }

  List<Map<String, dynamic>> _decodeList(
      http.Response response, {
        String? listKey,
      }) {
    final data = _decodeResponse(response);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      if (listKey != null && data[listKey] is List) {
        return (data[listKey] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }

      // Support common list response envelopes.
      for (final key in [
        'share_links',
        'requests',
        'access_requests',
        'invitations',
      ]) {
        if (data[key] is List) {
          return (data[key] as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }

    throw Exception('Unexpected server response.');
  }

  void _ensureSuccess(http.Response response) {
    _decodeResponse(response);
  }

  // --------------------------------------------------
  // SHARE LINKS
  // --------------------------------------------------

  /// Create a share link with a mandatory UTC expiry.
  ///
  /// Example expiry:
  /// 2026-12-31T18:30:00Z
  Future<Map<String, dynamic>> createShareLink({
    required int projectId,
    required String expiresAtUtc,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/share-links',
      ),
      headers: await _authorizedHeaders(jsonContent: true),
      body: jsonEncode({
        'expires_at_utc': expiresAtUtc,
      }),
    );

    return _decodeObject(response);
  }

  /// Get share links for a project gallery.
  Future<List<Map<String, dynamic>>> getShareLinks(
      int projectId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/share-links',
      ),
      headers: await _authorizedHeaders(),
    );

    return _decodeList(response, listKey: 'share_links');
  }

  /// Revoke a share link.
  Future<void> revokeShareLink({
    required int projectId,
    required int shareLinkId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/share-links/$shareLinkId',
      ),
      headers: await _authorizedHeaders(),
    );

    _ensureSuccess(response);
  }

  // --------------------------------------------------
  // ACCESS REQUESTS
  // --------------------------------------------------

  /// Request access using a share-link token.
  Future<Map<String, dynamic>> requestAccess(
      String token,
      ) async {
    final response = await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}/gallery/share-links/'
            '${Uri.encodeComponent(token)}/requests',
      ),
      headers: await _authorizedHeaders(),
    );

    return _decodeObject(response);
  }

  /// Get gallery access requests.
  Future<List<Map<String, dynamic>>> getAccessRequests({
    required int projectId,
    String? status,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/projects/$projectId/'
          'gallery/access-requests',
    ).replace(
      queryParameters: status == null
          ? null
          : {'status': status},
    );

    final response = await http.get(
      uri,
      headers: await _authorizedHeaders(),
    );

    return _decodeList(
      response,
      listKey: 'requests',
    );
  }

  /// Approve or reject an access request.
  Future<Map<String, dynamic>> resolveAccessRequest({
    required int projectId,
    required int requestId,
    required bool approve,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/access-requests/$requestId/decision',
      ),
      headers: await _authorizedHeaders(jsonContent: true),
      body: jsonEncode({
        'approve': approve,
      }),
    );

    return _decodeObject(response);
  }

  // --------------------------------------------------
  // EMAIL INVITATIONS
  // --------------------------------------------------

  /// Invite an email address as an Owner or Viewer.
  ///
  /// The backend determines whether the user already exists
  /// and whether membership can be granted immediately.
  Future<Map<String, dynamic>> inviteByEmail({
    required int projectId,
    required String email,
    required String role,
  }) async {
    if (role != 'owner' && role != 'viewer') {
      throw ArgumentError.value(
        role,
        'role',
        'Role must be owner or viewer.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty ||
        !normalizedEmail.contains('@')) {
      throw ArgumentError.value(
        email,
        'email',
        'Enter a valid email address.',
      );
    }

    final response = await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/members',
      ),
      headers: await _authorizedHeaders(jsonContent: true),
      body: jsonEncode({
        'email': normalizedEmail,
        'role': role,
      }),
    );

    return _decodeObject(response);
  }

  /// Get invitations for a gallery.
  Future<List<Map<String, dynamic>>> getInvitations(
      int projectId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/invitations',
      ),
      headers: await _authorizedHeaders(),
    );

    return _decodeList(
      response,
      listKey: 'invitations',
    );
  }

  /// Revoke a pending invitation.
  Future<void> revokeInvitation({
    required int projectId,
    required int invitationId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/invitations/$invitationId',
      ),
      headers: await _authorizedHeaders(),
    );

    _ensureSuccess(response);
  }
}

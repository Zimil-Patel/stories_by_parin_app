
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/services/auth_service.dart';

import '../models/gallery_member.dart';

class AdminService {
  AdminService._();

  static final AdminService adminService = AdminService._();

  /// Build authenticated headers for admin API requests.
  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await AuthService.authService.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in.');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch every project and its gallery status.
  /// The backend verifies that the current user is an Admin.
  Future<List<Map<String, dynamic>>> getAdminProjects() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/admin/projects'),
      headers: await _authorizedHeaders(),
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['detail']?.toString()
          : null;

      throw Exception(
        message ?? 'Failed to load admin projects.',
      );
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['projects'] is! List) {
      throw Exception('Invalid admin projects response.');
    }

    final projects = decoded['projects'] as List<dynamic>;

    return projects
        .map(
          (project) => Map<String, dynamic>.from(
        project as Map,
      ),
    )
        .toList();
  }

  /// Create a gallery for an existing project.
  Future<Map<String, dynamic>> createAdminGallery(
      int projectId,
      ) async {
    final response = await http.post(
      Uri.parse(
        '${AppConfig.baseUrl}/admin/projects/$projectId/gallery',
      ),
      headers: await _authorizedHeaders(),
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['detail']?.toString()
          : null;

      throw Exception(
        message ?? 'Failed to create gallery.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid gallery creation response.');
    }

    return decoded;
  }

  /// Enable or disable a project's gallery.
  Future<void> updateAdminGalleryStatus({
    required int projectId,
    required bool isEnabled,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '${AppConfig.baseUrl}/admin/projects/$projectId/gallery',
      ),
      headers: {
        ...await _authorizedHeaders(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'is_enabled': isEnabled,
      }),
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['detail']?.toString()
          : null;

      throw Exception(
        message ?? 'Failed to update gallery status.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/admin/users'),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(
          (data['users'] as List).map(
                (user) => Map<String, dynamic>.from(user),
          ),
        );
      }

      throw Exception(data['message'] ?? 'Failed to load users.');
    }

    throw Exception(
      'Failed to load users. Status code: ${response.statusCode}',
    );
  }

  Future<List<GalleryMember>> getAdminGalleryMembers(
      int projectId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/admin/projects/'
            '$projectId/gallery/members',
      ),
      headers: await _authorizedHeaders(),
    );

    final Map<String, dynamic> responseData =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['detail'] ??
            'Failed to load gallery members.',
      );
    }

    if (responseData['success'] != true) {
      throw Exception(
        responseData['message'] ??
            'Failed to load gallery members.',
      );
    }

    final List<dynamic> members =
    responseData['members'] as List<dynamic>;

    return members
        .map(
          (member) => GalleryMember.fromJson(
        member as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}

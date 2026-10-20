import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/models/person_model.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/services/auth_service.dart';

import '../models/gallery_member.dart';

class ApiService {
  ApiService._();

  static final ApiService apiService = ApiService._();

  /// Build the Authorization header for authenticated API requests.
  ///
  /// Firebase returns a cached ID token when it is still valid
  /// and refreshes it automatically when necessary.
  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await AuthService.authService.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in.');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch the currently authenticated user's local profile.
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/auth/me'),
      headers: await _authorizedHeaders(),
    );

    final responseData =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['detail'] ?? 'Failed to get current user',
      );
    }

    return responseData;
  }

  /// Fetch all projects.
  Future<List<Project>> getAllProjects() async {

    // log("Before call");

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/projects'),
      headers: await _authorizedHeaders(),
    );

    // log("After call");

    if (response.statusCode != 200) {
      throw Exception('Failed to load projects');
    }

    final List<dynamic> data = jsonDecode(response.body);
    // log("PROJECTS: $data");

    return data
        .map(
          (json) => Project.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Fetch all galleries
  Future<List<Project>> getAllGalleries() async {


    final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/my-galleries'),
      headers: await _authorizedHeaders()
    );

    if(response.statusCode != 200) {
      throw Exception('Failed to load galleries');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final galleries = data['galleries'] as List<dynamic>;

    return galleries.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();

  }

  /// Fetch registered members and pending invitations for a gallery.
  /// Only a gallery Owner should be allowed to call this endpoint.
  Future<List<GalleryMember>> getGalleryMembers(
      int projectId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/gallery/members',
      ),
      headers: await _authorizedHeaders(),
    );

    final responseData =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['detail'] ?? 'Failed to load gallery members.',
      );
    }

    final List<dynamic> data =
    responseData['members'] as List<dynamic>;

    return data
        .map(
          (json) => GalleryMember.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Fetch events belonging to a project.
  Future<List<Event>> getAllEvents(int projectId) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/events',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load events');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => Event.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Fetch photos belonging to an event.
  ///
  /// The backend checks whether the user has access to the
  /// gallery containing this event.
  Future<List<Photo>> getAllPhotosOfEvent(int eventId) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/events/$eventId/photos',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load photos: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => Photo.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Fetch all detected faces belonging to a project.
  Future<List<Person>> getAllFacesOfProject(
      int projectId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/faces',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load faces');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (json) => Person.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Fetch photos containing a particular person.
  Future<List<Photo>> getPhotosForPerson(
      int projectId,
      int faceId,
      ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/faces/$faceId/photos',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load person photos');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> photos = data['photos'] as List<dynamic>;

    return photos
        .map(
          (json) => Photo.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  /// Update the favourite status of a photo.
  Future<void> setPhotoFavourite({
    required int photoId,
    required bool isFavourite,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${AppConfig.baseUrl}/photos/$photoId/favourite'
            '?is_favourite=$isFavourite',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update photo favourite status: '
            '${response.statusCode}',
      );
    }
  }

  /// Change a member's role in a gallery.
  /// The backend verifies that the current user is an Owner.
  Future<void> updateGalleryMemberRole({
    required int projectId,
    required int memberId,
    required GalleryRole role,
  }) async {
    // Obtain the Firebase token for the authenticated request.
    final authHeaders = await _authorizedHeaders();

    final response = await http.patch(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/members/$memberId',
      ),
      headers: {
        ...authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        // FastAPI expects "owner" or "viewer".
        'role': role.name,
      }),
    );

    // Read the API response to provide useful error messages.
    final dynamic decoded =
    response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['detail']?.toString()
          : null;

      throw Exception(
        message ?? 'Failed to update gallery member role.',
      );
    }
  }

  /// Remove a member or pending invitation from a gallery.
  /// FastAPI verifies Owner permissions and protects the last Owner.
  Future<void> removeGalleryMember({
    required int projectId,
    required int memberId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '${AppConfig.baseUrl}/projects/$projectId/'
            'gallery/members/$memberId',
      ),
      headers: await _authorizedHeaders(),
    );

    if (response.statusCode != 200) {
      final responseData = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      throw Exception(
        responseData['detail'] ?? 'Failed to remove gallery member.',
      );
    }
  }
}
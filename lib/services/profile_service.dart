import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/models/user_model.dart';
import 'package:stories_by_parin/services/auth_service.dart';

class ProfileService {
  // Use a single shared instance throughout the application.
  ProfileService._();

  static final ProfileService profileService = ProfileService._();

  final AuthService _authService = AuthService.authService;

  /// Fetch the authenticated user's profile from FastAPI.
  Future<UserModel> fetchProfile() async {
    // Get the current Firebase ID token.
    // Firebase reuses the cached token when it is still valid.
    final token = await _authService.getIdToken();

    log("TOKEN----\n$token\n----");

    if (token == null || token.isEmpty) {
      throw Exception('User is not authenticated.');
    }

    // Request the profile from the backend.
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Decode the JSON response.
    final responseData =
    jsonDecode(response.body) as Map<String, dynamic>;

    // Convert backend errors into readable exceptions.
    if (response.statusCode != 200) {
      throw Exception(
        responseData['detail'] ?? 'Failed to load profile.',
      );
    }

    // Extract the local user returned by FastAPI.
    final userJson = responseData['user'] as Map<String, dynamic>;

    // Convert the response to our application profile model.
    return UserModel.fromJson(userJson);
  }

  /// Upload a cropped profile picture to our server
  Future<String> uploadProfilePhoto(Uint8List imageBytes) async {
    // Obtain the current Firebase ID token for authentication.
    final token = await AuthService.authService.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please sign in to upload your profile photo.');
    }

    // Multipart requests allow us to send an image file to FastAPI.
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}/auth/me/profile-photo'),
    );

    // Authenticate the upload request.
    request.headers['Authorization'] = 'Bearer $token';

    // Use a JPEG filename because the cropper produces JPEG output.
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'profile.jpg',
      ),
    );

    // Send the image to your own server.
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Decode the backend response.
    final responseData =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['detail'] ?? 'Failed to upload profile photo.',
      );
    }

    // The backend returns the URL stored in SQLite.
    final photoUrl = responseData['photo_url'] as String?;

    if (photoUrl == null || photoUrl.isEmpty) {
      throw Exception('The server did not return a profile photo URL.');
    }

    return photoUrl;
  }
}
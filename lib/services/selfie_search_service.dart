import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stories_by_parin/config/app_config.dart';

class SelfieSearchService {
  static final SelfieSearchService selfieSearchService =
      SelfieSearchService._();

  SelfieSearchService._();

  Future<Map<String, dynamic>> searchSelfie({
    required int projectId,
    required File selfie,
  }) async {
    
    final uri = Uri.parse("${AppConfig.baseUrl}/projects/$projectId/search-selfie");

    final request = http.MultipartRequest(
      'POST',
      uri
    );

    request.files.add(
      await http.MultipartFile.fromPath('selfie', selfie.path),
    );
    
    final streamResponse = await request.send();

    final response = await http.Response.fromStream(streamResponse);

    final responseData = jsonDecode(response.body);

    if(response.statusCode != 200){
      throw Exception(responseData['detail']);
    }

    return responseData as Map<String, dynamic>;
    
  }
}

import 'dart:convert';
import 'dart:developer' as console;

import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/models/face_model.dart';
import 'package:stories_by_parin/models/photo_model.dart';

import '../models/project_model.dart';
import 'package:http/http.dart' as http;

class ApiService {

  ApiService._();
  static final ApiService apiService = ApiService._();

  /// Fetch list of all projects
  Future<List<Project>> getAllProjects() async {
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/projects"));

    if (response.statusCode != 200) {
      throw Exception('Failed to load projects');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map(
            (json) => Project.fromJson(json as Map<String, dynamic>,)
    ).toList();
  }

  /// Fetch events for specific project
  Future<List<Event>> getAllEvents(int projectId) async{

    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/projects/$projectId/events"));

    if(response.statusCode != 200){
      throw Exception('Failed to load events');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
  }
  
  /// Fetch all photos of particular events
  Future<List<Photo>> getAllPhotosOfEvent(int eventId) async {
    
    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/events/$eventId/photos"));
    
    if(response.statusCode != 200){
      throw Exception('Failed to load photos');
    }
    
    final List<dynamic> data = jsonDecode(response.body); 
    
    return data.map((json) => Photo.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetch all faces of project
  Future<List<Person>> getAllFacesOfProject(int projectId) async {

    final response = await http.get(Uri.parse("${AppConfig.baseUrl}/projects/$projectId/faces"));

    if(response.statusCode != 200){
      throw Exception('Failed to load faces');
    }

    final List<dynamic> data = jsonDecode(response.body);
    
    return data.map((json) => Person.fromJson(json)).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/services/api_service.dart';

class ProjectProvider extends ChangeNotifier {

  final _apiService = ApiService.apiService;

  /// State
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects() async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _projects = await _apiService.getAllProjects();
    } catch(error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }


}
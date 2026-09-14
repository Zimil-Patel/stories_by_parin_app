import 'package:flutter/material.dart';
import 'package:stories_by_parin/services/api_service.dart';

import '../models/person_model.dart';

class PeopleProvider extends ChangeNotifier {
  final _apiService = ApiService.apiService;

  List<Person> _people = [];
  bool _isLoading = false;
  String? _error;

  List<Person> get people => _people;


  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchPeople(int projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _people = await _apiService.getAllFacesOfProject(projectId);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}

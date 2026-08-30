import 'dart:developer' as console;

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/services/api_service.dart';

class EventProvider extends ChangeNotifier {

  final _apiService = ApiService.apiService;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEvents(int projectId) async {


    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _events = await _apiService.getAllEvents(projectId);
    } catch(error){
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

}

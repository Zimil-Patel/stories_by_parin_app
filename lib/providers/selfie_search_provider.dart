import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/selfie_search_result_model.dart';
import 'package:stories_by_parin/services/selfie_search_service.dart';

class SelfieSearchProvider extends ChangeNotifier {
  final _selfieService = SelfieSearchService.selfieSearchService;

  bool _isLoading = false;
  SelfieSearchResult? _result;
  String? _error;

  bool get isLoading => _isLoading;

  SelfieSearchResult? get result => _result;

  String? get error => _error;

  Future<bool> searchSelfie({
    required int projectId,
    required File selfie,
  }) async {
    _isLoading = true;
    _error = null;
    _result = null;

    notifyListeners();

    try {
      final response = await _selfieService.searchSelfie(
        projectId: projectId,
        selfie: selfie,
      );

      log("=> Response: $response");

      _result = SelfieSearchResult.fromJson(response);

      if (response['success'] != true) {
        _error = response['message'] ?? "No matching person found.";

        return false;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _error = null;
    _isLoading = false;

    notifyListeners();
  }
}

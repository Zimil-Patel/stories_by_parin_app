import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/services/api_service.dart';

class PersonPhotoProvider extends ChangeNotifier {
  final _apiService = ApiService.apiService;

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<Photo> get photos => _photos;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchPhotosOfFaces(int projectId, int faceId, BuildContext context,) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _photos = await _apiService.getPhotosForPerson(projectId, faceId);
      context.read<PhotoProvider>().mergePhotos(
        _photos,
      );

    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

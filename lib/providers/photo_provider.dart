
import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/services/api_service.dart';

class PhotoProvider extends ChangeNotifier {

  final _apiService = ApiService.apiService;

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _error;
  bool _newestFirst = false;

  List<Photo> get photos => _photos;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get newestFirst => _newestFirst;

  Future<void> fetchAllPhotosOfEvent(int eventId) async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    try{

      _photos = await _apiService.getAllPhotosOfEvent(eventId);

    } catch(error) {

      _error = error.toString();

    } finally {

      _isLoading = false;
      notifyListeners();

    }
  }

  Future<void> refreshPhotoSilently(int eventId) async {
    try{
      final latestPhotos = await _apiService.getAllPhotosOfEvent(eventId);

      final existingIds = _photos.map((e) => e.id).toSet();

      final newPhotos = latestPhotos.where((photo) => !existingIds.contains(photo.id),);

      if(newPhotos.isEmpty){
        return;
      }

      /// update if new photo detected
      _photos = [..._photos, ...newPhotos];

      _photos = sortPhotos(photos);

      notifyListeners();

    } catch(e) {
      debugPrint('=> Silent Photo refresh failed: $error');
    }
  }


  void toggleSortOrder(){
    _newestFirst = !_newestFirst;
    
    _photos = sortPhotos(_photos);

    notifyListeners();
  }


  List<Photo> sortPhotos(List<Photo> photos) {
    final sortedPhotos = [...photos];

    sortedPhotos.sort((a, b) {
      final comparison = a.id.compareTo(b.id);

      if(_newestFirst) {
        return -comparison;
      }

      return comparison;
    },);

    return sortedPhotos;
  }
}
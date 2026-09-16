
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

  Future<bool> toggleFavourite(int photoId) async {
    final photoIndex = _photos.indexWhere((photo) => photo.id == photoId);

    if(photoIndex == -1){
      return false;
    }

    final currentPhoto = _photos[photoIndex];

    final newFavouriteStatus = !currentPhoto.isFavourite;

    _photos[photoIndex] = currentPhoto.copyWith(isFavourite: newFavouriteStatus);

    notifyListeners();

    try{

      await _apiService.setPhotoFavourite(photoId: photoId, isFavourite: newFavouriteStatus);
      return true;

    } catch (error) {
      _photos[photoIndex] = currentPhoto;
      notifyListeners();
      debugPrint(
        '=> Failed to update favourite: $error',
      );

      return false;
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

  /// Merge photos loaded by another provider into this provider.
  ///
  /// This is useful for screens such as Person Photos or Face Search,
  /// where the photos come from a different API/provider but we still
  /// want FavouriteButton to use the central PhotoProvider state.
  void mergePhotos(List<Photo> newPhotos) {
    for (final newPhoto in newPhotos) {
      final existingIndex = _photos.indexWhere(
            (photo) => photo.id == newPhoto.id,
      );

      if (existingIndex == -1) {
        // Photo is not currently known by PhotoProvider,
        // so add it.
        _photos.add(newPhoto);
      } else {
        // Photo already exists.
        //
        // Replace it with the latest version returned by the API.
        // This keeps isFavourite up to date.
        _photos[existingIndex] = newPhoto;
      }
    }

    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/services/api_service.dart';

class PhotoProvider extends ChangeNotifier {
  final _apiService = ApiService.apiService;

  List<Photo> _photos = [];
  List<Photo> _favouritePhotos = [];

  bool _isLoading = false;
  bool _isLoadingFavourites = false;

  String? _error;
  String? _favouritesError;

  bool _newestFirst = false;

  List<Photo> get photos => _photos;
  List<Photo> get favouritePhotos => _favouritePhotos;

  bool get isLoading => _isLoading;
  bool get isLoadingFavourites => _isLoadingFavourites;

  String? get error => _error;
  String? get favouritesError => _favouritesError;

  bool get newestFirst => _newestFirst;

  Future<void> fetchAllPhotosOfEvent(int eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _photos = await _apiService.getAllPhotosOfEvent(eventId);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all favourited photos across the project.
  Future<void> fetchProjectFavouritePhotos(int projectId) async {
    _isLoadingFavourites = true;
    _favouritesError = null;
    notifyListeners();

    try {
      final fetchedPhotos =
      await _apiService.getProjectFavouritePhotos(projectId);

      _favouritePhotos = sortPhotos(
        fetchedPhotos.where((photo) => photo.isFavourite).toList(),
      );

      // Keep favourite photos available to FavouriteButton,
      // even when they belong to another event.
      mergePhotos(fetchedPhotos);
    } catch (error) {
      _favouritesError = error.toString();
    } finally {
      _isLoadingFavourites = false;
      notifyListeners();
    }
  }

  Future<void> refreshPhotoSilently(int eventId) async {
    try {
      final latestPhotos =
      await _apiService.getAllPhotosOfEvent(eventId);

      final existingIds = _photos.map((photo) => photo.id).toSet();

      final newPhotos = latestPhotos.where(
            (photo) => !existingIds.contains(photo.id),
      );

      if (newPhotos.isEmpty) {
        return;
      }

      _photos = sortPhotos([..._photos, ...newPhotos]);
      notifyListeners();
    } catch (error) {
      debugPrint('=> Silent Photo refresh failed: $error');
    }
  }

  Future<bool> toggleFavourite(int photoId) async {
    final photoIndex =
    _photos.indexWhere((photo) => photo.id == photoId);

    if (photoIndex == -1) {
      return false;
    }

    final currentPhoto = _photos[photoIndex];
    final newFavouriteStatus = !currentPhoto.isFavourite;

    // Save the previous favourites list in case the request fails.
    final previousFavouritePhotos = List<Photo>.from(_favouritePhotos);

    final updatedPhoto = currentPhoto.copyWith(
      isFavourite: newFavouriteStatus,
    );

    // Update the main photo list.
    _photos[photoIndex] = updatedPhoto;

    // Update the favourites screen immediately.
    _favouritePhotos.removeWhere((photo) => photo.id == photoId);

    if (newFavouriteStatus) {
      _favouritePhotos.add(updatedPhoto);
      _favouritePhotos = sortPhotos(_favouritePhotos);
    }

    notifyListeners();

    try {
      await _apiService.setPhotoFavourite(
        photoId: photoId,
        isFavourite: newFavouriteStatus,
      );
      return true;
    } catch (error) {
      // Restore the photo's previous favourite status.
      final currentIndex =
      _photos.indexWhere((photo) => photo.id == photoId);

      if (currentIndex != -1) {
        _photos[currentIndex] = currentPhoto;
      }

      _favouritePhotos = previousFavouritePhotos;

      notifyListeners();

      debugPrint('=> Failed to update favourite: $error');
      return false;
    }
  }

  void toggleSortOrder() {
    _newestFirst = !_newestFirst;

    _photos = sortPhotos(_photos);
    _favouritePhotos = sortPhotos(_favouritePhotos);

    notifyListeners();
  }

  List<Photo> sortPhotos(List<Photo> photos) {
    final sortedPhotos = [...photos];

    sortedPhotos.sort((a, b) {
      final comparison = a.id.compareTo(b.id);
      return _newestFirst ? -comparison : comparison;
    });

    return sortedPhotos;
  }

  /// Merge photos from other screens into the central photo list.
  void mergePhotos(List<Photo> newPhotos) {
    for (final newPhoto in newPhotos) {
      final existingIndex =
      _photos.indexWhere((photo) => photo.id == newPhoto.id);

      if (existingIndex == -1) {
        _photos.add(newPhoto);
      } else {
        _photos[existingIndex] = newPhoto;
      }
    }

    notifyListeners();
  }
}

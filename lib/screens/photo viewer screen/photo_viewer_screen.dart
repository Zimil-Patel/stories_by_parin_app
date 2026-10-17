import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_zoom/photo_zoom.dart';
import 'package:stories_by_parin/models/project_model.dart';

import '../../config/app_config.dart';
import '../../models/photo_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/favourite_button.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<Photo> photos;
  final Project project;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex, required this.project,
  });

  @override
  State<PhotoViewerScreen> createState() =>
      _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late int _currentIndex;

  // Keep one page controller for the lifetime of this screen.
  late final PageController _pageController;

  // Store the token so image widgets and preloading use the same
  // authenticated request headers while the viewer is open.
  String? _idToken;
  bool _isLoadingToken = true;
  String? _tokenError;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );

    // Authenticate before starting image requests.
    _loadAuthorizationToken();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Obtain the current Firebase token before loading images.
  Future<void> _loadAuthorizationToken() async {
    try {
      final token = await AuthService.authService.getIdToken();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        setState(() {
          _isLoadingToken = false;
          _tokenError =
          'Please sign in again to view these photos.';
        });
        return;
      }

      setState(() {
        _idToken = token;
        _isLoadingToken = false;
      });

      // Preload images after the authenticated UI is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _preloadNearbyPhotos(_currentIndex);
        }
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Failed to obtain image authorization: $error');

      setState(() {
        _isLoadingToken = false;
        _tokenError = 'Unable to authenticate image requests.';
      });
    }
  }

  /// Build the Authorization header used by protected image endpoints.
  Map<String, String> get _imageHeaders => {
    'Authorization': 'Bearer $_idToken',
  };

  /// Preload thumbnails and originals near the current photo.
  void _preloadNearbyPhotos(int index) {
    if (_idToken == null) return;

    final indexesToPreload = <int>[
      index,
      index - 1,
      index + 1,
    ];

    for (final photoIndex in indexesToPreload) {
      if (photoIndex < 0 ||
          photoIndex >= widget.photos.length) {
        continue;
      }

      final photo = widget.photos[photoIndex];

      final thumbnailUrl =
          '${AppConfig.baseUrl}/photos/${photo.id}/thumbnail';

      final originalUrl =
          '${AppConfig.baseUrl}/photos/${photo.id}/image';

      // Preload the authenticated thumbnail.
      precacheImage(
        CachedNetworkImageProvider(
          thumbnailUrl,
          headers: _imageHeaders,
        ),
        context,
      ).catchError((error) {
        debugPrint(
          'Thumbnail preload failed for photo ${photo.id}: $error',
        );
      });

      // Preload the authenticated full-resolution original.
      precacheImage(
        CachedNetworkImageProvider(
          originalUrl,
          headers: _imageHeaders,
        ),
        context,
      ).catchError((error) {
        debugPrint(
          'Original preload failed for photo ${photo.id}: $error',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait until we have an authorization token.
    if (_isLoadingToken) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Do not request protected images without authentication.
    if (_idToken == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _tokenError ?? 'Unable to load photos.',
              style: const TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentPhotoId = widget.photos[_currentIndex].id;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.photos.length,
            pageController: _pageController,

            builder: (context, index) {
              final photo = widget.photos[index];

              final thumbnailUrl =
                  '${AppConfig.baseUrl}/photos/${photo.id}/thumbnail'
                  '?v=${photo.createdAt}';

              final originalUrl =
                  '${AppConfig.baseUrl}/photos/${photo.id}/image'
                  '?v=${photo.createdAt}';

              return PhotoViewGalleryPageOptions.customChild(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --------------------------------------------
                    // AUTHENTICATED CACHED THUMBNAIL
                    // --------------------------------------------
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      httpHeaders: _imageHeaders,
                      fit: BoxFit.contain,
                    ),

                    // --------------------------------------------
                    // AUTHENTICATED ORIGINAL PHOTO
                    // --------------------------------------------
                    Image(
                      image: CachedNetworkImageProvider(
                        originalUrl,
                        headers: _imageHeaders,
                      ),
                      fit: BoxFit.contain,

                      // Keep the thumbnail visible while the
                      // original image loads.
                      loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                          ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const SizedBox.shrink();
                      },

                      // Keep the thumbnail visible if the original
                      // image cannot be displayed.
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        debugPrint(
                          'Original image failed for photo '
                              '${photo.id}: $error',
                        );

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),

                // Use the actual original photo dimensions.
                childSize: Size(
                  photo.width.toDouble(),
                  photo.height.toDouble(),
                ),

                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                basePosition: Alignment.center,
              );
            },

            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),

            // Update the selected photo and preload its neighbors.
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });

              _preloadNearbyPhotos(index);
            },
          ),

          // CLOSE BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _ViewerButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // FAVOURITE BUTTON
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 58,
            child: FavouriteButton(
              role: widget.project.role ?? GalleryRole.viewer,
              photoId: currentPhotoId,
            ),
          ),

          // PHOTO COUNTER
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Text(
              '${_currentIndex + 1} / ${widget.photos.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ViewerButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
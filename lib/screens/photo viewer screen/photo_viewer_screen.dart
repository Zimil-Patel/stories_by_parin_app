import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_zoom/photo_zoom.dart';

import '../../config/app_config.dart';
import '../../models/photo_model.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadNearbyPhotos(widget.initialIndex);
    });
  }

  // Preload the original images immediately before and after
  // the currently visible photo.
  void _preloadNearbyPhotos(int index) {
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

      // Preload the small thumbnail.
      // This gives us something lightweight to show immediately.
      precacheImage(
        CachedNetworkImageProvider(thumbnailUrl),
        context,
      ).catchError((error) {
        debugPrint(
          'Thumbnail preload failed for photo ${photo.id}: $error',
        );
      });

      // Preload the full-resolution original.
      precacheImage(
        CachedNetworkImageProvider(originalUrl),
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
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.photos.length,

            builder: (context, index) {
              final photo = widget.photos[index];

              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  '${AppConfig.baseUrl}/photos/${photo.id}/image',
                ),

                // The whole screen is used as the viewer area.
                minScale: PhotoViewComputedScale.contained,

                // Allow the user to zoom considerably into
                // high-resolution wedding photos.
                maxScale:
                PhotoViewComputedScale.covered * 3,

                // Keep the photo centered when it is not zoomed.
                basePosition: Alignment.center,
              );
            },

            // Start from the photo selected in the grid.
            pageController: PageController(
              initialPage: widget.initialIndex,
            ),

            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),

            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });

              // Preload the new photo's neighbors.
              _preloadNearbyPhotos(index);
            },
          ),

          // Close button.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _ViewerButton(
              icon: Icons.close,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Photo counter.
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
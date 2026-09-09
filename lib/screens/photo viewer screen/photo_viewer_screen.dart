import 'package:flutter/material.dart';

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
  State<PhotoViewerScreen> createState() =>
      _PhotoViewerScreenState();
}

class _PhotoViewerScreenState
    extends State<PhotoViewerScreen> {
  late final PageController _pageController;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // -------------------------------------------------
          // PHOTO PAGES
          // -------------------------------------------------

          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,

            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            itemBuilder: (context, index) {
              final photo = widget.photos[index];

              return Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,


                  child: _ViewerPhoto(photo: photo),
                ),
              );
            },
          ),

          // -------------------------------------------------
          // CLOSE BUTTON
          // -------------------------------------------------

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _ViewerButton(
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          // -------------------------------------------------
          // PHOTO COUNTER
          // -------------------------------------------------

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // -------------------------------------------------
          // BOTTOM HINT
          // -------------------------------------------------

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Swipe to navigate • Pinch to zoom',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------
// VIEWER BUTTON
// -------------------------------------------------

class _ViewerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ViewerButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

// -------------------------------------------------
// VIEWER PHOTO
// -------------------------------------------------

class _ViewerPhoto extends StatelessWidget {
  final Photo photo;

  const _ViewerPhoto({
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        '${AppConfig.baseUrl}/photos/${photo.id}/thumbnail';

    final originalUrl =
        '${AppConfig.baseUrl}/photos/${photo.id}/image';

    return Stack(
      alignment: Alignment.center,
      children: [
        // -------------------------------------------------
        // THUMBNAIL
        // -------------------------------------------------
        //
        // This loads quickly and stays visible while the
        // full-resolution image is loading.
        //

        Image.network(
          thumbnailUrl,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const SizedBox.shrink();
          },
        ),

        // -------------------------------------------------
        // ORIGINAL PHOTO
        // -------------------------------------------------
        //
        // The original image is displayed on top once it
        // has finished loading.
        //

        Image.network(
          originalUrl,
          fit: BoxFit.contain,

          frameBuilder: (
              context,
              child,
              frame,
              wasSynchronouslyLoaded,
              ) {
            if (wasSynchronouslyLoaded) {
              return child;
            }

            if (frame == null) {
              return const SizedBox.shrink();
            }

            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 250),
              child: child,
            );
          },

          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Unable to load photo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
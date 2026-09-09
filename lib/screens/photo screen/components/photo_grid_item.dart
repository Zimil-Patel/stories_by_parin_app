import 'package:flutter/material.dart';
import 'package:stories_by_parin/config/app_config.dart';

import '../../../models/photo_model.dart';
import '../../photo viewer screen/photo_viewer_screen.dart';

class PhotoGridItem extends StatelessWidget {
  final Photo photo;
  final List<Photo> photos;
  final int index;

  const PhotoGridItem({
    super.key,
    required this.photo,
    required this.photos,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoViewerScreen(
              photos: photos,
              initialIndex: index,
            ),
          ),
        );
      },

      // Clip the image so the rounded corners are visible.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),

        child: Image.network(
          '${AppConfig.baseUrl}/photos/${photo.id}/thumbnail',
          fit: BoxFit.cover,

          // Keep the image from overflowing while loading.
          frameBuilder: (
              context,
              child,
              frame,
              wasSynchronouslyLoaded,
              ) {
            if (wasSynchronouslyLoaded) {
              return child;
            }

            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: child,
            );
          },

          // Show loading indicator while the image is loading.
          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          },

          // Show a simple error state if the image cannot load.
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const ColoredBox(
              color: Colors.black12,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          '${AppConfig.baseUrl}/photos/${photo.id}/image',
          fit: BoxFit.cover,

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
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          },

          // Show a simple error icon if the image cannot load.
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl:
          '${AppConfig.baseUrl}/photos/${photo.id}/thumbnail',

          fit: BoxFit.cover,

          // Show a small loader only if the thumbnail
          // is not already available in the cache.
          // Show shimmer while the thumbnail is loading.
          placeholder: (context, url) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                color: Colors.white,
              ),
            );
          },

          // Show an error state if the thumbnail cannot load.
          errorWidget: (context, url, error) {
            return const ColoredBox(
              color: Colors.black12,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                ),
              ),
            );
          },

          // Slight fade when the image first appears.
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
        ),
      ),
    );
  }
}


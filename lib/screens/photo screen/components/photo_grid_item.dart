import 'package:flutter/material.dart';

import '../../../models/photo_model.dart';


class PhotoGridItem extends StatelessWidget {

  final Photo photo;

  const PhotoGridItem({
    super.key,
    required this.photo,
  });


  @override
  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius:
      BorderRadius.circular(6),

      child: Image.network(

        'http://127.0.0.1:8000/photos/${photo.id}/image',

        fit: BoxFit.cover,

        // Shows a loader while the image is downloading.
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {

          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        // Shows something useful if the server can't
        // return the image.
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {

          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
            ),
          );
        },
      ),
    );
  }
}
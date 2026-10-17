import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stories_by_parin/config/app_config.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/services/auth_service.dart';
import 'package:stories_by_parin/widgets/favourite_button.dart';

import '../models/photo_model.dart';
import '../screens/photo viewer screen/photo_viewer_screen.dart';

class PhotoGridItem extends StatefulWidget {
  final Photo photo;
  final List<Photo> photos;
  final int index;
  final Project project;

  const PhotoGridItem({
    super.key,
    required this.photo,
    required this.photos,
    required this.index, required this.project,
  });

  @override
  State<PhotoGridItem> createState() => _PhotoGridItemState();
}

class _PhotoGridItemState extends State<PhotoGridItem> {

  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();

    _tokenFuture = AuthService.authService.getIdToken();
  }

  // Keep the existing shimmer loading appearance.
  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoViewerScreen(
              project: widget.project,
              photos: widget.photos,
              initialIndex: widget.index,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder<String?>(
                future: _tokenFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState != ConnectionState.done) {
                    return _buildPlaceholder();
                  }

                  final token = snapshot.data;

                  // Do not make an unauthenticated image request.
                  if (token == null || token.isEmpty) {
                    return const ColoredBox(
                      color: Colors.black12,
                      child: Center(
                        child: Icon(
                          Icons.lock_outline,
                          size: 32,
                        ),
                      ),
                    );
                  }

                  return CachedNetworkImage(
                    imageUrl:
                    '${AppConfig.baseUrl}/photos/${widget.photo.id}/thumbnail?v=${widget.photo.createdAt}',

                    httpHeaders: {
                      'Authorization': 'Bearer $token',
                    },

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
                  );
                }
              ),
            ),

            /// Favourite btn
            FavouriteButton(photoId: widget.photo.id,role: widget.project.role ?? GalleryRole.viewer,)
          ],
        ),
      ),
    );
  }
}


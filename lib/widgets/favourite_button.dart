import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';

class FavouriteButton extends StatelessWidget {
  final int photoId;

  const FavouriteButton({
    super.key,
    required this.photoId,
  });

  Future<void> _toggleFavourite(
      BuildContext context,
      ) async {
    final photoProvider = context.read<PhotoProvider>();

    final success = await photoProvider.toggleFavourite(
      photoId,
    );

    // The UI changes immediately because the provider
    // performs an optimistic update.
    //
    // If the API fails, the provider restores the old
    // state and returns false.
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Couldn\'t update favourite. Please check your connection and try again.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to PhotoProvider so this button automatically
    // rebuilds whenever the favourite state changes.
    final photoProvider = context.watch<PhotoProvider>();

    // Find the latest version of this photo from the provider.
    final photoIndex = photoProvider.photos.indexWhere(
          (photo) => photo.id == photoId,
    );

    // If the photo is not currently available in the provider,
    // don't show the button.
    if (photoIndex == -1) {
      return const SizedBox.shrink();
    }

    final isFavourite =
        photoProvider.photos[photoIndex].isFavourite;

    return IconButton(
      onPressed: () {
        _toggleFavourite(context);
      },
      icon: Icon(
        isFavourite
            ? Icons.favorite
            : Icons.favorite_border,
      ),
      color: isFavourite
          ? Colors.red
          : Colors.white,
      tooltip: isFavourite
          ? 'Remove favourite'
          : 'Add favourite',
    );
  }
}
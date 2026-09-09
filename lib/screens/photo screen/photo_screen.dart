import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/screens/photo%20screen/components/photo_grid_item.dart';

class PhotoScreen extends StatefulWidget {
  final Event event;

  const PhotoScreen({
    super.key,
    required this.event,
  });

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoProvider>().fetchAllPhotosOfEvent(
        widget.event.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
      ),

      body: Consumer<PhotoProvider>(
        builder: (context, provider, child) {
          // -------------------------------------------------
          // LOADING
          // -------------------------------------------------

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // -------------------------------------------------
          // ERROR
          // -------------------------------------------------

          if (provider.error != null) {
            return _PhotoErrorState(
              message: provider.error!,
            );
          }

          // -------------------------------------------------
          // EMPTY
          // -------------------------------------------------

          if (provider.photos.isEmpty) {
            return const _EmptyPhotoState();
          }

          // -------------------------------------------------
          // PHOTO GRID
          // -------------------------------------------------

          final photos = provider.photos;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              // Change the number of columns based on
              // the available screen width.
              int crossAxisCount;

              if (width < 600) {
                crossAxisCount = 3;
              } else if (width < 1000) {
                crossAxisCount = 5;
              } else {
                crossAxisCount = 7;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),

                physics: const BouncingScrollPhysics(),

                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),

                itemCount: photos.length,

                itemBuilder: (context, index) {
                  final photo = photos[index];

                  return PhotoGridItem(
                    photo: photo,
                    index: index,
                    photos: photos,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


// ---------------------------------------------------------
// EMPTY PHOTO STATE
// ---------------------------------------------------------

class _EmptyPhotoState extends StatelessWidget {
  const _EmptyPhotoState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          const Text(
            'No photos found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Photos for this event will appear here.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------
// ERROR PHOTO STATE
// ---------------------------------------------------------

class _PhotoErrorState extends StatelessWidget {
  final String message;

  const _PhotoErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
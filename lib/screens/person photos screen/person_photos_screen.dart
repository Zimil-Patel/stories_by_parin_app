import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stories_by_parin/providers/person_photo_provider.dart';
import 'package:stories_by_parin/screens/photo%20screen/components/photo_grid_item.dart';

import '../../utils/images.dart';

class PersonPhotoScreen extends StatefulWidget {
  final int projectId;
  final int faceId;

  const PersonPhotoScreen({
    super.key,
    required this.projectId,
    required this.faceId,
  });

  @override
  State<PersonPhotoScreen> createState() =>
      _PersonPhotoScreenState();
}

class _PersonPhotoScreenState extends State<PersonPhotoScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonPhotoProvider>().fetchPhotosOfFaces(
        widget.projectId,
        widget.faceId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 8.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              title: Text('Person Photos'),
              backgroundColor: Colors.white24,
            ),
          ),
        ),
      ),

      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
        ),
        child: Consumer<PersonPhotoProvider>(
          builder: (context, provider, child) {
            // -------------------------------------------------
            // LOADING STATE
            // -------------------------------------------------

            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // -------------------------------------------------
            // ERROR STATE
            // -------------------------------------------------

            if (provider.error != null) {
              return _PersonPhotoErrorState(
                message: provider.error!,
              );
            }

            // -------------------------------------------------
            // EMPTY STATE
            // -------------------------------------------------

            if (provider.photos.isEmpty) {
              return const _PersonPhotoEmptyState();
            }

            final photos = provider.photos;

            // -------------------------------------------------
            // PHOTO GRID
            // -------------------------------------------------

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int crossAxisCount;

                if (width < 600) {
                  crossAxisCount = 3;
                } else if (width < 1000) {
                  crossAxisCount = 5;
                } else {
                  crossAxisCount = 7;
                }

                return GridView.builder(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight - 48, // Status bar + AppBar height + margin
                    left: 8,
                    right: 8,
                    bottom: 16,
                  ),

                  physics: AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}

// -------------------------------------------------
// EMPTY STATE
// -------------------------------------------------

class _PersonPhotoEmptyState extends StatelessWidget {
  const _PersonPhotoEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_outlined,
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
            'No photos containing this person were found.',
            textAlign: TextAlign.center,
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

// -------------------------------------------------
// ERROR STATE
// -------------------------------------------------

class _PersonPhotoErrorState extends StatelessWidget {
  final String message;

  const _PersonPhotoErrorState({
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
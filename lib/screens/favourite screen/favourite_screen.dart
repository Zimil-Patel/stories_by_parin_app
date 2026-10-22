
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';
import 'package:stories_by_parin/widgets/photo_grid_item.dart';

class FavouritesScreen extends StatefulWidget {
  final Project project;

  const FavouritesScreen({
    super.key,
    required this.project,
  });

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<PhotoProvider>()
          .fetchProjectFavouritePhotos(widget.project.id);
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
            filter: ImageFilter.blur(
              sigmaX: 50,
              sigmaY: 8,
            ),
            child: AppBar(
              title: const Text('Favourites'),
              backgroundColor: Colors.white24,
              actions: [
                Consumer<PhotoProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      tooltip: provider.newestFirst
                          ? 'Newest first'
                          : 'Oldest first',
                      onPressed: () {
                        provider.toggleSortOrder();
                      },
                      icon: Icon(
                        provider.newestFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: Consumer<PhotoProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingFavourites) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.favouritesError != null) {
              return _FavouritesMessage(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load favourites',
                message: provider.favouritesError!,
                onRetry: () {
                  provider.fetchProjectFavouritePhotos(
                    widget.project.id,
                  );
                },
              );
            }

            final photos = provider.favouritePhotos;

            if (photos.isEmpty) {
              return RefreshIndicator(
                onRefresh: () {
                  return provider.fetchProjectFavouritePhotos(
                    widget.project.id,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight -
                        48,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favourite photos yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Photos you mark as favourite will appear here.',
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final crossAxisCount = width < 600
                    ? 3
                    : width < 1000
                    ? 5
                    : 7;

                return RefreshIndicator(
                  onRefresh: () {
                    return provider.fetchProjectFavouritePhotos(
                      widget.project.id,
                    );
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight -
                          48,
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        key: ValueKey(photo.id),
                        project: widget.project,
                        photo: photo,
                        index: index,
                        photos: photos,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavouritesMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _FavouritesMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
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
              icon,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

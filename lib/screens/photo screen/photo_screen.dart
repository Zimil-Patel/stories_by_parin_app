import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:stories_by_parin/models/event_model.dart';
import 'package:stories_by_parin/providers/photo_provider.dart';
import 'package:stories_by_parin/screens/photo%20screen/components/photo_grid_item.dart';

import '../../utils/images.dart';

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

  Timer? _refreshTimer;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoProvider>().fetchAllPhotosOfEvent(
        widget.event.id,
      );

      // _startAutoRefresh();
    });
  }
  // Start auto fetching new photos
  // void _startAutoRefresh(){
  //   _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
  //     if(!mounted){
  //       return;
  //     }
  //
  //     context.read<PhotoProvider>().refreshPhotoSilently(widget.event.id);
  //   },);
  // }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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
              title: Text(widget.event.name),
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

      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
        ),
        child: Consumer<PhotoProvider>(
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

                return RefreshIndicator(
                  onRefresh: () {
                    return context.read<PhotoProvider>().fetchAllPhotosOfEvent(
                      widget.event.id,
                    );
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight - 48, // Status bar + AppBar height + margin
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
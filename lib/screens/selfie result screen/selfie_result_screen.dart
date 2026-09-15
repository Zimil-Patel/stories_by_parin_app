import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/widgets/app_background.dart';
import 'package:stories_by_parin/widgets/photo_grid_item.dart';

import '../../utils/images.dart';

class SelfieResultScreen extends StatelessWidget {
  final List<Photo> photos;

  const SelfieResultScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      body: AppBackground(
        child: photos.isEmpty
            ? const Center(child: Text('No photos found.'))
            : GridView.builder(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight - 48,
                  // Status bar + AppBar height + margin
                  left: 8,

                  right: 8,
                  bottom: 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return PhotoGridItem(
                    photo: photos[index],
                    index: index,
                    photos: photos,
                  );
                },
              ),
      ),
    );
  }
}

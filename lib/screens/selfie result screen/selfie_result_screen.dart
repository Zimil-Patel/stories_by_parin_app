import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/photo_model.dart';
import 'package:stories_by_parin/screens/photo%20screen/components/photo_grid_item.dart';

class SelfieResultScreen extends StatelessWidget {
  final List<Photo> photos;

  const SelfieResultScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('photos')),

      body: photos.isEmpty
          ? const Center(child: Text('No photos found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/person_photo_provider.dart';
import 'package:stories_by_parin/screens/photo%20screen/components/photo_grid_item.dart';

class PersonPhotoScreen extends StatefulWidget {
  final int projectId;
  final int faceId;

  const PersonPhotoScreen({
    super.key,
    required this.projectId,
    required this.faceId,
  });

  @override
  State<PersonPhotoScreen> createState() => _PersonPhotoScreenState();
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
      appBar: AppBar(title: Text('photos')),

      body: Consumer<PersonPhotoProvider>(
        builder: (context, provider, child) {
          /// if photos are loading show loader
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          /// if there is any error show error
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          /// show all photos if no photos then show message
          if (provider.photos.isEmpty) {
            return Center(child: Text("No photos found"));
          }

          final photos = provider.photos;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];

              return PhotoGridItem(photo: photo, index: index, photos: photos,);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stories_by_parin/models/project_model.dart';

import '../screens/gallery sharing screen/gallery_sharing_screen.dart';

class GallerySharingAppBarAction extends StatelessWidget {
  final Project project;

  const GallerySharingAppBarAction({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    if (!project.isOwner) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Gallery sharing',
      icon: const Icon(Icons.share_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GallerySharingScreen(
              project: project,
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import '../screens/request gallery access screen/request_gallery_access_screen.dart';

class RequestGalleryAccessAppBarAction extends StatelessWidget {
  const RequestGalleryAccessAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Request gallery access',
      icon: const Icon(Icons.key_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const RequestGalleryAccessScreen(),
          ),
        );
      },
    );
  }
}
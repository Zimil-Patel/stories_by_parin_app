import 'package:flutter/material.dart';

import 'selfie_capture_button.dart';

class SelfieBottomControls extends StatelessWidget {
  final VoidCallback? onGallery;
  final VoidCallback? onCapture;

  const SelfieBottomControls({
    super.key,
    required this.onGallery,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              SelfieCaptureButton(onTap: onCapture),

              // Keeps the capture button centered.
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

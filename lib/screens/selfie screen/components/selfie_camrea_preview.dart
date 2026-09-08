import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SelfieCameraPreview extends StatelessWidget {
  final CameraController? controller;
  final bool isReady;

  const SelfieCameraPreview({
    super.key,
    required this.controller,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isReady || controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(child: CameraPreview(controller!));
  }
}

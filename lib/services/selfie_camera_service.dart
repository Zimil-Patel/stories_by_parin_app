import 'package:camera/camera.dart';

class SelfieCameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get isReady => _controller != null && _controller!.value.isInitialized;

  /// Initializes the front camera when available.
  Future<void> initialize() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw Exception('No camera available');
    }

    CameraDescription selectedCamera = cameras.first;

    // Prefer the front-facing camera for selfies.
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        selectedCamera = camera;
        break;
      }
    }

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  /// Switches between front and rear cameras.
  Future<void> switchCamera() async {
    final currentController = _controller;

    if (currentController == null) return;

    final cameras = await availableCameras();

    if (cameras.length < 2) return;

    final currentDirection = currentController.description.lensDirection;

    final newCamera = cameras.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => cameras.first,
    );

    await currentController.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  /// Captures a photo from the current camera.
  Future<XFile> takePicture() async {
    if (!isReady) {
      throw Exception('Camera is not ready');
    }

    return _controller!.takePicture();
  }

  /// Releases the camera.
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

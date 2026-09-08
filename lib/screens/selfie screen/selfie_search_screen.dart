import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

import '../../services/selfie_camera_service.dart';
import 'components/selfie_bottom_control.dart';
import 'components/selfie_camrea_preview.dart';
import 'components/selfie_face_guide.dart';
import 'components/selfie_loading_overlay.dart';
import 'components/selfie_top_bar.dart';


class SelfieSearchScreen extends StatefulWidget {
  const SelfieSearchScreen({super.key});

  @override
  State<SelfieSearchScreen> createState() => _SelfieSearchScreenState();
}

class _SelfieSearchScreenState extends State<SelfieSearchScreen> {
  final SelfieCameraService _cameraService = SelfieCameraService();

  final ImagePicker _imagePicker = ImagePicker();

  bool _isCameraReady = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_isProcessing) return;

    setState(() {
      _isCameraReady = false;
    });

    try {
      await _cameraService.switchCamera();

      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera switch failed: $e');

      if (!mounted) return;

      setState(() {
        _isCameraReady = false;
      });
    }
  }

  Future<void> _captureSelfie() async {
    if (_isProcessing || !_isCameraReady) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraService.takePicture();

      if (!mounted) return;

      Navigator.pop(context, File(image.path));
    } catch (e) {
      debugPrint('Capture failed: $e');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showMessage('Unable to capture the photo. Please try again.');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        _stopProcessing();
        return;
      }

      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Selfie',
            lockAspectRatio: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Selfie',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
          ),
        ],
      );

      if (croppedImage == null) {
        _stopProcessing();
        return;
      }

      if (!mounted) return;

      Navigator.pop(context, File(croppedImage.path));
    } catch (e) {
      debugPrint('Gallery selection failed: $e');

      if (!mounted) return;

      _stopProcessing();

      _showMessage('Unable to select this photo. Please try again.');
    }
  }

  void _stopProcessing() {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _cameraService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SelfieCameraPreview(
            controller: _cameraService.controller,
            isReady: _isCameraReady,
          ),

          const SelfieFaceGuide(),

          SelfieTopBar(
            onClose: _isProcessing ? null : () => Navigator.pop(context),
            onSwitchCamera: _isProcessing ? null : _switchCamera,
          ),

          SelfieBottomControls(
            onGallery: _isProcessing ? null : _pickFromGallery,
            onCapture: _isProcessing ? null : _captureSelfie,
          ),

          if (_isProcessing) const SelfieLoadingOverlay(),
        ],
      ),
    );
  }
}

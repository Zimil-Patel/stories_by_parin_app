import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/profile_provider.dart';


class ProfilePhotoEditor extends StatefulWidget {
  final String? photoUrl;
  final double size;

  const ProfilePhotoEditor({
    super.key,
    required this.photoUrl,
    this.size = 100,
  });

  @override
  State<ProfilePhotoEditor> createState() =>
      _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  /// Pick a photo, crop it to a square, then upload it.
  Future<void> _changePhoto() async {
    if (_isUploading) return;

    try {
      // Open the device's image picker.
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      // The user cancelled the picker.
      if (pickedImage == null) return;

      // Let the user position and crop the photo.
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        maxWidth: 512,
        maxHeight: 512,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop profile photo',
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Crop profile photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );

      // The user cancelled the crop screen.
      if (croppedImage == null) return;

      // Read only the cropped image rather than uploading the
      // original, potentially very large iPhone photograph.
      final imageBytes = await croppedImage.readAsBytes();

      if (!mounted) return;

      // Upload and synchronize the profile through ProfileProvider.
      final profileProvider = context.read<ProfileProvider>();

      setState(() {
        _isUploading = true;
      });


      final success =
      await profileProvider.uploadProfilePhoto(imageBytes);

      if (!mounted) return;

      // Show feedback after the upload completes.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile photo updated successfully.'
                : profileProvider.error ??
                'Unable to update profile photo.',
          ),
        ),
      );
    } catch (error) {
      debugPrint('Could not change profile photo: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not select or upload the photo. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Display the existing photo or a default avatar.
          Positioned.fill(
            child: ClipOval(
              child: widget.photoUrl != null &&
                  widget.photoUrl!.trim().isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: widget.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return const _DefaultAvatar();
                },
                errorWidget: (context, url, error) {
                  return const _DefaultAvatar();
                },
              )
                  : const _DefaultAvatar(),
            ),
          ),

          // Show a camera button to edit the profile photo.
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isUploading ? null : _changePhoto,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),

          // Cover the avatar while the upload operation is running.
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fallback avatar for users without a photo or while loading.
class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: Icon(
          Icons.person,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
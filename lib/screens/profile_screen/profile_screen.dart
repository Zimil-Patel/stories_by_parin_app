import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_background.dart';
import 'components/profile_photo_editor.dart';
import 'components/sign_out_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Open the edit form and show feedback after it closes.
  Future<void> _openEditProfile(
      BuildContext context, {
        required String firstName,
        required String lastName,
      }) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(
        firstName: firstName,
        lastName: lastName,
      ),
    );

    if (!context.mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the user's application profile from ProfileProvider.
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    // Firebase remains the source for the signed-in email.
    final email = context.watch<AuthProvider>().user?.email;

    final photoUrl = profile?.photoUrl;
    final fullName = profile?.fullName.trim();

    return Scaffold(
      extendBodyBehindAppBar: true,

      // Keep your preferred translucent, blurred AppBar.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 50,
              sigmaY: 8,
            ),
            child: AppBar(
              title: const Text('My Profile'),
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
      ),

      body: AppBackground(
        child: SafeArea(
          child: profileProvider.isInitializing
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo, name, and email.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfilePhotoEditor(
                      photoUrl: photoUrl,
                      size: 100,
                    ),

                    const SizedBox(width: 18),

                    // Expanded prevents long names and emails
                    // from overflowing the available width.
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName != null &&
                                fullName.isNotEmpty
                                ? fullName
                                : 'Your Name',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            email ?? 'No email available',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Open the edit form with the current local names.
                OutlinedButton.icon(
                  onPressed: profile == null
                      ? null
                      : () => _openEditProfile(
                    context,
                    firstName: profile.firstName,
                    lastName: profile.lastName,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit profile'),
                ),

                const SizedBox(height: 28),

                // Show the loading error only when no profile
                // could be loaded. Save errors appear in the
                // edit dialog instead.
                if (profileProvider.error != null &&
                    profile == null) ...[
                  Text(
                    'Unable to load your profile.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: profileProvider.isLoading
                        ? null
                        : () => profileProvider.refreshProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],

                const SizedBox(height: 32),

                // Sign out remains at the bottom of the content.
                const SignOutTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog containing the first-name and last-name fields.
class _EditProfileDialog extends StatefulWidget {
  final String firstName;
  final String lastName;

  const _EditProfileDialog({
    required this.firstName,
    required this.lastName,
  });

  @override
  State<_EditProfileDialog> createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  // Controllers retain the user's edits while the dialog rebuilds.
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  // Used to validate the form before saving.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Start with the names currently stored in the profile.
    _firstNameController = TextEditingController(
      text: widget.firstName,
    );

    _lastNameController = TextEditingController(
      text: widget.lastName,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Save the updated name through ProfileProvider.
  Future<void> _saveChanges() async {
    // Validate the entered first name before making an API request.
    if (!_formKey.currentState!.validate()) return;

    // Prevent another submission while an update is running.
    final profileProvider = context.read<ProfileProvider>();

    if (profileProvider.isUpdatingProfile) return;

    final success = await profileProvider.updateProfileName(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (!mounted) return;

    // Close the dialog only when the profile update succeeds.
    // Errors remain visible in the dialog for the user to address.
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for save/loading/error updates from the provider.
    final profileProvider = context.watch<ProfileProvider>();
    final isSaving = profileProvider.isUpdatingProfile;

    return AlertDialog(
      title: const Text('Edit profile'),

      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First name is required.
              TextFormField(
                controller: _firstNameController,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Last name is optional.
              TextFormField(
                controller: _lastNameController,
                enabled: !isSaving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!isSaving) {
                    _saveChanges();
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              // Display an error if saving fails.
              if (profileProvider.error != null) ...[
                const SizedBox(height: 12),

                Text(
                  profileProvider.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: isSaving ? null : _saveChanges,
          child: isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Text('Save changes'),
        ),
      ],
    );
  }
}

/// Default avatar used while loading or when no photo URL is available.
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: Icon(
          Icons.person,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
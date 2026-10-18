import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../screens/profile_screen/profile_screen.dart';

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Read only the photo URL so unrelated profile changes
    // don't unnecessarily rebuild this widget.
    final photoUrl = context.select<ProfileProvider, String?>(
          (provider) => provider.profile?.photoUrl,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // Open the user's profile screen.
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ProfileScreen(),
            ),
          );
        },
        child: SizedBox(
          width: 42,
          height: 42,
          child: ClipOval(
            child: photoUrl != null && photoUrl.trim().isNotEmpty
                ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return const _DefaultProfileAvatar();
              },
              errorWidget: (context, url, error) {
                return const _DefaultProfileAvatar();
              },
            )
                : const _DefaultProfileAvatar(),
          ),
        ),
      ),
    );
  }
}

class _DefaultProfileAvatar extends StatelessWidget {
  const _DefaultProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: Icon(
          Icons.person,
          size: 26,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
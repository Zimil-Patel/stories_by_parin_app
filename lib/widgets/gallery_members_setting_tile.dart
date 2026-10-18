import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../screens/gallery members screen/gallery_members_screen.dart';


class GalleryMembersAppBarAction extends StatelessWidget {
  final Project project;

  const GalleryMembersAppBarAction({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    // Show this action only when the user's role is explicitly Owner.
    if (project.role != GalleryRole.owner) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Gallery members',
      icon: const Icon(Icons.people_alt_outlined),
      onPressed: () {
        // Pass the same Project object to the members screen.
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GalleryMembersScreen(
              project: project,
            ),
          ),
        );
      },
    );
  }
}

class GalleryMembersSettingsTile extends StatelessWidget {
  final Project project;

  const GalleryMembersSettingsTile({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    // Only Owners should see the gallery member-management action.
    // A null role is also treated as having no management permission.
    if (project.role != GalleryRole.owner) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),

        // Leading settings icon.
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_alt_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),

        // Tile title.
        title: const Text(
          'Gallery members',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        // Tile description.
        subtitle: const Text(
          'Manage members and invitations',
        ),

        // Indicates that the tile opens another screen.
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),

        // ListTile provides the click feedback across the entire tile.
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GalleryMembersScreen(
                project: project,
              ),
            ),
          );
        },
      ),
    );
  }
}
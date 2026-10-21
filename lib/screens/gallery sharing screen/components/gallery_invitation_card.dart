
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

class GalleryInvitationCard extends StatelessWidget {
  final int projectId;
  final Map<String, dynamic> invitation;

  const GalleryInvitationCard({
    super.key,
    required this.projectId,
    required this.invitation,
  });

  Future<void> _revoke(BuildContext context) async {
    final rawId = invitation['id'];
    final invitationId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    if (invitationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify this invitation.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke invitation?'),
        content: const Text(
          'Are you sure you want to revoke this invitation?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<GallerySharingProvider>();

    final success = await provider.revokeInvitation(
      projectId: projectId,
      invitationId: invitationId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Invitation revoked.'
              : provider.error ?? 'Could not revoke invitation.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = invitation['email'] ??
        invitation['invitee_email'] ??
        'Unknown email';

    final role = invitation['role'] ?? 'viewer';
    final status = invitation['status'] ?? 'pending';

    final provider = context.watch<GallerySharingProvider>();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.mail_outline),
        ),
        title: Text(email.toString()),
        subtitle: Text(
          'Role: $role\nStatus: $status',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Revoke invitation',
          onPressed: provider.isPerformingAction
              ? null
              : () => _revoke(context),
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

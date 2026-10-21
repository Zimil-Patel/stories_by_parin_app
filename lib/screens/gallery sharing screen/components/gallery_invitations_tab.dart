
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

import 'gallery_invitation_card.dart';
import 'invite_by_email_form.dart';

class GalleryInvitationsTab extends StatelessWidget {
  final int projectId;

  const GalleryInvitationsTab({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GallerySharingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingInvitations) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null &&
            provider.invitations.isEmpty) {
          return _InvitationMessage(
            message: provider.error!,
            onRetry: () => provider.fetchInvitations(projectId),
          );
        }

        if (provider.invitations.isEmpty) {
          return const _InvitationMessage(
            message: 'No invitations yet.',
          );
        }


        return RefreshIndicator(
          onRefresh: () => provider.fetchInvitations(projectId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              InviteByEmailForm(projectId: projectId),
              const SizedBox(height: 16),
              if (provider.invitations.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No invitations yet.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...provider.invitations.map(
                      (invitation) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GalleryInvitationCard(
                      key: ValueKey(invitation['id']),
                      projectId: projectId,
                      invitation: invitation,
                    ),
                  ),
                ),
            ],
          ),
        );

      },
    );
  }
}

class _InvitationMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InvitationMessage({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

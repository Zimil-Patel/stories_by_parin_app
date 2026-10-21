
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

import 'access_request_card.dart';

class AccessRequestsTab extends StatelessWidget {
  final int projectId;

  const AccessRequestsTab({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GallerySharingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingAccessRequests) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null &&
            provider.accessRequests.isEmpty) {
          return _RequestMessage(
            message: provider.error!,
            onRetry: () => provider.fetchAccessRequests(
              projectId: projectId,
              status: 'pending',
            ),
          );
        }

        if (provider.accessRequests.isEmpty) {
          return const _RequestMessage(
            message: 'No pending access requests.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAccessRequests(
            projectId: projectId,
            status: 'pending',
          ),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: provider.accessRequests.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final request = provider.accessRequests[index];

              final requester = request['email'] ??
                  request['user_email'] ??
                  request['user_id'] ??
                  'Unknown user';

              return AccessRequestCard(
                key: ValueKey(request['id']),
                projectId: projectId,
                request: request,
              );
            },
          ),
        );
      },
    );
  }
}

class _RequestMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _RequestMessage({
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
            const Icon(Icons.pending_actions, size: 42),
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

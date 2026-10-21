
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';
import 'package:stories_by_parin/screens/gallery%20sharing%20screen/components/share_link_card.dart';

import 'create_share_link_form.dart';

class ShareLinksTab extends StatelessWidget {
  final int projectId;

  const ShareLinksTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GallerySharingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingShareLinks) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null &&
            provider.shareLinks.isEmpty) {
          return _MessageView(
            message: provider.error!,
            onRetry: () =>
                provider.fetchShareLinks(projectId),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              provider.fetchShareLinks(projectId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            children: [
              CreateShareLinkForm(
                projectId: projectId,
              ),
              const SizedBox(height: 16),
              if (provider.shareLinks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.link_off,
                        size: 36,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No share links yet. Create one above.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...provider.shareLinks.map(
                      (link) => ShareLinkCard(
                    key: ValueKey(link['id']),
                    projectId: projectId,
                    link: link,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _MessageView({
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
            const Icon(Icons.info_outline, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
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

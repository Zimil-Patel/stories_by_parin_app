
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

class ShareLinkCard extends StatelessWidget {
  final int projectId;
  final Map<String, dynamic> link;

  const ShareLinkCard({
    super.key,
    required this.projectId,
    required this.link,
  });

  Future<void> _copyToken(BuildContext context) async {
    final token = link['token']?.toString();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This record has no share token.'),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: token));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share token copied.'),
      ),
    );
  }

  Future<void> _revoke(BuildContext context) async {
    final rawId = link['id'];
    final linkId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    if (linkId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify this share link.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke share link?'),
        content: const Text(
          'People will no longer be able to submit new access '
              'requests using this link. Existing requests and '
              'gallery memberships will remain unchanged.',
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

    final success = await provider.revokeShareLink(
      projectId: projectId,
      shareLinkId: linkId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Share link revoked.'
              : provider.error ?? 'Could not revoke share link.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiry = link['expires_at_utc'] ??
        link['expires_at'] ??
        'Unknown';

    final token = link['token']?.toString();
    final isRevoked = link['revoked_at_utc'] != null &&
        link['revoked_at_utc'].toString().isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    isRevoked ? Icons.link_off : Icons.link,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share link ${link['id'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isRevoked)
                  const Chip(
                    label: Text('Revoked'),
                    avatar: Icon(Icons.block, size: 16),
                  )
                else
                  IconButton(
                    tooltip: 'Revoke link',
                    onPressed: () => _revoke(context),
                    icon: const Icon(
                      Icons.link_off,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Expires: $expiry'),
            if (token != null && token.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(
                'Token: $token',
                maxLines: 2,
              ),
              if (!isRevoked)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _copyToken(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy token'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

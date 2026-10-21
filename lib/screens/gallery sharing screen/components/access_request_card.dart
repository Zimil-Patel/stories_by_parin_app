
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

class AccessRequestCard extends StatelessWidget {
  final int projectId;
  final Map<String, dynamic> request;

  const AccessRequestCard({
    super.key,
    required this.projectId,
    required this.request,
  });

  Future<void> _decide(
      BuildContext context, {
        required bool approve,
      }) async {
    final rawId = request['id'];
    final requestId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify this access request.'),
        ),
      );
      return;
    }

    final action = approve ? 'Approve' : 'Reject';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$action access request?'),
        content: Text(
          approve
              ? 'Approve this request? The requester will receive gallery access.'
              : 'Reject this request? The requester will not receive gallery access.',
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
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<GallerySharingProvider>();

    final success = await provider.resolveAccessRequest(
      projectId: projectId,
      requestId: requestId,
      approve: approve,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? approve
              ? 'Access request approved.'
              : 'Access request rejected.'
              : provider.error ?? 'Could not process the request.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requester = request['email'] ??
        request['user_email'] ??
        request['user_id'] ??
        'Unknown requester';

    final createdAt = request['created_at'] ??
        request['requested_at'];

    final provider = context.watch<GallerySharingProvider>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    requester.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Chip(label: Text('Pending')),
              ],
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text('Requested: $createdAt'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.isPerformingAction
                        ? null
                        : () => _decide(
                      context,
                      approve: false,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: provider.isPerformingAction
                        ? null
                        : () => _decide(
                      context,
                      approve: true,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

class CreateShareLinkForm extends StatefulWidget {
  final int projectId;

  const CreateShareLinkForm({
    super.key,
    required this.projectId,
  });

  @override
  State<CreateShareLinkForm> createState() =>
      _CreateShareLinkFormState();
}

class _CreateShareLinkFormState extends State<CreateShareLinkForm> {
  DateTime? _expiresAt;

  Future<void> _selectExpiry() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _expiresAt ?? now.add(const Duration(days: 7)),
      ),
    );

    if (time == null || !mounted) return;

    final expiry = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!expiry.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry must be in the future.'),
        ),
      );
      return;
    }

    setState(() => _expiresAt = expiry);
  }

  Future<void> _createLink() async {
    final expiry = _expiresAt;

    if (expiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an expiry date and time first.'),
        ),
      );
      return;
    }

    final provider = context.read<GallerySharingProvider>();

    final success = await provider.createShareLink(
      projectId: widget.projectId,
      expiresAt: expiry,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Share link created.'
              : provider.error ?? 'Could not create share link.',
        ),
      ),
    );

    if (success) {
      setState(() => _expiresAt = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GallerySharingProvider>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a share link',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anyone with this link can request access. '
                  'They will not receive gallery access until an Owner approves.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: provider.isPerformingAction
                  ? null
                  : _selectExpiry,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _expiresAt == null
                    ? 'Choose expiry date and time'
                    : 'Expires: ${MaterialLocalizations.of(context).formatMediumDate(_expiresAt!)} '
                    '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_expiresAt!))}',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isPerformingAction
                    ? null
                    : _createLink,
                icon: provider.isPerformingAction
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.add_link),
                label: const Text('Create share link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

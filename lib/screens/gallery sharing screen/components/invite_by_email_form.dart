
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';

class InviteByEmailForm extends StatefulWidget {
  final int projectId;

  const InviteByEmailForm({
    super.key,
    required this.projectId,
  });

  @override
  State<InviteByEmailForm> createState() =>
      _InviteByEmailFormState();
}

class _InviteByEmailFormState extends State<InviteByEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String _role = 'viewer';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GallerySharingProvider>();

    final success = await provider.inviteByEmail(
      projectId: widget.projectId,
      email: _emailController.text.trim(),
      role: _role,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Invitation created.'
              : provider.error ?? 'Could not send invitation.',
        ),
      ),
    );

    if (success) {
      _emailController.clear();
      setState(() => _role = 'viewer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GallerySharingProvider>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invite by email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Invite an existing user or create a pending invitation '
                    'for someone who has not registered yet.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'person@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Enter an email address.';
                  }

                  final emailPattern =
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                  if (!emailPattern.hasMatch(email)) {
                    return 'Enter a valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Gallery role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'viewer',
                    child: Text('Viewer — view gallery photos'),
                  ),
                  DropdownMenuItem(
                    value: 'owner',
                    child: Text('Owner — manage gallery sharing'),
                  ),
                ],
                onChanged: provider.isPerformingAction
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() => _role = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: provider.isPerformingAction
                      ? null
                      : _sendInvitation,
                  icon: provider.isPerformingAction
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.person_add_alt_1),
                  label: const Text('Create invitation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

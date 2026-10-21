import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

class RequestGalleryAccessScreen extends StatefulWidget {
  const RequestGalleryAccessScreen({super.key});

  @override
  State<RequestGalleryAccessScreen> createState() =>
      _RequestGalleryAccessScreenState();
}

class _RequestGalleryAccessScreenState
    extends State<RequestGalleryAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GallerySharingProvider>();
    provider.clearError();

    final result = await provider.requestAccess(
      _tokenController.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      _tokenController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access request submitted. The gallery owner must approve it.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Unable to submit the access request.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Request Gallery Access'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<GallerySharingProvider>(
          builder: (context, provider, child) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'View a shared gallery',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter the share token you received. '
                              'The gallery owner must approve your request '
                              'before you can access the gallery.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _tokenController,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Share token',
                            hintText: 'Paste your share token',
                            prefixIcon: Icon(Icons.key_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a share token.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submitRequest(),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: provider.isPerformingAction
                              ? null
                              : _submitRequest,
                          icon: provider.isPerformingAction
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.send_outlined),
                          label: Text(
                            provider.isPerformingAction
                                ? 'Submitting...'
                                : 'Request access',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Submitting a request does not grant access '
                              'automatically.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class SignOutTile extends StatefulWidget {
  const SignOutTile({super.key});

  @override
  State<SignOutTile> createState() => _SignOutTileState();
}

class _SignOutTileState extends State<SignOutTile> {
  bool _isSigningOut = false;

  /// Ask the user to confirm before signing out.
  Future<bool> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            // Close the dialog without signing out.
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),

            // Confirm the sign-out action.
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  /// Sign out only after the user confirms.
  Future<void> _handleSignOut() async {
    if (_isSigningOut) return;

    // Show the confirmation dialog first.
    final confirmed = await _confirmSignOut();

    if (!mounted || !confirmed) return;

    setState(() {
      _isSigningOut = true;
    });

    final authProvider = context.read<AuthProvider>();

    // Perform the existing Firebase sign-out operation.
    await authProvider.signOutUser();

    if (!mounted) return;

    // AuthProvider stores an error if sign-out fails.
    final error = authProvider.error;

    if (error != null) {
      setState(() {
        _isSigningOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    // Return to the root AuthGate.
    // AuthGate will display LoginScreen after sign-out.
    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signOutColor = theme.colorScheme.error;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        // Sign-out icon on the left.
        leading: Icon(
          Icons.logout_rounded,
          color: signOutColor,
        ),

        // Text beside the icon.
        title: Text(
          _isSigningOut ? 'Signing out...' : 'Sign out',
          style: theme.textTheme.titleMedium?.copyWith(
            color: signOutColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Show progress while the operation is running.
        trailing: _isSigningOut
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: signOutColor,
          ),
        )
            : Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),

        // The entire tile remains clickable with ripple feedback.
        onTap: _isSigningOut ? null : _handleSignOut,
      ),
    );
  }
}
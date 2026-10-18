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

  Future<void> _handleSignOut() async {
    // Prevent repeated taps while sign-out is processing.
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    // Use the existing authentication provider.
    final authProvider = context.read<AuthProvider>();

    await authProvider.signOutUser();

    if (!mounted) return;

    // AuthProvider stores an error if sign-out fails.
    final error = authProvider.error;

    if (error != null) {
      setState(() {
        _isSigningOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );

      return;
    }

    // Return to the root route. AuthGate will show LoginScreen
    // because the Firebase session has ended.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signOutColor = theme.colorScheme.error;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        // Leading icon on the left.
        leading: Icon(
          Icons.logout_rounded,
          color: signOutColor,
        ),

        // Sign-out text beside the icon.
        title: Text(
          _isSigningOut ? 'Signing out...' : 'Sign out',
          style: theme.textTheme.titleMedium?.copyWith(
            color: signOutColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Show a progress indicator while signing out.
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

        // The whole tile is clickable and displays a ripple effect.
        onTap: _isSigningOut ? null : _handleSignOut,
      ),
    );
  }
}
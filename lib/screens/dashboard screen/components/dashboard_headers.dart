import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String firstName;

  const DashboardHeader({
    super.key,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 4),

        Text(
          firstName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
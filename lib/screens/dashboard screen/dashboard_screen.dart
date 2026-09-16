import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/auth_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../project screen/project_screen.dart';
import 'components/dashboard_action_card.dart';
import 'components/dashboard_headers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().localUser;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 50.0,
              sigmaY: 8.0,
            ),
            child: AppBar(
              scrolledUnderElevation: 0,
              title: const Text('Dashboard'),
              backgroundColor: Colors.white24,

              actions: [
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () {
                    context.read<AuthProvider>().signOutUser();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
          ),
        ),
      ),

      body: AppBackground(
        child: SafeArea(
          child: user == null
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  firstName: user.firstName,
                ),

                const SizedBox(height: 30),

                DashboardActionCard(
                  title: 'Projects',
                  subtitle: 'Manage your photography shoots',
                  icon: Icons.photo_library_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectScreen(),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
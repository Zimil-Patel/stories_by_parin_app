import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/auth_provider.dart';
import 'package:stories_by_parin/providers/profile_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../../services/request_gallery_access_app_bar_action.dart';
import '../../widgets/profile_avatar_button.dart';
import '../project screen/project_screen.dart';
import 'components/dashboard_action_card.dart';
import 'components/dashboard_headers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

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
                ProfileAvatarButton(),
              ],
            ),
          ),
        ),
      ),

      body: AppBackground(
        child: SafeArea(
          child: profile == null
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  firstName: profile.firstName,
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

                const RequestGalleryAccessAppBarAction(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/models/project_model.dart';
import 'package:stories_by_parin/providers/gallery_sharing_provider.dart';
import 'package:stories_by_parin/screens/gallery%20sharing%20screen/components/access_request_tab.dart';
import 'package:stories_by_parin/screens/gallery%20sharing%20screen/components/share_link_tab.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import 'components/gallery_invitations_tab.dart';

class GallerySharingScreen extends StatefulWidget {
  final Project project;

  const GallerySharingScreen({
    super.key,
    required this.project,
  });

  @override
  State<GallerySharingScreen> createState() =>
      _GallerySharingScreenState();
}

class _GallerySharingScreenState
    extends State<GallerySharingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<GallerySharingProvider>();

      provider.fetchShareLinks(widget.project.id);
      provider.fetchAccessRequests(
        projectId: widget.project.id,
        status: 'pending',
      );
      provider.fetchInvitations(widget.project.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.project.isOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gallery Sharing')),
        body: const Center(
          child: Text(
            'Only gallery Owners can manage sharing.',
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(112),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 8,
            ),
            child: AppBar(
              backgroundColor: Colors.white24,
              scrolledUnderElevation: 0,
              title: const Text('Gallery Sharing'),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.link),
                    text: 'Share Links',
                  ),
                  Tab(
                    icon: Icon(Icons.pending_actions),
                    text: 'Requests',
                  ),
                  Tab(
                    icon: Icon(Icons.mail_outline),
                    text: 'Invitations',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              ShareLinksTab(projectId: widget.project.id),
              AccessRequestsTab(projectId: widget.project.id),
              GalleryInvitationsTab(projectId: widget.project.id),
            ],
          ),
        ),
      ),
    );
  }
}

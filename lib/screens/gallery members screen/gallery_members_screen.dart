import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gallery_member.dart';
import '../../models/project_model.dart';
import '../../providers/gallery_members_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_background.dart';



class GalleryMembersScreen extends StatefulWidget {
  final Project project;

  const GalleryMembersScreen({
    super.key,
    required this.project,
  });

  @override
  State<GalleryMembersScreen> createState() =>
      _GalleryMembersScreenState();
}

class _GalleryMembersScreenState extends State<GalleryMembersScreen> {
  @override
  void initState() {
    super.initState();

    // Load members after the first frame, when Provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Viewers must not load or manage the member list.
      if (widget.project.role != GalleryRole.owner) return;

      context.read<GalleryMembersProvider>().fetchMembers(
        widget.project.id,
        force: true,
      );
    });
  }

  /// Refresh the list using the project's ID.
  Future<void> _refreshMembers() async {
    await context.read<GalleryMembersProvider>().fetchMembers(
      widget.project.id,
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide the management interface when the role is not Owner.
    if (widget.project.role != GalleryRole.owner) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: AppBackground(
          child: const SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Only gallery Owners can view members.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final provider = context.watch<GalleryMembersProvider>();
    final currentUserId =
        context.watch<ProfileProvider>().profile?.id;

    // Ensure this screen displays data for its own project only.
    final isCurrentProject = provider.projectId == widget.project.id;

    final isLoading = !isCurrentProject || provider.isLoading;

    final members = isCurrentProject
        ? provider.members
        : <GalleryMember>[];

    final error = isCurrentProject ? provider.error : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AppBackground(
        child: SafeArea(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (error != null) {
                return _buildError(context, error);
              }

              if (members.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshMembers,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Icon(
                        Icons.people_outline,
                        size: 56,
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text('No gallery members found.'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshMembers,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: members.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {



                    return _buildMemberTile(
                      context,
                      members[index],
                      currentUserId: currentUserId
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build the translucent AppBar using the app's preferred style.
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 50,
            sigmaY: 8,
          ),
          child: AppBar(
            title: const Text('Gallery Members'),
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }

  /// Display one registered member or pending invitation.
  Widget _buildMemberTile(
      BuildContext context,
      GalleryMember member,
      {
        required int? currentUserId,
      }
      ) {
    final theme = Theme.of(context);

    final hasPhoto =
        member.photoUrl != null && member.photoUrl!.trim().isNotEmpty;

    final isCurrentUser =
        currentUserId != null && member.userId == currentUserId;

    final displayName = isCurrentUser
        ? '${member.displayName} (You)'
        : member.displayName;

    final roleLabel = member.role?.name ?? 'unknown';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // Display the member's profile photo if available.
        leading: ClipOval(
          child: SizedBox(
            width: 48,
            height: 48,
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: member.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _defaultAvatar(context),
              errorWidget: (_, __, ___) =>
                  _defaultAvatar(context),
            )
                : _defaultAvatar(context),
          ),
        ),

        title: Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show the email when the display name is different.
              if (member.displayName != member.email)
                Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 6),

              // Registered status distinguishes accounts from invitations.
              Row(
                children: [
                  Icon(
                    member.isRegistered
                        ? Icons.check_circle_outline
                        : Icons.schedule,
                    size: 14,
                    color: member.isRegistered
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      member.isRegistered
                          ? 'Registered'
                          : 'Pending invitation',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Display the member's role.
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roleLabel[0].toUpperCase() + roleLabel.substring(1),
            style: theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar(BuildContext context) {
    return ColoredBox(
      color: Colors.black12,
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: 28,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load gallery members.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _refreshMembers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
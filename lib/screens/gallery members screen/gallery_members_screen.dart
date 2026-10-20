import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gallery_member.dart';
import '../../models/project_model.dart';
import '../../providers/gallery_members_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_background.dart';

enum _GalleryMemberAction {
  makeOwner,
  makeViewer,
  remove,
}

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


  /// Confirm and submit a role change.
  Future<void> _confirmAndChangeRole({
    required GalleryMember member,
    required int projectId,
    required GalleryRole newRole,
  }) async {
    final newRoleLabel =
    newRole == GalleryRole.owner ? 'Owner' : 'Viewer';

    final description = newRole == GalleryRole.owner
        ? 'Owners can manage gallery membership and invitations.'
        : 'Viewers can access gallery photos but cannot manage members.';

    // Ask for confirmation before changing another member's permissions.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change member role?'),
        content: Text(
          'Change ${member.email} to $newRoleLabel?\n\n$description',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    // Submit the update through the provider and API service.
    final provider = context.read<GalleryMembersProvider>();

    final success = await provider.changeMemberRole(
      projectId: projectId,
      memberId: member.id,
      role: newRole,
    );

    if (!mounted) return;

    // Report the outcome without replacing the member list on an action error.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${member.email} is now a $newRoleLabel.'
              : provider.memberActionError ??
              'Could not update the member role.',
        ),
      ),
    );
  }

  /// Confirm removal before revoking a member's access.
  Future<void> _confirmAndRemoveMember({
    required GalleryMember member,
    required int projectId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove access?'),
          content: Text(
            'Remove ${member.email} from this gallery?\n\n'
                'They will no longer have access to this gallery.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Remove access'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final provider = context.read<GalleryMembersProvider>();

    final success = await provider.removeMember(
      projectId: projectId,
      memberId: member.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Access removed for ${member.email}.'
              : provider.memberActionError ??
              'Could not remove gallery access.',
        ),
      ),
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

    // Used to avoid offering a demotion action for the last Owner.
    final ownerCount = members
        .where((member) => member.role == GalleryRole.owner)
        .length;

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
                      currentUserId: currentUserId,
                      projectId: widget.project.id,
                      ownerCount: ownerCount,
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

  Widget _buildMemberTile(
      BuildContext context,
      GalleryMember member, {
        required int? currentUserId,
        required int projectId,
        required int ownerCount,
      }) {
    final theme = Theme.of(context);
    final provider = context.watch<GalleryMembersProvider>();

    final isCurrentUser = currentUserId != null &&
        member.userId == currentUserId;

    final isUpdatingRole = provider.isUpdatingMemberRole &&
        provider.updatingMemberId == member.id;

    final isRemoving = provider.isRemovingMember &&
        provider.removingMemberId == member.id;

    final isBusy = isUpdatingRole || isRemoving;

    final hasPhoto =
        member.photoUrl != null &&
            member.photoUrl!.trim().isNotEmpty;

    final role = member.role;
    final roleLabel = role?.name ?? 'unknown';

    // Prepare allowed role changes.
    final roleActions = <_GalleryMemberAction>[];

    if (role == GalleryRole.viewer) {
      roleActions.add(_GalleryMemberAction.makeOwner);
    }

    if (role == GalleryRole.owner && ownerCount > 1) {
      roleActions.add(_GalleryMemberAction.makeViewer);
    }

    // Hide all management actions for the current user.
    // Also fail closed if the current user's ID is unavailable.
    final canManageMember =
        currentUserId != null &&
            !isCurrentUser &&
            role != null;

    // Don't offer removal of the last Owner.
    final canRemove = canManageMember &&
        !(role == GalleryRole.owner && ownerCount <= 1);

    final canShowMenu = canManageMember &&
        (roleActions.isNotEmpty || canRemove);

    final roleBadge = Container(
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
    );

    Widget trailing = roleBadge;

    if (isBusy) {
      trailing = const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (canShowMenu) {
      trailing = PopupMenuButton<_GalleryMemberAction>(
        tooltip: 'Manage member',

        onSelected: (action) {
          switch (action) {
            case _GalleryMemberAction.makeOwner:
              _confirmAndChangeRole(
                member: member,
                projectId: projectId,
                newRole: GalleryRole.owner,
              );

            case _GalleryMemberAction.makeViewer:
              _confirmAndChangeRole(
                member: member,
                projectId: projectId,
                newRole: GalleryRole.viewer,
              );

            case _GalleryMemberAction.remove:
              _confirmAndRemoveMember(
                member: member,
                projectId: projectId,
              );
          }
        },

        itemBuilder: (context) => [
          ...roleActions.map((action) {
            final isOwnerAction =
                action == _GalleryMemberAction.makeOwner;

            return PopupMenuItem<_GalleryMemberAction>(
              value: action,
              child: Text(
                isOwnerAction ? 'Make Owner' : 'Make Viewer',
              ),
            );
          }),

          if (canRemove)
            PopupMenuItem<_GalleryMemberAction>(
              value: _GalleryMemberAction.remove,
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove_outlined,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Remove access',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              roleBadge,
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: ClipOval(
          child: SizedBox(
            width: 48,
            height: 48,
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: member.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _defaultAvatar(context),
              errorWidget: (_, __, ___) => _defaultAvatar(context),
            )
                : _defaultAvatar(context),
          ),
        ),

        title: Text(
          isCurrentUser
              ? '${member.displayName} (You)'
              : member.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (member.displayName != member.email)
                Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
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

        trailing: trailing,
      ),
    );
  }
}
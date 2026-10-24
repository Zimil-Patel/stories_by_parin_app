
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/admin_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

import '../admin users screen/admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().loadProjects();
      }
    });
  }

  Future<void> _createGallery(
      Map<String, dynamic> project,
      ) async {
    final provider = context.read<AdminProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Gallery?'),
        content: Text(
          'Create a client gallery for '
              '"${project['name'] ?? 'this project'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.createGallery(
      project['id'] as int,
    );

    if (!mounted) return;

    final message = success
        ? provider.actionMessage ?? 'Gallery created successfully.'
        : provider.errorMessage ?? 'Failed to create gallery.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    provider.clearMessages();
  }

  Future<void> _toggleGalleryStatus(
      Map<String, dynamic> project,
      ) async {
    final provider = context.read<AdminProvider>();
    final projectId = project['id'] as int;
    final currentlyEnabled = project['is_enabled'] == true;
    final newStatus = !currentlyEnabled;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${newStatus ? 'Enable' : 'Disable'} Gallery?',
        ),
        content: Text(
          newStatus
              ? 'Enable the gallery for '
              '"${project['name'] ?? 'this project'}"? '
              'Members will regain access.'
              : 'Disable the gallery for '
              '"${project['name'] ?? 'this project'}"? '
              'Members will no longer be able to access it.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: Text(newStatus ? 'Enable' : 'Disable'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.updateGalleryStatus(
      projectId: projectId,
      isEnabled: newStatus,
    );

    if (!mounted) return;

    final message = success
        ? provider.actionMessage ??
        'Gallery status updated successfully.'
        : provider.errorMessage ??
        'Failed to update gallery status.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    provider.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

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
              title: const Text('Admin Dashboard'),
              backgroundColor: Colors.white24,

              actions: [
                IconButton(
                  tooltip: 'Registered Users',
                  icon: const Icon(Icons.people_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: _buildBody(admin),
        ),
      ),
    );
  }

  Widget _buildBody(AdminProvider admin) {
    if (admin.isLoading && admin.projects.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (admin.errorMessage != null &&
        admin.projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load admin projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                admin.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: admin.isLoading
                    ? null
                    : () => context
                    .read<AdminProvider>()
                    .loadProjects(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<AdminProvider>().loadProjects(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage projects and client gallery access.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Projects',
                  value: admin.totalProjects,
                  icon: Icons.photo_library_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Galleries',
                  value: admin.totalGalleries,
                  icon: Icons.collections_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Enabled Galleries',
            value: admin.enabledGalleries,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 28),
          const Text(
            'All Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (admin.isLoading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (admin.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              admin.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 12),
          if (admin.projects.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No projects found.'),
                ),
              ),
            )
          else
            ...admin.projects.map(_buildProjectCard),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final projectName =
        project['name']?.toString() ?? 'Unnamed Project';
    final projectId = project['id'];
    final galleryId = project['gallery_id'];
    final isEnabled = project['is_enabled'];

    final String galleryStatus;

    if (galleryId == null) {
      galleryStatus = 'Not created';
    } else if (isEnabled == true) {
      galleryStatus = 'Enabled';
    } else if (isEnabled == false) {
      galleryStatus = 'Disabled';
    } else {
      galleryStatus = 'Unknown';
    }

    final admin = context.watch<AdminProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    projectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Project ID: $projectId'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Gallery status: '),
                Expanded(
                  child: Text(
                    galleryStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: galleryId == null
                          ? Colors.grey.shade700
                          : isEnabled == true
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (galleryId == null)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: admin.isUpdating
                      ? null
                      : () => _createGallery(project),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Gallery'),
                ),
              )
            else if (isEnabled is bool)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: admin.isUpdating
                      ? null
                      : () => _toggleGalleryStatus(project),
                  icon: Icon(
                    isEnabled
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  label: Text(
                    isEnabled ? 'Disable Gallery' : 'Enable Gallery',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

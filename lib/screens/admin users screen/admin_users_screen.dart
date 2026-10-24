import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_by_parin/providers/admin_provider.dart';
import 'package:stories_by_parin/widgets/app_background.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {


  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  List<Map<String, dynamic>> _filterUsers(
      List<Map<String, dynamic>> users,
      ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users.where((user) {
      final firstName = (user['first_name'] ?? '').toString();
      final lastName = (user['last_name'] ?? '').toString();
      final email = (user['email'] ?? '').toString();

      final fullName = '$firstName $lastName'.trim();

      return fullName.toLowerCase().contains(query) ||
          firstName.toLowerCase().contains(query) ||
          lastName.toLowerCase().contains(query) ||
          email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 8.0),
            child: AppBar(
              title: const Text('Registered Users'),
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white24,
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Consumer<AdminProvider>(
            builder: (context, admin, child) {
              if (admin.isLoadingUsers && admin.users.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (admin.errorMessage != null && admin.users.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          admin.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: admin.loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (admin.users.isEmpty) {
                return RefreshIndicator(
                  onRefresh: admin.loadUsers,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Center(child: Text('No registered users found.')),
                    ],
                  ),
                );
              }

              final filteredUsers = _filterUsers(admin.users);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.88),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: admin.loadUsers,
                      child: filteredUsers.isEmpty
                          ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 80),
                          Icon(
                            Icons.person_search_outlined,
                            size: 52,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              _searchQuery.trim().isEmpty
                                  ? 'No registered users found.'
                                  : 'No users match "$_searchQuery".',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                          : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          final firstName =
                          (user['first_name'] ?? '').toString().trim();
                          final lastName =
                          (user['last_name'] ?? '').toString().trim();
                          final fullName = '$firstName $lastName'.trim();
                          final email = (user['email'] ?? '').toString();
                          final photoUrl =
                          (user['photo_url'] ?? '').toString();
                          final isAdmin = user['is_admin'] == true ||
                              user['is_admin'] == 1;

                          return Card(
                            color: Colors.white.withValues(alpha: 0.88),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: ClipOval(
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: photoUrl.trim().isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: photoUrl.trim(),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => _defaultAvatar(context),
                                    errorWidget: (_, __, ___) => _defaultAvatar(context),
                                  )
                                      : _defaultAvatar(context),
                                ),
                              ),
                              title: Text(
                                fullName.isEmpty ? 'Unnamed User' : fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(email),
                              ),
                              trailing: isAdmin
                                  ? const Chip(
                                label: Text('Admin'),
                                avatar: Icon(Icons.verified_user, size: 16),
                              )
                                  : const Chip(
                                label: Text('User'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
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
}
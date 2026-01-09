// This screen displays all users for admin management
// Features:
// - Display all users except current admin
// - Search functionality
// - Role filtering
// - User statistics
// - Clean, modern UI with theme system
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../user/entities/user_entity.dart';
import '../../../user/entities/role.dart';
import '../../functions/fetch_all_users.dart';
import '../../functions/block_user.dart';
import '../widgets/users/user_card.dart';
import '../widgets/users/user_search_bar.dart';
import '../widgets/users/user_empty_state.dart';
import '../widgets/users/user_stat_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final Logger _logger = Logger();
  List<UserEntity> _users = [];
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String _searchQuery = '';
  Role? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      _logger.d('UsersScreen: Loading users...');
      _logger.d('  - Current user ID: $currentUserId');
      _logger.d('  - Role filter: ${_selectedRole?.name ?? 'none'}');

      final result = await fetchAllUsersForAdmin(
        currentUserId: currentUserId,
        limit: 100,
        roleFilter: _selectedRole,
      );

      _logger.d('  - Result success: ${result.isSuccess}');
      if (result.isSuccess) {
        _logger.i('  - Users loaded: ${result.data!.length}');
        setState(() => _users = result.data!);
      } else {
        _logger.e('  - Error: ${result.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to load users'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('  - Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final result = await getUserStatisticsForAdmin();
      if (result.isSuccess) {
        setState(() => _statistics = result.data!);
      }
    } catch (e) {
      // Statistics are optional, don't show error
    }
  }

  Future<void> _searchUsers() async {
    if (_searchQuery.trim().isEmpty) {
      _loadUsers();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final result = await searchUsersForAdmin(
        currentUserId: currentUserId,
        searchTerm: _searchQuery,
        limit: 50,
      );

      if (result.isSuccess) {
        setState(() => _users = result.data!);
      }
    } catch (e) {
      // Handle search errors silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = null;
      _searchController.clear();
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(
          title: 'User Management',
          backgroundColor: AppCommonColors.white,
          foregroundColor: AppColors.text,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadUsers();
                _loadStatistics();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            UserSearchBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedRole: _selectedRole,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
                if (value.length > 2 || value.isEmpty) {
                  _searchUsers();
                }
              },
              onRoleFilterPressed: _showRoleFilter,
              onClearFilters: _clearFilters,
            ),

            // Statistics Cards
            if (_statistics.isNotEmpty)
              Container(
                    padding: AppSpacing.paddingL,
                    child: Row(
                      children: [
                        UserStatCard(
                          title: 'Total Users',
                          value: _statistics['total'] ?? 0,
                          color: AppColors.primary,
                          icon: Icons.people,
                        ),
                        AppSpacing.h12,
                        UserStatCard(
                          title: 'Admins',
                          value: _statistics['admins'] ?? 0,
                          color: AppCommonColors.orange,
                          icon: Icons.admin_panel_settings,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, duration: 600.ms),

            // Users List
            Expanded(
              child: _users.isEmpty
                  ? const UserEmptyState()
                  : ListView.builder(
                      padding: AppSpacing.paddingL,
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return UserCard(
                          user: user,
                          index: index,
                          onViewDetails: () => _viewUserDetails(user),
                          onChangeRole: () => _changeUserRole(user),
                          onBlockUser: () => _blockUser(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.paddingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Role',
              style: TextStyle(fontSize: 18, fontWeight: AppFontWeights.bold),
            ),
            AppSpacing.v16,
            ...Role.values.map(
              (role) => ListTile(
                title: Text(role.name),
                onTap: () {
                  setState(() => _selectedRole = role);
                  Navigator.pop(context);
                  _loadUsers();
                },
              ),
            ),
            ListTile(
              title: const Text('All Roles'),
              onTap: () {
                setState(() => _selectedRole = null);
                Navigator.pop(context);
                _loadUsers();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewUserDetails(UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.fullName}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role?.name ?? 'No Role'}'),
            Text('Joined: ${user.createdAt.toString().split(' ')[0]}'),
            if (user.nickname != null) Text('Nickname: ${user.nickname}'),
            if (user.phoneNumber != null) Text('Phone: ${user.phoneNumber}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _changeUserRole(UserEntity user) {
    // TODO: Implement role change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change role for: ${user.fullName}')),
    );
  }

  void _blockUser(UserEntity user) {
    final isBlocked = user.adminblocked;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          isBlocked
              ? 'Are you sure you want to unblock ${user.fullName}?'
              : 'Are you sure you want to block ${user.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performBlockAction(user, !isBlocked);
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: isBlocked ? AppCommonColors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performBlockAction(UserEntity user, bool block) async {
    setState(() => _isLoading = true);

    try {
      final result = await blockUser(userId: user.userId, block: block);

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${user.fullName} has been ${block ? 'blocked' : 'unblocked'} successfully',
              ),
              backgroundColor: block
                  ? AppCommonColors.red
                  : AppCommonColors.green,
            ),
          );
          // Refresh the users list
          _loadUsers();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ??
                    'Failed to ${block ? 'block' : 'unblock'} user',
              ),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${block ? 'blocking' : 'unblocking'} user: $e',
            ),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

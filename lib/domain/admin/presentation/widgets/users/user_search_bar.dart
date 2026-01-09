import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../user/entities/role.dart';
import '../../../../../core/themes/app_theme.dart';

class UserSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Role? selectedRole;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRoleFilterPressed;
  final VoidCallback? onClearFilters;

  const UserSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedRole,
    required this.onSearchChanged,
    required this.onRoleFilterPressed,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          decoration: const BoxDecoration(
            color: AppCommonColors.white,
            border: Border(
              bottom: BorderSide(color: AppCommonColors.grey500, width: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users by name or email...',
                  prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                  border: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusS,
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppCommonColors.grey100,
                ),
                onChanged: onSearchChanged,
              ),

              AppSpacing.v12,

              // Filter Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (selectedRole != null || searchQuery.isNotEmpty) ...[
                      TextButton.icon(
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                      ),
                      AppSpacing.h8,
                    ],
                    _buildFilterChip(
                      'All Roles',
                      selectedRole?.name ?? 'All Roles',
                      selectedRole != null,
                      onRoleFilterPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.1, end: 0, duration: 600.ms);
  }

  Widget _buildFilterChip(
    String defaultText,
    String currentText,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(currentText),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppCommonColors.grey100,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}

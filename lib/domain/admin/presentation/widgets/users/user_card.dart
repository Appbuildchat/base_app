import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_shadows.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../user/entities/user_entity.dart';
import '../role_chip.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  final int index;
  final VoidCallback? onViewDetails;
  final VoidCallback? onChangeRole;
  final VoidCallback? onBlockUser;

  const UserCard({
    super.key,
    required this.user,
    required this.index,
    this.onViewDetails,
    this.onChangeRole,
    this.onBlockUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          decoration: BoxDecoration(
            color: AppCommonColors.white,
            borderRadius: AppDimensions.borderRadiusM,
            boxShadow: AppShadows.card,
          ),
          child: ListTile(
            contentPadding: AppSpacing.paddingL,
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage:
                  user.imageUrl != null && user.imageUrl!.isNotEmpty
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: user.imageUrl == null || user.imageUrl!.isEmpty
                  ? Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.fullName,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.v4,
                Text(
                  user.email,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                AppSpacing.v8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row: Role and Blocked status
                    Row(
                      children: [
                        RoleChip(role: user.role),
                        if (user.adminblocked) ...[
                          AppSpacing.h8,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: AppDimensions.borderRadiusM,
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'BLOCKED',
                              style: AppTypography.caption.copyWith(
                                color: Colors.red,
                                fontWeight: AppFontWeights.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.v4,
                    // Second row: Joined date
                    Text(
                      'Joined ${_formatDate(user.createdAt)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onViewDetails?.call();
                    break;
                  case 'role':
                    onChangeRole?.call();
                    break;
                  case 'block':
                    onBlockUser?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: AppDimensions.iconS + 2),
                      AppSpacing.h8,
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: AppDimensions.iconS + 2,
                      ),
                      AppSpacing.h8,
                      Text('Change Role'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(
                        user.adminblocked ? Icons.lock_open : Icons.block,
                        size: AppDimensions.iconS + 2,
                        color: user.adminblocked
                            ? AppCommonColors.green
                            : AppCommonColors.red,
                      ),
                      AppSpacing.h8,
                      Text(
                        user.adminblocked ? 'Unblock User' : 'Block User',
                        style: TextStyle(
                          color: user.adminblocked
                              ? AppCommonColors.green
                              : AppCommonColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.05, end: 0, duration: 600.ms);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}

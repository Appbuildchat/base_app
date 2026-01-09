import 'package:flutter/material.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../user/entities/role.dart';

class RoleChip extends StatelessWidget {
  final Role? role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleText = role?.name ?? 'No Role';
    final roleColor = role == Role.admin ? Colors.red : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        roleText,
        style: AppTypography.bodySmall.copyWith(
          color: roleColor,
          fontSize: 10,
          fontWeight: AppFontWeights.medium,
        ),
      ),
    );
  }
}

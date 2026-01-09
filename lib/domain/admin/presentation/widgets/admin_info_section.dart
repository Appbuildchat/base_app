import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_shadows.dart';

class AdminInfoSection extends StatelessWidget {
  const AdminInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        color: AppCommonColors.white,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                  size: AppDimensions.iconL,
                ),
              ),
              AppSpacing.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrator',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      currentUser?.email ?? 'admin@example.com',
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingM,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: AppDimensions.borderRadiusS,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: AppDimensions.iconS,
                ),
                AppSpacing.h8,
                Expanded(
                  child: Text(
                    'You have full administrative access to manage users and system settings.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

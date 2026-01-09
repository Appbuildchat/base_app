import 'package:flutter/material.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifications', style: AppTypography.headline2),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              size: AppDimensions.iconXXL * 2,
              color: AppColors.primary,
            ),
            AppSpacing.v20,
            Text(
              'Notifications',
              style: AppTypography.headline2.copyWith(color: AppColors.text),
            ),
            AppSpacing.v8,
            Text(
              'Coming Soon - All your notifications in one place',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

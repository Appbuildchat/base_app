import 'package:flutter/material.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_typography.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'flutter_basic_project'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: AppDimensions.iconXXL * 2,
              color: AppColors.primary,
            ),
            AppSpacing.v20,
            Text(
              'Welcome Home!',
              style: TextStyle(
                fontSize: AppTypography.bodySmall.fontSize,
                fontWeight: AppFontWeights.semiBold,
                color: AppColors.text,
              ),
            ),
            AppSpacing.v8,
            Text(
              'This is your main dashboard',
              style: TextStyle(
                fontSize: AppTypography.bodyRegular.fontSize,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/color_theme.dart';
import '../themes/app_typography.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

enum ToastType { success, error, info }

class ModernToast extends StatelessWidget {
  final String message;
  final ToastType type;

  const ModernToast({super.key, required this.message, required this.type});

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, ToastType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, ToastType.info);
  }

  static void _showToast(BuildContext context, String message, ToastType type) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 20,
        right: 20,
        child: ModernToast(message: message, type: type)
            .animate()
            .slideY(
              begin: 1.0,
              end: 0.0,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 300.ms),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.strong,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: AppCommonColors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyRegular.copyWith(
                  color: _getTextColor(),
                  fontWeight: AppFontWeights.medium,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.success:
        return AppCommonColors.green.withValues(alpha: 0.1);
      case ToastType.error:
        return AppCommonColors.red.withValues(alpha: 0.1);
      case ToastType.info:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case ToastType.success:
        return AppCommonColors.green;
      case ToastType.error:
        return AppCommonColors.red;
      case ToastType.info:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ToastType.success:
        return AppCommonColors.white;
      case ToastType.error:
        return AppCommonColors.white;
      case ToastType.info:
        return AppCommonColors.white;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check;
      case ToastType.error:
        return Icons.close;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}

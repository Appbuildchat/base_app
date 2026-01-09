import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../themes/color_theme.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

enum ModernButtonType { primary, secondary, outline, text }

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ModernButtonType type;
  final Widget? icon;
  final double? width;
  final double height;
  final Color? customColor;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ModernButtonType.primary,
    this.icon,
    this.width,
    this.height = 56,
    this.customColor,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case ModernButtonType.primary:
        return widget.customColor ?? AppColors.primary;
      case ModernButtonType.secondary:
        return AppColors.secondary;
      case ModernButtonType.outline:
        return AppCommonColors.white.withValues(alpha: 0.0);
      case ModernButtonType.text:
        return AppCommonColors.white.withValues(alpha: 0.0);
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case ModernButtonType.primary:
        return AppCommonColors.white;
      case ModernButtonType.secondary:
        return AppCommonColors.white;
      case ModernButtonType.outline:
        return widget.customColor ?? AppColors.primary;
      case ModernButtonType.text:
        return widget.customColor ?? AppColors.primary;
    }
  }

  BorderSide get _borderSide {
    switch (widget.type) {
      case ModernButtonType.outline:
        return BorderSide(
          color: widget.customColor ?? AppColors.primary,
          width: 2,
        );
      default:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      widget.type == ModernButtonType.primary ||
                          widget.type == ModernButtonType.secondary
                      ? AppShadows.primaryShadow(_backgroundColor)
                      : null,
                ),
                child: GestureDetector(
                  onTapDown: widget.onPressed != null && !widget.isLoading
                      ? _handleTapDown
                      : null,
                  onTapUp: widget.onPressed != null && !widget.isLoading
                      ? _handleTapUp
                      : null,
                  onTapCancel: widget.onPressed != null && !widget.isLoading
                      ? _handleTapCancel
                      : null,
                  child: ElevatedButton(
                    onPressed: widget.onPressed != null && !widget.isLoading
                        ? () {
                            widget.onPressed!();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _backgroundColor,
                      foregroundColor: _textColor,
                      elevation: 0,
                      shadowColor: AppCommonColors.white.withValues(alpha: 0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: _borderSide,
                      ),
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: AppCommonColors.grey300,
                      disabledForegroundColor: AppCommonColors.grey600,
                    ),
                    child: widget.isLoading
                        ? SpinKitThreeBounce(color: _textColor, size: 20)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: AppFontWeights.semiBold,
                                  color: _textColor,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 200.ms);
  }
}

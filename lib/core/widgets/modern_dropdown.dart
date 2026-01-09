import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/color_theme.dart';
import '../themes/app_typography.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

class ModernDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String labelText;
  final String? hintText;
  final String? Function(T?)? validator;
  final ValueChanged<T?> onChanged;
  final Widget? prefixIcon;

  const ModernDropdown({
    super.key,
    this.value,
    required this.items,
    required this.labelText,
    this.hintText,
    this.validator,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  State<ModernDropdown<T>> createState() => _ModernDropdownState<T>();
}

class _ModernDropdownState<T> extends State<ModernDropdown<T>> {
  bool _isFocused = false;
  bool _hasError = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _hasError
                ? null
                : (_isFocused
                      ? AppShadows.primaryShadow(AppColors.primary)
                      : AppShadows.button),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasError = error != null;
                  });
                }
              });
              return error;
            },
            items: widget.items,
            style: AppTypography.bodyRegular.copyWith(fontSize: 10),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: AppFontWeights.medium,
                color: _isFocused ? AppColors.primary : AppColors.secondary,
              ),
              hintStyle: TextStyle(
                fontSize: 10,
                color: AppCommonColors.grey400,
              ),
              filled: true,
              fillColor: _isFocused
                  ? AppColors.background
                  : AppCommonColors.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.accent, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            dropdownColor: AppCommonColors.white,
            borderRadius: BorderRadius.circular(16),
            menuMaxHeight: 300,
            icon: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _isFocused ? AppColors.primary : AppColors.secondary,
                size: 24,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../themes/color_theme.dart';
import '../themes/app_theme.dart';
import '../themes/app_shadows.dart';

class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color? overlayColor;
  final Color? spinnerColor;
  final Duration? duration;
  final VoidCallback? onTimeout;
  final bool forceKeepLoading;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
    this.spinnerColor,
    this.duration,
    this.onTimeout,
    this.forceKeepLoading = false,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  Timer? _timer;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _updateLoadingState();
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _updateLoadingState();
    }
  }

  void _updateLoadingState() {
    if (widget.isLoading && !_showLoading) {
      // Start loading
      setState(() {
        _showLoading = true;
      });

      // Set up timer for auto-hide (default 5 seconds for better stability)
      _timer?.cancel();
      _timer = Timer(widget.duration ?? const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showLoading = false;
          });
          widget.onTimeout?.call();
        }
      });
    } else if (!widget.isLoading && _showLoading && !widget.forceKeepLoading) {
      // Stop loading immediately only if not forced to keep loading
      _timer?.cancel();
      setState(() {
        _showLoading = false;
      });
    }
    // If forceKeepLoading is true, ignore isLoading=false and wait for timer
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showLoading)
          Positioned.fill(
            child:
                Container(
                      color:
                          widget.overlayColor ??
                          AppCommonColors.white.withValues(alpha: 0.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppCommonColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppShadows.strong,
                          ),
                          child: SpinKitPulse(
                            color: widget.spinnerColor ?? AppColors.primary,
                            size: 60,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scaleXY(begin: 0.8, end: 1.0, duration: 300.ms),
          ),
      ],
    );
  }
}

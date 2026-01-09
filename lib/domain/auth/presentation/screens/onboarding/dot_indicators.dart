import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.inActiveColor,
    this.activeColor,
  });

  final bool isActive;

  final Color? inActiveColor, activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 8, // 높이 통일
      width: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context)
                  .primaryColor // 활성화된 경우 테마 기본 색상 사용
            : Colors.grey.withValues(alpha: 0.5), // 비활성화된 경우 회색
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

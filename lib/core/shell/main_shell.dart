import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'tab_utils.dart';
import '../../domain/user/entities/role.dart';
import '../themes/color_theme.dart';
import '../themes/app_typography.dart';
import '../themes/app_font_weights.dart';
import '../themes/app_theme.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_shadows.dart';

/// =============================================================================
/// MAIN SHELL (하단 네비게이션 바 메인)
/// =============================================================================
///
/// 이 파일은 하단 네비게이션 바와 탭 화면들을 표시하는 메인 위젯입니다.
/// 현재 앱의 모던한 디자인과 애니메이션을 적용했습니다.
///
/// 스타일 변경하기:
/// 1. AppColors에서 색상 변경
/// 2. AppTypography에서 폰트 스타일 변경
/// 3. 애니메이션 duration 조정
///
/// 새 프로젝트 적용법:
/// 1. color system에 맞는 색상으로 수정
/// 2. Role enum import 경로 수정
/// 3. tab_utils.dart import 경로 수정
/// =============================================================================

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final Role? role;

  const MainShell({required this.navigationShell, this.role, super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('MainShell Debug:');
    _logger.d('  - Role: ${widget.role?.name ?? 'none'}');
    _logger.d(
      '  - NavigationShell branches: ${widget.navigationShell.route.branches.length}',
    );
    _logger.d('  - Current index: ${widget.navigationShell.currentIndex}');

    // 역할에 따른 탭 아이템 가져오기
    final items = TabUtils.getNavigationItemsForRole(widget.role);
    _logger.d('  - Tab items count: ${items.length}');
    _logger.d(
      '  - Tab items: ${items.map((e) => '${e.label}(${e.route})').join(', ')}',
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.navigationShell,
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppCommonColors.white,
          boxShadow: AppShadows.light,
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == widget.navigationShell.currentIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(context, index),
                    borderRadius: AppDimensions.borderRadiusM,
                    splashColor: AppColors.primary.withValues(alpha: 0.1),
                    highlightColor: AppColors.primary.withValues(alpha: 0.05),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppDimensions.borderRadiusM,
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? AppColors.primary
                                  : AppCommonColors.grey500,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTypography.caption.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppCommonColors.grey600,
                              fontWeight: isSelected
                                  ? AppFontWeights.semiBold
                                  : AppFontWeights.medium,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// 탭 선택 처리 (애니메이션 포함)
  void _onTap(BuildContext context, int index) {
    // 같은 탭을 누른 경우 무시
    if (index == widget.navigationShell.currentIndex) return;

    // 인덱스가 유효한 범위인지 확인
    if (index >= 0 && index < widget.navigationShell.route.branches.length) {
      // 애니메이션 실행
      _animationController.reset();
      _animationController.forward();

      // Role에 따른 특별한 경로 처리
      if (index == 1) {
        // 두 번째 탭 (Index 1) - Admin은 Users, User는 Profile
        final targetRoute = widget.role == Role.admin ? '/users' : '/profile';
        _logger.d('Navigating to: $targetRoute (role: ${widget.role?.name})');
        context.go(targetRoute);
      } else {
        // 다른 탭들은 기본 branch navigation 사용
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      }
    } else {
      _logger.w(
        'Invalid tab index: $index, max: ${widget.navigationShell.route.branches.length - 1}',
      );
    }
  }
}

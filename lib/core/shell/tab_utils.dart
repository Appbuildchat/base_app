import 'package:flutter/material.dart';
import '../../domain/user/entities/role.dart';
import '../themes/color_theme.dart';

/// =============================================================================
/// TAB UTILS (탭 아이콘/이름 설정)
/// =============================================================================
///
/// 이 파일은 하단 네비게이션 바의 탭 아이콘과 이름을 관리합니다.
/// 현재 앱의 실제 스크린에 맞게 구성했습니다.
///
/// 탭 아이콘/이름 변경하기:
/// 1. 해당 Role의 함수에서 아이콘과 라벨 수정
/// 2. 새로운 NavigationItem 추가
///
/// 탭 추가하기:
/// 1. 해당 Role 함수에 새 NavigationItem 추가
/// 2. shell_routes.dart에도 같은 개수만큼 브랜치 추가
///
/// Role 추가하기:
/// 1. 새 getRole3Items() 함수 생성
/// 2. getTabItemsForRole()과 getTabCountForRole()에 case 추가
/// =============================================================================

/// 네비게이션 아이템 모델
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// 탭 관련 유틸리티 함수
class TabUtils {
  /// Admin용 탭 아이템 (관리자)
  static List<NavigationItem> getAdminItems() {
    return [
      const NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: '/home',
      ),
      const NavigationItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Users',
        route: '/users',
      ),
      const NavigationItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        label: 'Reports',
        route: '/reports',
      ),
      const NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        route: '/admin-settings',
      ),
    ];
  }

  /// User용 탭 아이템 (일반 사용자)
  static List<NavigationItem> getUserItems() {
    return [
      const NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: '/home',
      ),
      const NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        route: '/profile',
      ),
    ];
  }

  /// 기본 탭 아이템 (역할 없을 때)
  static List<NavigationItem> getDefaultItems() {
    return [
      const NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        route: '/home',
      ),
      const NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        route: '/profile',
      ),
    ];
  }

  /// 역할에 따른 NavigationItem 리스트 가져오기 (MainShell용)
  static List<NavigationItem> getNavigationItemsForRole(Role? role) {
    switch (role) {
      case Role.admin:
        return getAdminItems();
      case Role.user:
        return getUserItems();
      default:
        return getDefaultItems();
    }
  }

  /// 역할에 따른 BottomNavigationBarItem 리스트 가져오기 (MainShell의 BottomNavigationBar용)
  static List<BottomNavigationBarItem> getTabItemsForRole(Role? role) {
    final items = getNavigationItemsForRole(role);
    return items.map((item) => _createBottomNavigationBarItem(item)).toList();
  }

  /// NavigationItem을 BottomNavigationBarItem으로 변환하는 헬퍼 함수
  static BottomNavigationBarItem _createBottomNavigationBarItem(
    NavigationItem item,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(
        item.icon,
        color: AppColors.secondary.withValues(alpha: 0.6),
        size: 24,
      ),
      activeIcon: Icon(item.activeIcon, color: AppColors.primary, size: 24),
      label: item.label,
    );
  }

  /// 역할에 따른 탭 개수 가져오기
  static int getTabCountForRole(Role? role) {
    switch (role) {
      case Role.admin:
        return 4; // Home, Users, Reports, Settings
      case Role.user:
        return 2; // Home, Profile
      default:
        return 2; // Home, Profile
    }
  }

  /// 역할에 따른 라우트 리스트 가져오기 (StatefulShellRoute의 브랜치용)
  static List<String> getRoutesForRole(Role? role) {
    final items = getNavigationItemsForRole(role);
    return items.map((item) => item.route).toList();
  }
}

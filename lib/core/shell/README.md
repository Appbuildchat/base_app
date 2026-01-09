# Shell

The Shell module provides the main navigation shell and tab management system for the application. It handles bottom navigation, tab switching, and maintains the persistent UI structure across different app sections.

## Folder Structure

```
lib/core/shell/
├── main_shell.dart         # Main navigation shell with bottom tabs
└── tab_utils.dart          # Tab management utilities and helpers
```

## Key Components

### 1. Main Shell (`main_shell.dart`)
The primary navigation container providing:
- **Bottom Navigation Bar**: Tab-based navigation interface
- **Tab Management**: Active tab state and switching logic
- **Persistent UI**: Consistent shell layout across screens
- **Modern Design**: Animated and styled navigation components

### 2. Tab Utils (`tab_utils.dart`)
Navigation utilities and helpers:
- **Tab Configuration**: Tab definitions and properties
- **Navigation Logic**: Tab switching and state management
- **Utility Functions**: Helper methods for tab operations
- **Route Mapping**: Tab-to-route associations

## Usage

### Basic Shell Setup
```dart
import '../core/shell/main_shell.dart';

// Used in router configuration
ShellRoute(
  builder: (context, state, child) {
    return MainShell(child: child);
  },
  routes: [
    // Tab routes go here
  ],
);
```

### Shell Integration with Router
```dart
import 'package:go_router/go_router.dart';
import '../core/shell/main_shell.dart';

final shellRoute = ShellRoute(
  builder: (context, state, child) {
    return MainShell(child: child);
  },
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileScreen(),
    ),
  ],
);
```

## Tab Configuration

### Default Tab Setup
The shell typically includes these main tabs:
- **Home**: Main app content and feeds
- **Search**: Search and discovery functionality
- **Notifications**: User notifications and alerts
- **Profile**: User profile and settings

### Tab Properties
```dart
class TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final Widget screen;

  const TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.screen,
  });
}
```

### Tab Configuration Example
```dart
import '../core/shell/tab_utils.dart';

final List<TabItem> mainTabs = [
  TabItem(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/home',
    screen: HomeScreen(),
  ),
  TabItem(
    label: 'Search',
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    route: '/search',
    screen: SearchScreen(),
  ),
  TabItem(
    label: 'Notifications',
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    route: '/notifications',
    screen: NotificationsScreen(),
  ),
  TabItem(
    label: 'Profile',
    icon: Icons.person_outlined,
    activeIcon: Icons.person,
    route: '/profile',
    screen: ProfileScreen(),
  ),
];
```

## Navigation Features

### Tab Switching
```dart
import '../core/shell/tab_utils.dart';

// Switch to specific tab
TabUtils.switchToTab(context, '/home');

// Get current tab index
int currentTab = TabUtils.getCurrentTabIndex(context);

// Check if tab is active
bool isHomeActive = TabUtils.isTabActive(context, '/home');
```

### Tab State Management
```dart
class TabState {
  final int currentIndex;
  final String currentRoute;
  final List<String> tabHistory;

  TabState({
    required this.currentIndex,
    required this.currentRoute,
    required this.tabHistory,
  });
}
```

### Nested Navigation
```dart
// Navigate within a tab (push new screen)
context.push('/home/details');

// Navigate to different tab
context.go('/search');

// Navigate with tab preservation
TabUtils.navigateInTab(context, '/home/settings');
```

## UI Customization

### Bottom Navigation Styling
```dart
import '../core/themes/app_theme.dart';
import '../core/themes/color_theme.dart';

BottomNavigationBar(
  backgroundColor: AppCommonColors.white,
  selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.neutral400,
  type: BottomNavigationBarType.fixed,
  elevation: 8,
  // Additional styling...
);
```

### Tab Animation
```dart
import 'package:flutter_animate/flutter_animate.dart';

// Animated tab switching
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: currentScreen,
).animate().fadeIn(duration: 200.ms);
```

### Custom Tab Bar
```dart
class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          return CustomTabBarItem(
            tab: entry.value,
            isActive: currentIndex == entry.key,
            onTap: () => onTap(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
```

## Tab Badge Support

### Notification Badges
```dart
class TabWithBadge extends StatelessWidget {
  final TabItem tab;
  final int badgeCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(isActive ? tab.activeIcon : tab.icon),
        if (badgeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Badge(
              label: Text('$badgeCount'),
              backgroundColor: Colors.red,
            ),
          ),
      ],
    );
  }
}
```

### Badge Management
```dart
import '../core/shell/tab_utils.dart';

// Update tab badge
TabUtils.updateBadge('/notifications', 5);

// Clear tab badge
TabUtils.clearBadge('/notifications');

// Get badge count
int badgeCount = TabUtils.getBadgeCount('/notifications');
```

## Deep Link Handling

### Tab-Specific Deep Links
```dart
class ShellDeepLinkHandler {
  static void handleDeepLink(String path) {
    // Determine which tab the path belongs to
    if (path.startsWith('/home')) {
      TabUtils.switchToTab(context, '/home');
      // Navigate to specific screen within home tab
    } else if (path.startsWith('/profile')) {
      TabUtils.switchToTab(context, '/profile');
      // Navigate to specific screen within profile tab
    }
  }
}
```

### URL Preservation
```dart
// Maintain tab context in URLs
class TabAwareRouter {
  static String buildTabUrl(String baseRoute, String subRoute) {
    return '$baseRoute$subRoute';
  }
  
  static void navigateWithinTab(String tabRoute, String destination) {
    final fullPath = buildTabUrl(tabRoute, destination);
    context.push(fullPath);
  }
}
```

## State Persistence

### Tab State Persistence
```dart
class TabStatePersistence {
  static const String _tabStateKey = 'current_tab_state';
  
  static Future<void> saveTabState(TabState state) async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = jsonEncode(state.toJson());
    await prefs.setString(_tabStateKey, stateJson);
  }
  
  static Future<TabState?> loadTabState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_tabStateKey);
    
    if (stateJson != null) {
      return TabState.fromJson(jsonDecode(stateJson));
    }
    
    return null;
  }
}
```

### Screen State Preservation
```dart
class TabScreenState {
  // Preserve scroll positions
  final Map<String, ScrollController> _scrollControllers = {};
  
  ScrollController getScrollController(String tabRoute) {
    return _scrollControllers.putIfAbsent(
      tabRoute,
      () => ScrollController(),
    );
  }
  
  void disposeControllers() {
    _scrollControllers.values.forEach((controller) {
      controller.dispose();
    });
    _scrollControllers.clear();
  }
}
```

## Accessibility

### Tab Accessibility
```dart
BottomNavigationBarItem(
  icon: Icon(tab.icon),
  activeIcon: Icon(tab.activeIcon),
  label: tab.label,
  tooltip: '${tab.label} tab',
  // Semantic labels for screen readers
);
```

### Focus Management
```dart
class AccessibleTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: BottomNavigationBar(
        // Tab bar implementation
        onTap: (index) {
          // Announce tab change to screen readers
          SemanticsService.announce(
            'Switched to ${tabs[index].label} tab',
            TextDirection.ltr,
          );
        },
      ),
    );
  }
}
```

## Performance Optimization

### Lazy Loading
```dart
class LazyTabContent extends StatelessWidget {
  final Widget child;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return SizedBox.shrink(); // Don't render inactive tabs
    }
    
    return child;
  }
}
```

### Memory Management
```dart
class TabMemoryManager {
  static void cleanupInactiveTabs() {
    // Clean up resources for inactive tabs
    // Clear caches, dispose controllers, etc.
  }
  
  static void preloadNextTab(int currentIndex) {
    // Preload content for likely next tab
  }
}
```

## Important Notes

- The shell provides persistent bottom navigation across app sections
- Tab state is maintained during navigation within tabs
- Custom styling follows the app's design system
- Badge support is available for notification counts
- Deep linking preserves tab context
- State persistence maintains user's tab preferences
- Accessibility features support screen readers and keyboard navigation
- Performance optimizations prevent unnecessary rendering of inactive tabs
- Tab utilities provide helper functions for common tab operations
- The shell integrates seamlessly with GoRouter for navigation management
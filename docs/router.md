# Router Rules

## MANDATORY GoRouter Implementation

### Required Files Structure
```
lib/core/router/
├── app_router.dart      # Main router configuration
├── general_routes.dart  # General app routes
└── shell_routes.dart    # Shell navigation routes
```

### Router Configuration Pattern
```dart
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) {
      return ErrorPage(
        error: state.error,
        location: state.matchedLocation,
      );
    },
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuth = user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      
      if (!isAuth && !isAuthRoute) return '/auth/signin';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Route definitions
    ],
  );
}
```

## Navigation Commands

### ALWAYS Use
```dart
context.go('/path');      // Navigate and replace
context.push('/path');    // Push on stack
context.pop();           // Pop current route
```

### NEVER Use
```dart
Navigator.push()         // Direct Navigator usage
Navigator.pop()          // Direct Navigator usage
```

## Route Definition Rules

### Standard Route
```dart
GoRoute(
  path: '/profile/:userId',
  name: 'profile',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfileScreen(userId: userId);
  },
)
```

### Shell Route (Bottom Navigation)
```dart
ShellRoute(
  builder: (context, state, child) => MainShell(child: child),
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
)
```

## STRICT Requirements
- ALWAYS include errorBuilder with ErrorPage
- ALWAYS implement authentication redirect
- ALWAYS use FirebaseAuth for auth state
- ALWAYS use path parameters for dynamic routes
- NEVER use query parameters for required data

## Route Guards
- Check auth state in redirect callback
- Redirect unauthorized users to /auth/signin
- Redirect authenticated users away from auth routes
- Return null when no redirect needed

## FORBIDDEN
- Using Navigator directly
- Missing errorBuilder in configuration
- Creating routes without names
- Hardcoding navigation paths in widgets
- Using MaterialPageRoute or CupertinoPageRoute
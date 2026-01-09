# Router

The Router module provides comprehensive navigation and routing functionality using GoRouter. It handles app navigation, route guards, authentication-based routing, and nested navigation structures.

## Folder Structure

```
lib/core/router/
├── app_router.dart         # Main router configuration
├── auth_guard.dart         # Authentication route protection
├── general_routes.dart     # General app routes definition
└── shell_routes.dart       # Shell/nested routes configuration
```

## Key Components

### 1. App Router (`app_router.dart`)
Central router configuration providing:
- **Router Instance**: Main GoRouter configuration
- **Navigator Keys**: Root and shell navigator management
- **Initial Route**: App startup navigation
- **Debug Logging**: Development navigation debugging

### 2. Auth Guard (`auth_guard.dart`)
Authentication protection system:
- **Route Protection**: Secure authenticated routes
- **Login Redirect**: Automatic authentication redirects
- **Permission Checks**: Role-based route access
- **Session Management**: Authentication state monitoring

### 3. General Routes (`general_routes.dart`)
App-wide route definitions:
- **Public Routes**: Accessible without authentication
- **Authentication Routes**: Login, signup, onboarding
- **Deep Linking**: External link handling
- **Error Routes**: 404 and error page routing

### 4. Shell Routes (`shell_routes.dart`)
Nested navigation structure:
- **Tab Navigation**: Bottom navigation routes
- **Nested Routes**: Multi-level navigation
- **Shell Layout**: Persistent UI elements
- **Tab State**: Navigation state management

## Usage

### Basic Router Setup
```dart
import '../core/router/app_router.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      routerConfig: AppRouter.router,
    );
  }
}
```

### Navigate to Routes
```dart
import 'package:go_router/go_router.dart';

// Push new route
context.push('/profile');

// Replace current route
context.go('/home');

// Pop current route
context.pop();

// Push with parameters
context.push('/user/123');

// Push with extra data
context.push('/details', extra: {'data': userObject});
```

### Route Parameters
```dart
// Define parameterized routes
GoRoute(
  path: '/user/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserScreen(userId: userId);
  },
),

// Access parameters
String userId = GoRouterState.of(context).pathParameters['userId']!;
```

### Query Parameters
```dart
// Navigate with query parameters
context.push('/search?q=flutter&category=mobile');

// Access query parameters
Map<String, String> queryParams = GoRouterState.of(context).uri.queryParameters;
String query = queryParams['q'] ?? '';
String category = queryParams['category'] ?? '';
```

## Authentication Guard

### Protected Routes
```dart
import '../core/router/auth_guard.dart';

// Define protected route
GoRoute(
  path: '/dashboard',
  builder: (context, state) => DashboardScreen(),
  redirect: AuthGuard.requireAuth,
),

// Role-based protection
GoRoute(
  path: '/admin',
  builder: (context, state) => AdminScreen(),
  redirect: (context, state) => AuthGuard.requireRole(Role.admin),
),
```

### Authentication State
```dart
class AuthGuard {
  static String? requireAuth(BuildContext context, GoRouterState state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    
    if (!isLoggedIn) {
      return '/login?redirect=${state.uri}';
    }
    
    return null; // Allow access
  }
  
  static String? requireRole(Role requiredRole) {
    return (BuildContext context, GoRouterState state) {
      final user = getCurrentUser();
      
      if (user?.role != requiredRole) {
        return '/unauthorized';
      }
      
      return null;
    };
  }
}
```

## Route Definitions

### General Routes Structure
```dart
// Public routes (no authentication required)
final publicRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => SplashScreen(),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginScreen(),
  ),
  GoRoute(
    path: '/signup',
    builder: (context, state) => SignupScreen(),
  ),
  GoRoute(
    path: '/onboarding',
    builder: (context, state) => OnboardingScreen(),
  ),
];

// Protected routes (authentication required)
final protectedRoutes = [
  GoRoute(
    path: '/home',
    builder: (context, state) => HomeScreen(),
    redirect: AuthGuard.requireAuth,
  ),
  GoRoute(
    path: '/profile',
    builder: (context, state) => ProfileScreen(),
    redirect: AuthGuard.requireAuth,
  ),
];
```

### Shell Routes with Tabs
```dart
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

## Deep Linking

### Handle External Links
```dart
// Configure app to handle custom schemes
GoRouter(
  routes: [
    GoRoute(
      path: '/share/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return PostScreen(postId: postId);
      },
    ),
  ],
);
```

### URL Generation
```dart
// Generate URLs for sharing
String generateShareUrl(String postId) {
  return 'https://yourapp.com/share/$postId';
}

// Navigate to generated URLs
context.push(Uri.parse(url).path);
```

## Navigation State Management

### Current Route Information
```dart
import 'package:go_router/go_router.dart';

// Get current route
String currentRoute = GoRouterState.of(context).uri.path;

// Check if specific route is active
bool isHomeActive = currentRoute == '/home';

// Get route parameters
Map<String, String> params = GoRouterState.of(context).pathParameters;
```

### Navigation Observers
```dart
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    print('Navigated to: ${route.settings.name}');
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print('Popped from: ${route.settings.name}');
  }
}

// Add observer to router
GoRouter(
  observers: [NavigationObserver()],
  routes: [...],
);
```

## Error Handling

### Custom Error Pages
```dart
GoRouter(
  errorBuilder: (context, state) {
    return ErrorPage(
      error: state.error,
      onRetry: () => context.go('/'),
    );
  },
  routes: [...],
);
```

### Route Not Found
```dart
// Handle 404 errors
GoRoute(
  path: '/404',
  builder: (context, state) => NotFoundPage(),
),

// Redirect unknown routes
redirect: (context, state) {
  final validRoutes = ['/home', '/profile', '/settings'];
  
  if (!validRoutes.contains(state.uri.path)) {
    return '/404';
  }
  
  return null;
},
```

## Route Transitions

### Custom Transitions
```dart
GoRoute(
  path: '/profile',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: ProfileScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
          ),
          child: child,
        );
      },
    );
  },
),
```

### Material/Cupertino Transitions
```dart
// Material page transition
GoRoute(
  path: '/settings',
  pageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: SettingsScreen(),
    );
  },
),

// Cupertino page transition
GoRoute(
  path: '/details',
  pageBuilder: (context, state) {
    return CupertinoPage(
      key: state.pageKey,
      child: DetailsScreen(),
    );
  },
),
```

## Route Configuration

### Route Matching
```dart
GoRouter(
  routes: [
    // Exact match
    GoRoute(path: '/home', ...),
    
    // Parameter matching
    GoRoute(path: '/user/:id', ...),
    
    // Wildcard matching
    GoRoute(path: '/files/*', ...),
    
    // Optional parameters
    GoRoute(path: '/search/:query?', ...),
  ],
);
```

### Route Priorities
```dart
// Order matters - more specific routes first
final routes = [
  GoRoute(path: '/user/profile', ...),  // Specific
  GoRoute(path: '/user/:id', ...),      // Parameter
  GoRoute(path: '/user', ...),          // General
];
```

## Best Practices

### Route Organization
- Group related routes together
- Use consistent naming conventions
- Implement proper error handling
- Add authentication guards where needed

### Performance Considerations
- Use lazy loading for heavy screens
- Implement route preloading for critical paths
- Monitor navigation performance
- Cache route parameters when appropriate

### Security
- Validate route parameters
- Implement proper authentication checks
- Use HTTPS for production deep links
- Sanitize user input in route handlers

## Important Notes

- All routes use GoRouter for consistent navigation
- Authentication guards are applied to protected routes
- Shell routes provide persistent navigation structure
- Deep linking is supported for external navigation
- Error handling includes custom error pages and fallbacks
- Route parameters and query parameters are fully supported
- Custom transitions can be applied to individual routes
- Navigation observers can track route changes for analytics
- URL generation supports sharing and deep linking functionality
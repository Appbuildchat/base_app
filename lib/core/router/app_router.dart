import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../error_page.dart';
import 'auth_guard.dart';
import 'general_routes.dart';
import 'shell_routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    initialLocation: '/',

    // Redirect logic for authentication
    redirect: (BuildContext context, GoRouterState state) {
      final currentRoute = state.uri.toString();
      return AuthGuard.redirectLogic(currentRoute);
    },

    // Refresh listenable for auth state changes
    refreshListenable: AuthStateNotifier(),

    // Error handling
    errorBuilder: (context, state) =>
        ErrorPage(errorCode: state.error.toString()),

    routes: [
      // General routes (public/auth routes) - includes splash screen at '/'
      ...GeneralRoutes.routes,

      // Shell routes (protected routes with bottom navigation)
      ...ShellRoutes.routes(_shellNavigatorKey),
    ],
  );

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;
}

// Global router instance for use in notification handlers and other global contexts
GoRouter? globalRouter = AppRouter.router;

/// Notifier for auth state changes to trigger router refresh
class AuthStateNotifier extends ChangeNotifier {
  static final Logger _logger = Logger();

  AuthStateNotifier() {
    AuthGuard.authStateChanges.listen((_) {
      if (kDebugMode) {
        _logger.d('AuthStateNotifier: Auth state changed, notifying router');
      }
      notifyListeners();
    });
  }
}

/// Custom page transition builder
class CustomPageTransition {
  static Page<T> fadeTransition<T extends Object?>(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  static Page<T> slideTransition<T extends Object?>(
    Widget child,
    GoRouterState state, {
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: begin,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
    );
  }

  static Page<T> scaleTransition<T extends Object?>(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

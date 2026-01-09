import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/home/presentations/screens/home_screen.dart';
import '../../domain/user/presentation/screens/profile_screen.dart';
import '../../domain/admin/presentation/screens/users_screen.dart';
import '../../domain/admin/presentation/screens/admin_settings_screen.dart';
import '../../domain/admin/presentation/screens/feedback_list_screen.dart';
import '../shell/main_shell.dart';
import '../providers/role_provider.dart';
import 'auth_guard.dart';
import 'app_router.dart';

class ShellRoutes {
  static List<RouteBase> routes(
    GlobalKey<NavigatorState> shellNavigatorKey,
  ) => [
    // StatefulShellRoute with role-based navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ListenableBuilder(
          listenable: RoleProvider(),
          builder: (context, child) {
            final roleProvider = RoleProvider();

            // Check for incomplete profile on social users
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (AuthGuard.isAuthenticated) {
                final hasIncomplete = await AuthGuard.hasIncompleteProfile();
                if (hasIncomplete && context.mounted) {
                  final socialData =
                      AuthGuard.getSocialDataForIncompleteProfile();
                  final provider = socialData['socialProvider'] as String?;

                  if (provider != null &&
                      provider != 'unknown' &&
                      provider != 'email') {
                    context.go(
                      '/auth/social-sign-up',
                      extra: {'socialData': socialData, 'provider': provider},
                    );
                  }
                }
              }
            });

            return MainShell(
              navigationShell: navigationShell,
              role: roleProvider.currentRole,
            );
          },
        );
      },
      branches: [
        // Home branch - Available to all roles (Index 0)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  CustomPageTransition.fadeTransition(
                    const HomeScreen(),
                    state,
                  ),
            ),
          ],
        ),

        // Second tab - Users (Admin) or Profile (User) (Index 1)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/users',
              pageBuilder: (context, state) =>
                  CustomPageTransition.fadeTransition(
                    const UsersScreen(),
                    state,
                  ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  CustomPageTransition.fadeTransition(
                    const ProfileScreen(),
                    state,
                  ),
            ),
          ],
        ),

        // Reports branch - Admin only (Index 2)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              pageBuilder: (context, state) =>
                  CustomPageTransition.fadeTransition(
                    const FeedbackListScreen(),
                    state,
                  ),
            ),
          ],
        ),

        // Admin Settings branch - Admin only (Index 3)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/admin-settings',
              pageBuilder: (context, state) =>
                  CustomPageTransition.fadeTransition(
                    const AdminSettingsScreen(),
                    state,
                  ),
            ),
          ],
        ),
      ],
    ),
  ];
}

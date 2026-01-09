import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/router/auth_guard.dart';
import 'core/themes/app_theme.dart';
import 'core/themes/color_loader.dart';
import 'core/themes/font_loader.dart';
import 'core/providers/role_provider.dart';
import 'core/notification/function/notification_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize colors and fonts from JSON
  await ColorLoader.loadColors();
  await FontLoader.loadFonts();

  // Initialize Firebase with proper options
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    AuthGuard.setFirebaseInitialized(true);
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    // Firebase not configured or error during initialization
    AuthGuard.setFirebaseInitialized(false);
    debugPrint('Firebase initialization error: $e');
    debugPrint('Running in offline mode - Firebase features disabled');
  }

  // Only initialize Firebase-dependent services if Firebase is ready
  if (firebaseInitialized) {
    try {
      // Initialize auth state listener for debugging
      AuthGuard.initializeAuthListener();

      // Initialize role provider to listen to auth changes
      RoleProvider().initialize();
      await NotificationInitializer.initialize();
    } catch (e) {
      debugPrint('Firebase services initialization error: $e');
    }
  }

  // Initialize animations
  Animate.restartOnHotReload = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Basic Project',
      debugShowCheckedModeBanner: false,

      // Router configuration
      routerConfig: AppRouter.router,

      // Theme configuration
      theme: AppTheme.lightTheme,

      // Builder for additional configuration
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling beyond reasonable limits
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

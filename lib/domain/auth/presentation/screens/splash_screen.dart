// =============================================================================
// SPLASH SCREEN
// =============================================================================
//
// This is the initial screen shown when the app starts. It features animated
// elements including the app logo, name, loading indicator, and branding.
//
// Features:
// - Animated logo with scale and rotation effects
// - Typewriter animation for app name
// - Modern loading indicator
// - Gradient animated background
// - Auto-navigation after animations complete
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/router/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;

  String _displayedText = '';
  final String _fullText = 'Your App Name';
  int _currentIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startAnimationSequence() async {
    // Start background animation immediately
    _backgroundController.repeat(reverse: true);

    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _logoController.forward();
    }

    // Start typewriter effect
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _startTypewriterEffect();
    }

    // Start loading animation
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      _loadingController.repeat(reverse: true);
    }

    // Navigate after all animations
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _startTypewriterEffect() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToNextScreen() async {
    // Check if user is already authenticated
    final isAuthenticated = AuthGuard.isAuthenticated;

    if (mounted) {
      if (isAuthenticated) {
        // User is authenticated, check if they have a complete profile
        await _checkUserDocumentAndNavigate();
      } else {
        context.go('/onboarding');
      }
    }
  }

  Future<void> _checkUserDocumentAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[SPLASH] No current user, going to onboarding');
        if (mounted) context.go('/onboarding');
        return;
      }

      debugPrint('[SPLASH] Checking user document for UID: ${user.uid}');

      // Check if user document exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists && userDoc.data() != null) {
        // User has complete profile, but check if we need to migrate authProvider
        final userData = userDoc.data() as Map<String, dynamic>;
        await _migrateAuthProviderIfNeeded(user.uid, userData);

        if (!mounted) return;

        debugPrint('[SPLASH] User document exists, navigating to home');
        context.go('/home');
      } else {
        // User is authenticated but has no profile document
        // This happens with social sign-in users who haven't completed profile setup
        debugPrint(
          '[SPLASH] User document missing, navigating to social sign-up',
        );

        // Detect the actual auth provider from Firebase providerData
        String detectedProvider = 'unknown';
        for (final providerProfile in user.providerData) {
          final providerId = providerProfile.providerId;
          if (providerId == 'google.com') {
            detectedProvider = 'google';
            break;
          } else if (providerId == 'apple.com') {
            detectedProvider = 'apple';
            break;
          }
        }

        debugPrint(
          '[SPLASH] Detected auth provider for social sign-up: $detectedProvider',
        );

        // We need to prepare social data for the social sign-up screen
        // Since we don't have the original social data, we'll use available Firebase user data
        final socialData = {
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'firstName': user.displayName?.split(' ').first ?? '',
          'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
          'photoUrl': user.photoURL,
          'isSocialSignUp': true,
          'socialProvider': detectedProvider,
        };

        context.go(
          '/auth/social-sign-up',
          extra: {'socialData': socialData, 'provider': detectedProvider},
        );
      }
    } catch (e) {
      debugPrint('[SPLASH] Error checking user document: $e');
      if (mounted) {
        // On error, sign out and go to onboarding
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/onboarding');
        }
      }
    }
  }

  Future<void> _migrateAuthProviderIfNeeded(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    // Check if authProvider field is missing
    if (userData['authProvider'] != null) {
      debugPrint(
        '[SPLASH] Auth provider already exists: ${userData['authProvider']}',
      );
      return; // Already has authProvider, no migration needed
    }

    debugPrint('[SPLASH] Auth provider missing, attempting migration...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Detect provider from Firebase providerData
      String detectedProvider = 'unknown';
      for (final providerProfile in user.providerData) {
        final providerId = providerProfile.providerId;
        if (providerId == 'password') {
          detectedProvider = 'email';
          break;
        } else if (providerId == 'google.com') {
          detectedProvider = 'google';
          break;
        } else if (providerId == 'apple.com') {
          detectedProvider = 'apple';
          break;
        }
      }

      if (detectedProvider != 'unknown') {
        debugPrint(
          '[SPLASH] Detected auth provider: $detectedProvider, updating user document',
        );

        // Update the user document with the detected auth provider
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
              'authProvider': detectedProvider,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        debugPrint('[SPLASH] Auth provider migration completed');
      } else {
        debugPrint('[SPLASH] Could not detect auth provider from providerData');
      }
    } catch (e) {
      debugPrint('[SPLASH] Auth provider migration failed: $e');
      // Don't throw error, this is non-critical
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _loadingController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.3),
                        _backgroundAnimation.value,
                      ) ??
                      AppColors.primary.withValues(alpha: 0.2),
                  Color.lerp(
                        AppColors.background,
                        AppColors.primary.withValues(alpha: 0.1),
                        _backgroundAnimation.value,
                      ) ??
                      AppColors.background,
                  Color.lerp(
                        AppColors.background,
                        AppColors.accent.withValues(alpha: 0.1),
                        _backgroundAnimation.value,
                      ) ??
                      AppColors.background,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top spacer
                  const Spacer(flex: 3),

                  // Logo Section
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: AppShadows.primaryShadow(
                                AppColors.primary,
                              ),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              size: 60,
                              color: AppCommonColors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // App Name with Typewriter Effect
                  Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text(
                          _displayedText,
                          style: AppTypography.headline1.copyWith(
                            color: AppColors.text,
                            fontSize: 28,
                            fontWeight: AppFontWeights.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 1000.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 800.ms,
                        delay: 1000.ms,
                      ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                        'Building Tomorrow, Today',
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.secondary,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 1400.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        delay: 1400.ms,
                      ),

                  const Spacer(flex: 2),

                  // Loading Animation
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Custom loading dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.2;
                              final animation =
                                  Tween<double>(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: _loadingController,
                                      curve: Interval(
                                        delay,
                                        (0.5 + delay).clamp(0.0, 1.0),
                                        curve: Curves.easeInOut,
                                      ),
                                    ),
                                  );

                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3 + (animation.value * 0.7),
                                      ),
                                    ),
                                    transform: Matrix4.identity()
                                      ..translate(0.0, -animation.value * 10),
                                  );
                                },
                              );
                            }),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Loading...',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 1800.ms),

                  const Spacer(flex: 1),

                  // Powered by AppBuildChat
                  Column(
                        children: [
                          Text(
                            'Powered by',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondary.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AppBuildChat',
                            style: AppTypography.bodyRegular.copyWith(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: AppFontWeights.semiBold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 2200.ms)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        delay: 2200.ms,
                      ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

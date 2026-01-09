import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/themes/app_theme.dart';
import '../screens/onboarding/onboarding_content.dart';
import '../screens/onboarding/dot_indicators.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Test Page 1',
      'description': 'Content test 1',
      'image': 'https://via.placeholder.com/300x300/4285F4/FFFFFF?text=Page+1',
      'category': 'Welcome',
    },
    {
      'title': 'Test Page 2',
      'description': 'Content test 2',
      'image': 'https://via.placeholder.com/300x300/34A853/FFFFFF?text=Page+2',
      'category': 'Discover',
    },
    {
      'title': 'Test Page 3',
      'description': 'Content test 3',
      'image': 'https://via.placeholder.com/300x300/EA4335/FFFFFF?text=Page+3',
      'category': 'Get Started',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    if (mounted) {
      context.go('/auth/sign-in-and-up');
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCommonColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideX(begin: 0.3, end: 0, duration: 600.ms, delay: 200.ms),

            // PageView
            Expanded(
              child:
                  PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          // Restart animation for new page
                          _animationController.reset();
                          _animationController.forward();
                        },
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          final data = _onboardingData[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                            ),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: OnboardingContent(
                                      title: data['title']!,
                                      description: data['description']!,
                                      image: data['image']!,
                                      category: data['category'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 400.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 800.ms,
                        delay: 400.ms,
                      ),
            ),

            // Bottom section with dots and button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: DotIndicator(
                              isActive: index == _currentPage,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        delay: 800.ms,
                      ),

                  AppSpacing.v30,

                  // Next/Get Started button
                  SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppCommonColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusL,
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: AppTypography.button,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 1000.ms)
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        delay: 1000.ms,
                      )
                      .scaleXY(
                        begin: 0.8,
                        end: 1.0,
                        duration: 600.ms,
                        delay: 1000.ms,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

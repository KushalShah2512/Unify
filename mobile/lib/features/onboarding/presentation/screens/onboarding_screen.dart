import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isFinishing = false;

  final List<OnboardingModel> _pages = [
    const OnboardingModel(
      image: AppAssets.onboarding1,
      title: 'Find Opportunities',
      description:
          'Discover internships, freelance gigs and jobs from verified companies.',
    ),
    const OnboardingModel(
      image: AppAssets.onboarding2,
      title: 'AI Career Assistant',
      description:
          'Receive AI-powered career guidance, resume analysis and personalized recommendations.',
    ),
    const OnboardingModel(
      image: AppAssets.onboarding3,
      title: 'Connect & Grow',
      description:
          'Build your professional network and accelerate your career journey.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    await StorageService.completeOnboarding();

    if (!mounted) return;

    context.go(RouteNames.login);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ------------------------------------------------------------
            // Skip
            // ------------------------------------------------------------
            SizedBox(
              height: 52,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isFinishing ? null : _finishOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),

            // ------------------------------------------------------------
            // Pages
            // ------------------------------------------------------------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final imageHeight =
                          (constraints.maxHeight * 0.42).clamp(200.0, 320.0);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),

                                // Illustration
                                SizedBox(
                                  height: imageHeight,
                                  child: Image.asset(
                                    page.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                const SizedBox(height: 42),

                                // Title
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Description
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ------------------------------------------------------------
            // Page Indicators
            // ------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) {
                  final isActive = _currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------------------
            // Next / Get Started
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFinishing ? null : _nextPage,
                  child: _isFinishing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _currentPage == _pages.length - 1
                              ? AppStrings.getStarted
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
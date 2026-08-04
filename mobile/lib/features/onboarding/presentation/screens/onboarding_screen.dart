import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<OnboardingModel> pages = [
    const OnboardingModel(
      image: AppAssets.onboarding1,
      title: "Find Opportunities",
      description:
          "Discover internships, freelance gigs and jobs from verified companies.",
    ),
    const OnboardingModel(
      image: AppAssets.onboarding2,
      title: "AI Career Assistant",
      description:
          "Receive AI-powered career guidance, resume analysis and personalized recommendations.",
    ),
    const OnboardingModel(
      image: AppAssets.onboarding3,
      title: "Connect & Grow",
      description:
          "Build your professional network and accelerate your career journey.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> finishOnboarding() async {
    await StorageService.completeOnboarding();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [

            /// Skip Button

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: finishOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (context, index) {

                  final page = pages[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Image.asset(
                          page.image,
                          height: 280,
                        ),

                        const SizedBox(height: 50),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge,
                        ),

                        const SizedBox(height: 18),

                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color:
                                    AppColors.textSecondary,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) {
                  return AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4),

                    width: currentPage == index ? 28 : 8,

                    height: 8,

                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? AppColors.primary
                          : Colors.grey.shade300,

                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),

              child: SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: nextPage,

                  child: Text(
                    currentPage == pages.length - 1
                        ? AppStrings.getStarted
                        : "Next",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
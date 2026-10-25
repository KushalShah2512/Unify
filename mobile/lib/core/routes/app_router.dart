// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:unify/features/auth/presentation/screens/login_screen.dart';
import 'package:unify/features/auth/presentation/screens/register_screen.dart';
import 'package:unify/features/home/screens/home_screen.dart';
import 'package:unify/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:unify/features/profile/screens/profile_screen.dart';
import 'package:unify/features/profile/screens/skills_screen.dart';
import 'package:unify/features/splash/presentation/screens/splash_screen.dart';
import 'package:unify/features/profile/screens/edit_profile_screen.dart';
import 'package:unify/features/profile/screens/projects_screen.dart';
import 'package:unify/features/profile/screens/certifications_screen.dart';
import 'package:unify/features/profile/screens/education_screen.dart';
import 'package:unify/features/profile/screens/career_passport_screen.dart';
import 'package:unify/features/ai/screens/ai_test_screen.dart';
import 'package:unify/features/ai/screens/opportunity_readiness_screen.dart';
import 'package:unify/features/opportunities/screens/opportunities_screen.dart';
import 'package:unify/features/opportunities/screens/opportunity_details_screen.dart';
import 'package:unify/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:unify/features/ai/screens/ai_career_assistant_screen.dart';
import 'package:unify/features/ai/screens/ats_resume_checker_screen.dart';
import 'package:unify/features/profile/screens/settings_screen.dart';

import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    
    GoRoute(
      path: RouteNames.education,
      builder: (context, state) => const EducationScreen(),
    ),

    GoRoute(
      path: RouteNames.skills,
      builder: (context, state) => const SkillsScreen(),
    ),

    GoRoute(
      path: RouteNames.editProfile,
      builder: (context, state) {
        return const EditProfileScreen();
      },
    ),

    GoRoute(
      path: RouteNames.projects,
      builder: (context, state) => const ProjectsScreen(),
    ),

    GoRoute(
      path: RouteNames.certifications,
      builder: (context, state) => const CertificationsScreen(),
    ),

    GoRoute(
      path: RouteNames.careerPassport,
      builder: (context, state) => const CareerPassportScreen(),
    ),

    GoRoute(
      path: RouteNames.aiTest,
      builder: (context, state) => const AiTestScreen(),
    ),

    GoRoute(
      path: RouteNames.opportunityReadiness,
      builder: (context, state) {
        final opportunity =
            state.extra as Map<String, dynamic>;

        return OpportunityReadinessScreen(
          opportunity: opportunity,
        );
      },
    ),

    GoRoute(
      path: RouteNames.opportunities,
      builder: (context, state) {
        final initialTab = (state.extra as Map<String, dynamic>?)?['initialTab'] as int? ?? 0;
        return OpportunitiesScreen(initialTab: initialTab);
      },
    ),

    GoRoute(
      path: RouteNames.opportunityDetails,
      builder: (context, state) {
        final opportunity =
            state.extra as Map<String, dynamic>;

        return OpportunityDetailsScreen(
          opportunity: opportunity,
        );
      },
    ),

    GoRoute(
      path: RouteNames.aiAssistant,
      builder: (context, state) => const AiCareerAssistantScreen(),
    ),

    GoRoute(
      path: RouteNames.atsChecker,
      builder: (context, state) => const AtsResumeCheckerScreen(),
    ),

    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
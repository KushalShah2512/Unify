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
      builder: (context, state) => const OpportunitiesScreen(),
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
  ],
);
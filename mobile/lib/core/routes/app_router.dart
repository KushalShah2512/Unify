// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:unify/features/auth/presentation/screens/login_screen.dart';
import 'package:unify/features/auth/presentation/screens/register_screen.dart';
import 'package:unify/features/home/screens/home_screen.dart';
import 'package:unify/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:unify/features/profile/screens/profile_screen.dart';
import 'package:unify/features/splash/presentation/screens/splash_screen.dart';
import 'package:unify/features/profile/screens/edit_profile_screen.dart';

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
      path: RouteNames.editProfile,
      builder: (context, state) {
        return const EditProfileScreen();
      },
    ),
  ],
);
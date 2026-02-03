import 'package:aura/features/auth/presentation/login_screen.dart';
import 'package:aura/features/home/presentation/home_screen.dart';
import 'package:aura/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aura/features/social/presentation/invite_screen.dart';
import 'package:aura/features/settings/presentation/ios_setup_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/onboarding', // Start with Onboarding for demo
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
           GoRoute(
            path: 'invite',
            builder: (context, state) => const InviteScreen(),
          ),
          GoRoute(
            path: 'ios-setup',
            builder: (context, state) => const IosSetupTutorialScreen(),
          ),
        ]
      ),
    ],
  );
}


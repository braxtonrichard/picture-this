import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/experience/presentation/log_experience_screen.dart';
import '../../features/experience/presentation/my_experiences_screen.dart';
import '../../features/home/presentation/root_shell.dart';
import '../../features/onboarding/presentation/onboarding_vibe_picker_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reflect/presentation/reflect_screen.dart';
import '../../features/vibes/presentation/vibe_detail_screen.dart';
import '../models/experience.dart';
import '../models/recommendation.dart';
import '../services/auth_service.dart';

/// The single source of truth for navigation. A GoRouter that redirects
/// based on auth state, so no screen has to re-check "am I logged in?"
/// itself. Watching [authStateProvider] here means this whole provider —
/// and therefore the GoRouter instance — rebuilds on sign-in/sign-out,
/// which is what re-runs `redirect`.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (_, GoRouterState state) {
      final bool isLoggedIn = authState.valueOrNull != null;
      final bool onAuthRoute = <String>[
        '/welcome',
        '/sign-in',
        '/sign-up',
      ].contains(state.matchedLocation);

      if (!isLoggedIn && !onAuthRoute) return '/welcome';
      if (isLoggedIn && onAuthRoute) return '/';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingVibePickerScreen(),
      ),
      ShellRoute(
        builder: (_, __, Widget child) => RootShell(child: child),
        routes: <RouteBase>[
          GoRoute(path: '/', builder: (_, __) => const DiscoverScreen()),
          GoRoute(
            path: '/experiences',
            builder: (_, __) => const MyExperiencesScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/vibe/:vibeId',
        builder: (_, GoRouterState state) =>
            VibeDetailScreen(vibeId: state.pathParameters['vibeId']!),
      ),
      GoRoute(
        path: '/log-experience',
        builder: (_, GoRouterState state) =>
            LogExperienceScreen(recommendation: state.extra! as Recommendation),
      ),
      GoRoute(
        path: '/reflect',
        builder: (_, GoRouterState state) =>
            ReflectScreen(experience: state.extra! as Experience),
      ),
    ],
  );
});

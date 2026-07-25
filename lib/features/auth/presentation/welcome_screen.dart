import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

/// The very first screen — sets the tone before anything else. Large
/// type, a lot of negative space, no chrome. Everything the founder spec
/// asks for ("this cannot be overstated") starts here.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 3),
              Text(
                'Picture This',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06, end: 0),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Who do you want to become today?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideY(begin: 0.06, end: 0),
              const Spacer(flex: 4),
              ElevatedButton(
                onPressed: () => context.go('/sign-up'),
                child: const Text('GET STARTED'),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text('I ALREADY HAVE AN ACCOUNT'),
              ).animate().fadeIn(delay: 380.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

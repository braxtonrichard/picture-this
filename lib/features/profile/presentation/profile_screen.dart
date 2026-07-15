import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/models/vibe.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vibe_chip.dart';
import '../../discover/data/discover_providers.dart';
import '../data/profile_providers.dart';

/// The "fun profile" from the founder spec — favorite vibes plus a grid
/// of playful either/or answers, instead of a demographics form.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfile?> profile = ref.watch(
      userProfileStreamProvider,
    );
    final AsyncValue<List<Vibe>> vibes = ref.watch(vibesStreamProvider);
    final AppColorScheme colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: profile.when(
        data: (UserProfile? p) {
          if (p == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: colors.surfaceMuted,
                backgroundImage: p.photoUrl != null
                    ? NetworkImage(p.photoUrl!)
                    : null,
                child: p.photoUrl == null
                    ? Text(
                        p.displayName.isNotEmpty
                            ? p.displayName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.displayMedium,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                p.displayName,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(p.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Favorite vibes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (p.favoriteVibeIds.isEmpty)
                Text(
                  "You haven't picked any vibes yet.",
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: p.favoriteVibeIds.map((String id) {
                    Vibe? vibe;
                    for (final Vibe v in vibes.valueOrNull ?? const <Vibe>[]) {
                      if (v.id == id) {
                        vibe = v;
                        break;
                      }
                    }
                    return VibeChip(
                      label: vibe?.name ?? id,
                      selected: true,
                      onTap: () => context.push('/vibe/$id'),
                    );
                  }).toList(),
                ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'About you',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (p.answers.isEmpty)
                Text(
                  'Personality questions coming soon.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...p.answers.entries.map(
                  (MapEntry<String, String> e) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          e.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          e.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/experience.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/experience_providers.dart';

/// Step 3 + the record of the loop: every experiment the user has
/// planned, done, or reflected on, newest first. Anything "experienced"
/// but not yet reflected on gets a prompt — reflection is what actually
/// feeds learning, so it shouldn't be easy to forget.
class MyExperiencesScreen extends ConsumerWidget {
  const MyExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Experience>> experiences = ref.watch(
      experiencesStreamProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your Experiments')),
      body: experiences.when(
        data: (List<Experience> list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'No experiments yet',
              message:
                  'Choose something from Discover to start your first one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int i) =>
                _ExperienceRow(experience: list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load your experiments",
          message: e.toString(),
        ),
      ),
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  const _ExperienceRow({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;
    final bool needsReflection =
        experience.status == ExperienceStatus.experienced;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 64,
              height: 64,
              child: CachedNetworkImage(
                imageUrl: experience.recommendationImageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: colors.divider),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  experience.recommendationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(experience.status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (needsReflection)
            TextButton(
              onPressed: () => context.push('/reflect', extra: experience),
              child: const Text('REFLECT'),
            ),
        ],
      ),
    );
  }

  String _statusLabel(ExperienceStatus status) {
    switch (status) {
      case ExperienceStatus.planned:
        return 'Planned';
      case ExperienceStatus.experienced:
        return 'Ready to reflect';
      case ExperienceStatus.reflected:
        return 'Reflected';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/recommendation.dart';
import '../../../core/models/vibe.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picture_card.dart';
import '../../../core/widgets/vibe_chip.dart';
import '../data/discover_providers.dart';

/// "Choose a vibe. Receive recommendations." — the entry point of the
/// core loop. A Pinterest-style masonry grid so photography leads and the
/// UI recedes.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Vibe>> vibes = ref.watch(vibesStreamProvider);
    final AsyncValue<List<Recommendation>> recommendations = ref.watch(
      recommendationsStreamProvider,
    );
    final String? selectedVibeId = ref.watch(selectedVibeIdProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Who do you want\nto become today?',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            if (vibes.valueOrNull?.isNotEmpty ?? false)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    itemCount: vibes.value!.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int i) {
                      final Vibe vibe = vibes.value![i];
                      return VibeChip(
                        label: vibe.name,
                        selected: selectedVibeId == vibe.id,
                        onTap: () {
                          ref.read(selectedVibeIdProvider.notifier).state =
                              selectedVibeId == vibe.id ? null : vibe.id;
                        },
                      );
                    },
                  ),
                ),
              ),
            if (selectedVibeId != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.push('/vibe/$selectedVibeId'),
                      child: const Text('VIEW VIBE PAGE →'),
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            recommendations.when(
              data: (List<Recommendation> list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Nothing to discover yet',
                      message: 'Seed the "recommendations" table in '
                          'Supabase to populate this feed — see '
                          'docs/ARCHITECTURE.md.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childCount: list.length,
                    itemBuilder: (BuildContext context, int i) {
                      final Recommendation rec = list[i];
                      return PictureCard(
                        imageUrl: rec.imageUrl,
                        title: rec.title,
                        subtitle: _categoryLabel(rec.category),
                        aspectRatio: i.isEven ? 0.75 : 1.05,
                        onTap: () =>
                            context.push('/log-experience', extra: rec),
                      );
                    },
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: "Couldn't load Discover",
                  message: e.toString(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.movie:
        return 'Movie';
      case RecommendationCategory.tvShow:
        return 'TV Show';
      case RecommendationCategory.book:
        return 'Book';
      case RecommendationCategory.music:
        return 'Music';
      case RecommendationCategory.podcast:
        return 'Podcast';
      case RecommendationCategory.restaurant:
        return 'Restaurant';
      case RecommendationCategory.recipe:
        return 'Recipe';
      case RecommendationCategory.coffeeShop:
        return 'Coffee Shop';
      case RecommendationCategory.city:
        return 'City';
      case RecommendationCategory.travel:
        return 'Travel';
      case RecommendationCategory.activity:
        return 'Activity';
      case RecommendationCategory.sport:
        return 'Sport';
      case RecommendationCategory.hobby:
        return 'Hobby';
      case RecommendationCategory.fashion:
        return 'Fashion';
      case RecommendationCategory.fragrance:
        return 'Fragrance';
      case RecommendationCategory.homeDecor:
        return 'Home Decor';
      case RecommendationCategory.art:
        return 'Art';
      case RecommendationCategory.photography:
        return 'Photography';
      case RecommendationCategory.videoGame:
        return 'Video Game';
      case RecommendationCategory.event:
        return 'Event';
    }
  }
}

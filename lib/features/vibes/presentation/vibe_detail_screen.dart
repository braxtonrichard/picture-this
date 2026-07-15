import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/recommendation.dart';
import '../../../core/models/vibe.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picture_card.dart';
import '../../../core/widgets/pt_button.dart';
import '../../discover/data/discover_providers.dart';

/// A vibe's own page — description plus everything tagged to it. "Apply
/// this vibe" is stubbed to jump into Discover pre-filtered to this vibe;
/// building a full day-plan generator is a deliberate follow-up, not part
/// of this skeleton pass (see docs/ARCHITECTURE.md).
class VibeDetailScreen extends ConsumerWidget {
  const VibeDetailScreen({required this.vibeId, super.key});

  final String vibeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Vibe?> vibe = ref.watch(vibeByIdProvider(vibeId));
    final AsyncValue<List<Recommendation>> recs = ref.watch(
      recommendationsForVibeProvider(vibeId),
    );
    final AppColorScheme colors = context.appColors;

    return Scaffold(
      body: vibe.when(
        data: (Vibe? v) {
          if (v == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Vibe not found',
              message: 'This vibe may have been removed.',
            );
          }
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: colors.background,
                surfaceTintColor: Colors.transparent,
                leading: const BackButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: v.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: colors.surfaceMuted),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        v.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        v.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PtButton(
                        label: 'APPLY THIS VIBE',
                        onPressed: () {
                          ref.read(selectedVibeIdProvider.notifier).state =
                              v.id;
                          context.go('/');
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'In this vibe',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              recs.when(
                data: (List<Recommendation> list) => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.85,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int i,
                    ) {
                      final Recommendation rec = list[i];
                      return PictureCard(
                        imageUrl: rec.imageUrl,
                        title: rec.title,
                        onTap: () =>
                            context.push('/log-experience', extra: rec),
                      );
                    }, childCount: list.length),
                  ),
                ),
                loading: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load this vibe",
          message: e.toString(),
        ),
      ),
    );
  }
}

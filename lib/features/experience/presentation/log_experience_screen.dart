import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/experience.dart';
import '../../../core/models/recommendation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pt_button.dart';

/// Step 2 of the core loop, "Experience." A recommendation becomes a
/// real, trackable experiment here — either saved for later (planned) or
/// marked done on the spot, which drops straight into Reflect.
class LogExperienceScreen extends ConsumerStatefulWidget {
  const LogExperienceScreen({required this.recommendation, super.key});

  final Recommendation recommendation;

  @override
  ConsumerState<LogExperienceScreen> createState() =>
      _LogExperienceScreenState();
}

class _LogExperienceScreenState extends ConsumerState<LogExperienceScreen> {
  bool _saving = false;

  Future<void> _log(ExperienceStatus status) async {
    final String? uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    final String id = await ref
        .read(firestoreServiceProvider)
        .logExperience(
          uid: uid,
          recommendation: widget.recommendation,
          status: status,
        );

    if (!mounted) return;

    if (status == ExperienceStatus.experienced) {
      final DateTime now = DateTime.now();
      context.push(
        '/reflect',
        extra: Experience(
          id: id,
          recommendationId: widget.recommendation.id,
          recommendationTitle: widget.recommendation.title,
          recommendationImageUrl: widget.recommendation.imageUrl,
          status: status,
          createdAt: now,
          experiencedAt: now,
        ),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Recommendation rec = widget.recommendation;
    final AppColorScheme colors = context.appColors;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            leading: const BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: rec.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    Container(color: colors.surfaceMuted),
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
                    rec.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    rec.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PtButton(
                    label: "I'VE EXPERIENCED THIS",
                    onPressed: () => _log(ExperienceStatus.experienced),
                    loading: _saving,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => _log(ExperienceStatus.planned),
                    child: const Text('SAVE FOR LATER'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vibe.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/pt_button.dart';
import '../../../core/widgets/vibe_chip.dart';
import '../../discover/data/discover_providers.dart';

/// The first thing a new user does: pick the vibes they're drawn to right
/// now. This seeds Discover — nothing here is permanent, vibes can be
/// added or dropped later from Profile.
class OnboardingVibePickerScreen extends ConsumerStatefulWidget {
  const OnboardingVibePickerScreen({super.key});

  @override
  ConsumerState<OnboardingVibePickerScreen> createState() =>
      _OnboardingVibePickerScreenState();
}

class _OnboardingVibePickerScreenState
    extends ConsumerState<OnboardingVibePickerScreen> {
  final Set<String> _selected = <String>{};
  bool _saving = false;

  Future<void> _finish() async {
    final String? uid = ref.read(authStateProvider).valueOrNull?.id;
    if (uid == null) return;
    setState(() => _saving = true);
    await ref
        .read(supabaseServiceProvider)
        .setFavoriteVibes(uid, _selected.toList());
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Vibe>> vibes = ref.watch(vibesStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Pick a few vibes',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Choose whatever you're drawn to — you can change these anytime.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: vibes.when(
                  data: (List<Vibe> list) => list.isEmpty
                      ? const _NoVibesYet()
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: list.map((Vibe v) {
                              final bool selected = _selected.contains(v.id);
                              return VibeChip(
                                label: v.name,
                                selected: selected,
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selected.remove(v.id);
                                  } else {
                                    _selected.add(v.id);
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object e, _) => const _NoVibesYet(),
                ),
              ),
              PtButton(
                label: _selected.isEmpty ? 'SKIP FOR NOW' : 'CONTINUE',
                onPressed: _finish,
                loading: _saving,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoVibesYet extends StatelessWidget {
  const _NoVibesYet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No vibes seeded yet — add some to the 'vibes' table in "
        'Supabase to populate this screen. See docs/ARCHITECTURE.md.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

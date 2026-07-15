import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/experience.dart';
import '../../../core/models/reflection.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pt_button.dart';

/// Step 3, "Reflect" — every recommendation gets feedback, which is what
/// the founder spec says the (future) learning engine actually trains on.
/// Rating uses the five-point Love/Like/Neutral/Dislike/Never Again scale
/// from the spec's Voting System section.
class ReflectScreen extends ConsumerStatefulWidget {
  const ReflectScreen({required this.experience, super.key});

  final Experience experience;

  @override
  ConsumerState<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends ConsumerState<ReflectScreen> {
  ReflectionRating _rating = ReflectionRating.like;
  bool _wouldRepeat = true;
  bool _matchedVibe = true;
  double _moodBefore = 3;
  double _moodAfter = 4;
  final TextEditingController _journal = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _journal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String? uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    await ref
        .read(firestoreServiceProvider)
        .submitReflection(
          uid: uid,
          reflection: Reflection(
            id: '',
            experienceId: widget.experience.id,
            rating: _rating,
            wouldRepeat: _wouldRepeat,
            matchedVibe: _matchedVibe,
            moodBefore: _moodBefore.round(),
            moodAfter: _moodAfter.round(),
            journalEntry: _journal.text.trim().isEmpty
                ? null
                : _journal.text.trim(),
            createdAt: DateTime.now(),
          ),
        );

    if (mounted) context.go('/experiences');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflect')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.experience.recommendationTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'How did it feel?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _RatingRow(
                value: _rating,
                onChanged: (ReflectionRating r) => setState(() => _rating = r),
              ),
              const SizedBox(height: AppSpacing.xl),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Would you do it again?'),
                value: _wouldRepeat,
                onChanged: (bool v) => setState(() => _wouldRepeat = v),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Did it match your vibe?'),
                value: _matchedVibe,
                onChanged: (bool v) => setState(() => _matchedVibe = v),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Mood before',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _moodBefore,
                min: 1,
                max: 5,
                divisions: 4,
                label: _moodBefore.round().toString(),
                onChanged: (double v) => setState(() => _moodBefore = v),
              ),
              Text(
                'Mood after',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _moodAfter,
                min: 1,
                max: 5,
                divisions: 4,
                label: _moodAfter.round().toString(),
                onChanged: (double v) => setState(() => _moodAfter = v),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Journal (optional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _journal,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What happened? What did you learn?',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PtButton(
                label: 'SAVE REFLECTION',
                onPressed: _submit,
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

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.value, required this.onChanged});

  final ReflectionRating value;
  final ValueChanged<ReflectionRating> onChanged;

  static const Map<ReflectionRating, String> _emoji =
      <ReflectionRating, String>{
        ReflectionRating.love: '😍',
        ReflectionRating.like: '🙂',
        ReflectionRating.neutral: '😐',
        ReflectionRating.dislike: '🙁',
        ReflectionRating.neverAgain: '🚫',
      };

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ReflectionRating.values.map((ReflectionRating rating) {
        final bool selected = rating == value;
        return GestureDetector(
          onTap: () => onChanged(rating),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.accentSoft : colors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? colors.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(_emoji[rating]!, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }
}

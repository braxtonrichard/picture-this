import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/recommendation.dart';
import '../../../core/models/vibe.dart';
import '../../../core/services/supabase_service.dart';

final StreamProvider<List<Vibe>> vibesStreamProvider =
    StreamProvider<List<Vibe>>(
  (Ref ref) => ref.watch(supabaseServiceProvider).watchVibes(),
);

/// Which vibe (if any) Discover is currently filtered to — set by tapping
/// a vibe chip in the "Choose a vibe" row.
final StateProvider<String?> selectedVibeIdProvider =
    StateProvider<String?>((Ref ref) => null);

/// Supabase's realtime `.stream()` only filters on a single `.eq()`
/// column, so "recommendations tagged with this vibe" is a client-side
/// filter over the one live `recommendations` stream rather than a second
/// query shape — fine for a hand-seeded reference table.
final StreamProvider<List<Recommendation>> recommendationsStreamProvider =
    StreamProvider<List<Recommendation>>((Ref ref) {
  final String? vibeId = ref.watch(selectedVibeIdProvider);
  final Stream<List<Recommendation>> all =
      ref.watch(supabaseServiceProvider).watchRecommendations();
  if (vibeId == null) return all;
  return all.map(
    (List<Recommendation> list) =>
        list.where((Recommendation r) => r.vibeIds.contains(vibeId)).toList(),
  );
});

final FutureProviderFamily<Vibe?, String> vibeByIdProvider =
    FutureProvider.family<Vibe?, String>(
  (Ref ref, String vibeId) =>
      ref.watch(supabaseServiceProvider).getVibe(vibeId),
);

final StreamProviderFamily<List<Recommendation>, String>
    recommendationsForVibeProvider =
    StreamProvider.family<List<Recommendation>, String>(
        (Ref ref, String vibeId) {
  return ref.watch(supabaseServiceProvider).watchRecommendations().map(
        (List<Recommendation> list) => list
            .where((Recommendation r) => r.vibeIds.contains(vibeId))
            .toList(),
      );
});

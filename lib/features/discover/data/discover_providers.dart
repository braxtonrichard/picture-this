import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/recommendation.dart';
import '../../../core/models/vibe.dart';
import '../../../core/services/firestore_service.dart';

final StreamProvider<List<Vibe>> vibesStreamProvider =
    StreamProvider<List<Vibe>>(
      (Ref ref) => ref.watch(firestoreServiceProvider).watchVibes(),
    );

/// Which vibe (if any) Discover is currently filtered to — set by tapping
/// a vibe chip in the "Choose a vibe" row.
final StateProvider<String?> selectedVibeIdProvider = StateProvider<String?>(
  (Ref ref) => null,
);

final StreamProvider<List<Recommendation>> recommendationsStreamProvider =
    StreamProvider<List<Recommendation>>((Ref ref) {
      final String? vibeId = ref.watch(selectedVibeIdProvider);
      return ref
          .watch(firestoreServiceProvider)
          .watchRecommendations(vibeId: vibeId);
    });

final FutureProviderFamily<Vibe?, String> vibeByIdProvider =
    FutureProvider.family<Vibe?, String>(
      (Ref ref, String vibeId) =>
          ref.watch(firestoreServiceProvider).getVibe(vibeId),
    );

final StreamProviderFamily<List<Recommendation>, String>
recommendationsForVibeProvider =
    StreamProvider.family<List<Recommendation>, String>(
      (Ref ref, String vibeId) => ref
          .watch(firestoreServiceProvider)
          .watchRecommendations(vibeId: vibeId),
    );

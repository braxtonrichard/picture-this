import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/experience.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

final StreamProvider<List<Experience>> experiencesStreamProvider =
    StreamProvider<List<Experience>>((Ref ref) {
      final String? uid = ref.watch(authStateProvider).valueOrNull?.uid;
      if (uid == null) {
        return Stream<List<Experience>>.value(const <Experience>[]);
      }
      return ref.watch(firestoreServiceProvider).watchExperiences(uid);
    });

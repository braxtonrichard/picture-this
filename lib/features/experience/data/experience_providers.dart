import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/experience.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';

final StreamProvider<List<Experience>> experiencesStreamProvider =
    StreamProvider<List<Experience>>((Ref ref) {
  final String? uid = ref.watch(authStateProvider).valueOrNull?.id;
  if (uid == null) {
    return Stream<List<Experience>>.value(const <Experience>[]);
  }
  return ref.watch(supabaseServiceProvider).watchExperiences(uid);
});

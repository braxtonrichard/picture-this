import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';

final StreamProvider<UserProfile?> userProfileStreamProvider =
    StreamProvider<UserProfile?>((Ref ref) {
  final String? uid = ref.watch(authStateProvider).valueOrNull?.id;
  if (uid == null) return Stream<UserProfile?>.value(null);
  return ref.watch(supabaseServiceProvider).watchUserProfile(uid);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/experience.dart';
import '../models/recommendation.dart';
import '../models/reflection.dart';
import '../models/user_profile.dart';
import '../models/vibe.dart';

/// All Supabase reads/writes for the app go through here — screens never
/// touch `Supabase.instance.client` directly, so the schema in
/// docs/ARCHITECTURE.md / supabase/migrations/0001_init.sql has exactly
/// one place it can drift from.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Profile ---------------------------------------------------------

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _client
        .from('profiles')
        .stream(primaryKey: <String>['id'])
        .eq('id', uid)
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.isEmpty ? null : UserProfile.fromMap(rows.first),
        );
  }

  Future<void> updateProfileAnswers(String uid, Map<String, String> answers) {
    return _client
        .from('profiles')
        .update(<String, dynamic>{'answers': answers}).eq('id', uid);
  }

  Future<void> setFavoriteVibes(String uid, List<String> vibeIds) {
    return _client
        .from('profiles')
        .update(<String, dynamic>{'favorite_vibe_ids': vibeIds}).eq('id', uid);
  }

  // --- Vibes -------------------------------------------------------------

  Stream<List<Vibe>> watchVibes() {
    return _client.from('vibes').stream(primaryKey: <String>['id']).map(
        (List<Map<String, dynamic>> rows) => rows.map(Vibe.fromMap).toList());
  }

  Future<Vibe?> getVibe(String vibeId) async {
    final Map<String, dynamic>? row =
        await _client.from('vibes').select().eq('id', vibeId).maybeSingle();
    return row == null ? null : Vibe.fromMap(row);
  }

  // --- Recommendations -----------------------------------------------
  //
  // Supabase's realtime `.stream()` only filters on a single `.eq()`
  // column, not array-contains — so vibe filtering happens client-side in
  // the Discover providers instead of a second query shape here. Fine for
  // a hand-seeded reference table; revisit if this collection grows large.

  Stream<List<Recommendation>> watchRecommendations() {
    return _client
        .from('recommendations')
        .stream(primaryKey: <String>['id']).map(
            (List<Map<String, dynamic>> rows) =>
                rows.map(Recommendation.fromMap).toList());
  }

  // --- Experiences ---------------------------------------------------

  Future<String> logExperience({
    required String uid,
    required Recommendation recommendation,
    required ExperienceStatus status,
  }) async {
    final Map<String, dynamic> row = await _client
        .from('experiences')
        .insert(<String, dynamic>{
          'user_id': uid,
          'recommendation_id': recommendation.id,
          'recommendation_title': recommendation.title,
          'recommendation_image_url': recommendation.imageUrl,
          'status': status.name,
          'experienced_at': status == ExperienceStatus.planned
              ? null
              : DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return row['id'] as String;
  }

  Stream<List<Experience>> watchExperiences(String uid) {
    return _client
        .from('experiences')
        .stream(primaryKey: <String>['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((List<Map<String, dynamic>> rows) =>
            rows.map(Experience.fromMap).toList());
  }

  // --- Reflections -----------------------------------------------------

  /// Calls the `submit_reflection` Postgres function (see the migration)
  /// so the reflection insert and the experience's status flip happen in
  /// one transaction instead of two separate round trips.
  Future<void> submitReflection(
      {required String uid, required Reflection reflection}) {
    return _client.rpc<void>(
      'submit_reflection',
      params: <String, dynamic>{
        'p_experience_id': reflection.experienceId,
        'p_rating': reflection.rating.name,
        'p_would_repeat': reflection.wouldRepeat,
        'p_matched_vibe': reflection.matchedVibe,
        'p_mood_before': reflection.moodBefore,
        'p_mood_after': reflection.moodAfter,
        'p_journal_entry': reflection.journalEntry,
      },
    );
  }
}

final Provider<SupabaseService> supabaseServiceProvider =
    Provider<SupabaseService>(
  (Ref ref) => SupabaseService(),
);

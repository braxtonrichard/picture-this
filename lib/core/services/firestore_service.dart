import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/experience.dart';
import '../models/recommendation.dart';
import '../models/reflection.dart';
import '../models/user_profile.dart';
import '../models/vibe.dart';
import 'firestore_paths.dart';

/// All Firestore reads/writes for the app go through here — screens never
/// touch `FirebaseFirestore.instance` directly, so the schema in
/// docs/ARCHITECTURE.md has exactly one place it can drift from.
class FirestoreService {
  FirestoreService() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // --- Profile ---------------------------------------------------------

  Future<void> upsertUserProfile({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
  }) {
    return _db.doc(FirestorePaths.userDoc(uid)).set(<String, dynamic>{
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteVibeIds': <String>[],
      'answers': <String, String>{},
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _db.doc(FirestorePaths.userDoc(uid)).snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> doc,
    ) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> updateProfileAnswers(String uid, Map<String, String> answers) {
    return _db.doc(FirestorePaths.userDoc(uid)).set(<String, dynamic>{
      'answers': answers,
    }, SetOptions(merge: true));
  }

  Future<void> setFavoriteVibes(String uid, List<String> vibeIds) {
    return _db.doc(FirestorePaths.userDoc(uid)).set(<String, dynamic>{
      'favoriteVibeIds': vibeIds,
    }, SetOptions(merge: true));
  }

  // --- Vibes -------------------------------------------------------------

  Stream<List<Vibe>> watchVibes() {
    return _db
        .collection(FirestorePaths.vibes)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                    Vibe.fromMap(d.id, d.data()),
              )
              .toList(),
        );
  }

  Future<Vibe?> getVibe(String vibeId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .collection(FirestorePaths.vibes)
        .doc(vibeId)
        .get();
    if (!doc.exists) return null;
    return Vibe.fromMap(doc.id, doc.data()!);
  }

  // --- Recommendations -----------------------------------------------

  Stream<List<Recommendation>> watchRecommendations({String? vibeId}) {
    Query<Map<String, dynamic>> query = _db.collection(
      FirestorePaths.recommendations,
    );
    if (vibeId != null) {
      query = query.where('vibeIds', arrayContains: vibeId);
    }
    return query.snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                Recommendation.fromMap(d.id, d.data()),
          )
          .toList(),
    );
  }

  // --- Experiences ---------------------------------------------------

  Future<String> logExperience({
    required String uid,
    required Recommendation recommendation,
    required ExperienceStatus status,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = await _db
        .collection(FirestorePaths.experiences(uid))
        .add(<String, dynamic>{
          'recommendationId': recommendation.id,
          'recommendationTitle': recommendation.title,
          'recommendationImageUrl': recommendation.imageUrl,
          'status': status.name,
          'createdAt': Timestamp.now(),
          'experiencedAt': status == ExperienceStatus.planned
              ? null
              : Timestamp.now(),
        });
    return ref.id;
  }

  Future<void> markExperienced(String uid, String experienceId) {
    return _db.doc(FirestorePaths.experienceDoc(uid, experienceId)).update(
      <String, dynamic>{
        'status': ExperienceStatus.experienced.name,
        'experiencedAt': Timestamp.now(),
      },
    );
  }

  Stream<List<Experience>> watchExperiences(String uid) {
    return _db
        .collection(FirestorePaths.experiences(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                    Experience.fromMap(d.id, d.data()),
              )
              .toList(),
        );
  }

  // --- Reflections -----------------------------------------------------

  Future<void> submitReflection({
    required String uid,
    required Reflection reflection,
  }) async {
    final WriteBatch batch = _db.batch();
    final DocumentReference<Map<String, dynamic>> reflectionRef = _db
        .collection(FirestorePaths.reflections(uid))
        .doc();
    batch.set(reflectionRef, reflection.toMap());
    batch.update(
      _db.doc(FirestorePaths.experienceDoc(uid, reflection.experienceId)),
      <String, dynamic>{'status': ExperienceStatus.reflected.name},
    );
    await batch.commit();
  }
}

final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((Ref ref) => FirestoreService());

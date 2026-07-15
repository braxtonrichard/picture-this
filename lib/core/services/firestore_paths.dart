/// Centralizes every Firestore collection/document path so the schema
/// lives in one place. See docs/ARCHITECTURE.md for the full data model.
class FirestorePaths {
  const FirestorePaths._();

  static const String users = 'users';
  static const String vibes = 'vibes';
  static const String recommendations = 'recommendations';

  static String userDoc(String uid) => '$users/$uid';
  static String experiences(String uid) => '$users/$uid/experiences';
  static String experienceDoc(String uid, String experienceId) =>
      '${experiences(uid)}/$experienceId';
  static String reflections(String uid) => '$users/$uid/reflections';
}

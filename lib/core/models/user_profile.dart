/// A user's profile — deliberately built around the founder spec's
/// "fun, not demographic" personality profile rather than a rigid schema.
/// [answers] is an open map of question id -> answer so new personality
/// questions (Hogwarts House, love language, etc.) can be added without a
/// migration.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.favoriteVibeIds = const <String>[],
    this.answers = const <String, String>{},
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final List<String> favoriteVibeIds;
  final Map<String, String> answers;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      favoriteVibeIds: List<String>.from(
        map['favoriteVibeIds'] as List<dynamic>? ?? <dynamic>[],
      ),
      answers: Map<String, String>.from(
        map['answers'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteVibeIds': favoriteVibeIds,
      'answers': answers,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? favoriteVibeIds,
    Map<String, String>? answers,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteVibeIds: favoriteVibeIds ?? this.favoriteVibeIds,
      answers: answers ?? this.answers,
    );
  }
}

/// A curated starter set of "fun profile" questions from the founder spec.
/// Kept as data (not hardcoded widgets) so the list can grow freely.
const List<String> personalityQuestionIds = <String>[
  'favoriteColor',
  'dogsOrCats',
  'coffeeOrTea',
  'beachOrMountains',
  'morningOrNight',
  'introvertOrExtrovert',
  'hogwartsHouse',
  'loveLanguage',
  'dreamVacation',
  'favoriteQuote',
];

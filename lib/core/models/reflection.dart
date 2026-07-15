import 'package:cloud_firestore/cloud_firestore.dart';

/// The five-point voting scale used everywhere a recommendation can be
/// rated — this is the signal the (future) learning engine trains on.
enum ReflectionRating { love, like, neutral, dislike, neverAgain }

/// The "Reflect" step of the core loop — feedback on a completed
/// experience. Kept intentionally close to the founder spec's question
/// list (enjoyment, would-repeat, mood shift, journal).
class Reflection {
  const Reflection({
    required this.id,
    required this.experienceId,
    required this.rating,
    required this.wouldRepeat,
    required this.matchedVibe,
    required this.createdAt,
    this.moodBefore,
    this.moodAfter,
    this.journalEntry,
  });

  final String id;
  final String experienceId;
  final ReflectionRating rating;
  final bool wouldRepeat;
  final bool matchedVibe;

  /// Free-form 1-5 mood scale, optional — the founder spec asks "mood
  /// before" / "mood after" without prescribing a scale, so this stays a
  /// small int rather than a rigid enum.
  final int? moodBefore;
  final int? moodAfter;
  final String? journalEntry;
  final DateTime createdAt;

  factory Reflection.fromMap(String id, Map<String, dynamic> map) {
    return Reflection(
      id: id,
      experienceId: map['experienceId'] as String? ?? '',
      rating: ReflectionRating.values.firstWhere(
        (ReflectionRating r) => r.name == map['rating'],
        orElse: () => ReflectionRating.neutral,
      ),
      wouldRepeat: map['wouldRepeat'] as bool? ?? false,
      matchedVibe: map['matchedVibe'] as bool? ?? false,
      moodBefore: map['moodBefore'] as int?,
      moodAfter: map['moodAfter'] as int?,
      journalEntry: map['journalEntry'] as String?,
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'experienceId': experienceId,
      'rating': rating.name,
      'wouldRepeat': wouldRepeat,
      'matchedVibe': matchedVibe,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'journalEntry': journalEntry,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

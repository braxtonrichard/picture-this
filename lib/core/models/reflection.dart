/// The five-point voting scale used everywhere a recommendation can be
/// rated — this is the signal the (future) learning engine trains on.
enum ReflectionRating { love, like, neutral, dislike, neverAgain }

/// The "Reflect" step of the core loop — feedback on a completed
/// experience. Kept intentionally close to the founder spec's question
/// list (enjoyment, would-repeat, mood shift, journal).
///
/// Built by the Reflect screen and passed straight to
/// `SupabaseService.submitReflection` (which calls the `submit_reflection`
/// Postgres function) — there's no read-back path yet, so this class has
/// no `fromMap`/`toMap`, just the fields the RPC call needs.
class Reflection {
  const Reflection({
    required this.experienceId,
    required this.rating,
    required this.wouldRepeat,
    required this.matchedVibe,
    this.moodBefore,
    this.moodAfter,
    this.journalEntry,
  });

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
}

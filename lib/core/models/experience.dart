/// Where an experience sits in the core loop: chosen but not yet done,
/// done and awaiting reflection, or fully reflected on.
enum ExperienceStatus { planned, experienced, reflected }

/// A user's personal record of trying a [Recommendation] — this is what
/// makes a recommendation "an experiment" rather than just a suggestion.
class Experience {
  const Experience({
    required this.id,
    required this.recommendationId,
    required this.recommendationTitle,
    required this.recommendationImageUrl,
    required this.status,
    required this.createdAt,
    this.experiencedAt,
  });

  final String id;
  final String recommendationId;

  // Denormalized so the Experiences list can render without a second
  // read per row — the recommendation itself may change or be removed.
  final String recommendationTitle;
  final String recommendationImageUrl;

  final ExperienceStatus status;
  final DateTime createdAt;
  final DateTime? experiencedAt;

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'] as String,
      recommendationId: map['recommendation_id'] as String? ?? '',
      recommendationTitle: map['recommendation_title'] as String? ?? '',
      recommendationImageUrl: map['recommendation_image_url'] as String? ?? '',
      status: ExperienceStatus.values.firstWhere(
        (ExperienceStatus s) => s.name == map['status'],
        orElse: () => ExperienceStatus.planned,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      experiencedAt: map['experienced_at'] == null
          ? null
          : DateTime.parse(map['experienced_at'] as String),
    );
  }
}

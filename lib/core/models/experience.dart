import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Experience.fromMap(String id, Map<String, dynamic> map) {
    return Experience(
      id: id,
      recommendationId: map['recommendationId'] as String? ?? '',
      recommendationTitle: map['recommendationTitle'] as String? ?? '',
      recommendationImageUrl: map['recommendationImageUrl'] as String? ?? '',
      status: ExperienceStatus.values.firstWhere(
        (ExperienceStatus s) => s.name == map['status'],
        orElse: () => ExperienceStatus.planned,
      ),
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      experiencedAt: (map['experiencedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'recommendationId': recommendationId,
      'recommendationTitle': recommendationTitle,
      'recommendationImageUrl': recommendationImageUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'experiencedAt': experiencedAt == null
          ? null
          : Timestamp.fromDate(experiencedAt!),
    };
  }
}

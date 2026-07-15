/// The category of a recommendation — deliberately an enum (not free text)
/// so Discover can filter/group consistently even before real content
/// exists for every category.
enum RecommendationCategory {
  movie,
  tvShow,
  book,
  music,
  podcast,
  restaurant,
  recipe,
  coffeeShop,
  city,
  travel,
  activity,
  sport,
  hobby,
  fashion,
  fragrance,
  homeDecor,
  art,
  photography,
  videoGame,
  event,
}

/// A single "experiment" the app can suggest — a movie, a coffee shop, a
/// hike. This is the unit that gets shown in Discover, logged in
/// Experience, and rated in Reflect.
class Recommendation {
  const Recommendation({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.vibeIds = const <String>[],
    this.location,
  });

  final String id;
  final String title;
  final RecommendationCategory category;
  final String imageUrl;
  final String description;
  final List<String> vibeIds;

  /// Free-text location string (city, address) — used later by Maps.
  final String? location;

  factory Recommendation.fromMap(String id, Map<String, dynamic> map) {
    return Recommendation(
      id: id,
      title: map['title'] as String? ?? '',
      category: RecommendationCategory.values.firstWhere(
        (RecommendationCategory c) => c.name == map['category'],
        orElse: () => RecommendationCategory.activity,
      ),
      imageUrl: map['imageUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      vibeIds: List<String>.from(
        map['vibeIds'] as List<dynamic>? ?? <dynamic>[],
      ),
      location: map['location'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'category': category.name,
      'imageUrl': imageUrl,
      'description': description,
      'vibeIds': vibeIds,
      'location': location,
    };
  }
}

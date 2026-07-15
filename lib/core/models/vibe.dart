/// A vibe is the organizing unit of Picture This — "Old Money", "Dark
/// Academia", "Coastal Grandmother", etc. Everything else (recommendations,
/// "Apply this vibe" days, daily suggestions) is generated in reference to
/// one or more vibes.
class Vibe {
  const Vibe({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    this.tags = const <String>[],
  });

  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final List<String> tags;

  factory Vibe.fromMap(String id, Map<String, dynamic> map) {
    return Vibe(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List<dynamic>? ?? <dynamic>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'tags': tags,
    };
  }
}

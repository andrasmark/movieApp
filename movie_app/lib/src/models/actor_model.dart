class Actor {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  Actor({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory Actor.fromMap(Map<String, dynamic> map) {
    return Actor(
      id: map['id'],
      name: map['name'] ?? 'Unknown',
      character: map['character'] ?? 'Unknown',
      profilePath: map['profile_path'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profilePath': profilePath,
    };
  }
}

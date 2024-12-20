class ActorDetailsModel {
  final int id;
  final String name;
  final String biography;
  final String profilePath;

  ActorDetailsModel({
    required this.id,
    required this.name,
    required this.biography,
    required this.profilePath,
  });

  factory ActorDetailsModel.fromJson(Map<String, dynamic> json) {
    return ActorDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      biography: json['biography'] ?? '',
      profilePath: json['profile_path'] ?? '',
    );
  }
}

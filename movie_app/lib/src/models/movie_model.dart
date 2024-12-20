class Movie{

  final int id;
  final String title;
  final String overview;
  final String backDropPath;
  final String posterPath;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.backDropPath,
    required this.posterPath
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? 'Unknown Title',
      overview: map['overview'] ?? 'No overview available',
      backDropPath: map['backdrop_path'] ?? '',
      posterPath: map['poster_path'] ?? '',
    );
  }


  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'backDropPath': backDropPath,
      'posterPath': posterPath,
      'overview': overview
    };
  }

}
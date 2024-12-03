class Movie{

  final String title;
  final String overview;
  final String backDropPath;
  final String posterPath;

  Movie({required this.title, required this.overview, required this.backDropPath, required this.posterPath});

  factory Movie.fromMap(Map<String, dynamic> map){
    return Movie(
      title: map['title'],
      backDropPath: map['backdrop_path'],
      posterPath: map['poster_path'],
      overview: map['overview']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'title': title,
      'backDropPath': backDropPath,
      'posterPath': posterPath,
      'overview': overview
    };
  }

}
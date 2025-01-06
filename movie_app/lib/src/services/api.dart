import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movie_app/src/models/movie_details_model.dart';
import 'package:movie_app/src/models/movie_model.dart';
import 'package:movie_app/src/models/movie_recommendations_model.dart';
import 'package:movie_app/src/models/actor_details_model.dart';


const apiKey = 'ff8b6c84a784e6e6f7b289816d0ef15a';
const baseUrl = 'https://api.themoviedb.org/3/';

class Api {
  final upComingApiUrl =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';
  final topRatedApiUrl =
      'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
  final popularApiUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';

  Future<List<Movie>> getUpcomingMovies() async {
    final response = await http.get(Uri.parse(upComingApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(Uri.parse(popularApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final response = await http.get(Uri.parse(topRatedApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<List<Movie>> getSearchResults(String searchString) async {
    var endPoint = "search/movie?query=$searchString";
    final url = "$baseUrl$endPoint";
    print(" search url is $url");
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmZjhiNmM4NGE3ODRlNmU2ZjdiMjg5ODE2ZDBlZjE1YSIsIm5iZiI6MTcyOTc1NDM1Ni40MjEsInN1YiI6IjY3MTlmNGY0ZTgzM2Q5MmVmMDVmZDJjNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Y9ZKHGPyHqQkfvpzLE_q5WfJSkY6Iu3ntMxpgwzys08"
    });

    if (response.statusCode == 200) {
      // Parse the response body and map it to a list of Movie objects
      var jsonData = jsonDecode(response.body);
      List<dynamic> results = jsonData['results'];

      // Convert each result into a Movie object
      List<Movie> movieList = results.map((item) {
        return Movie.fromMap(item);
      }).toList();

      return movieList;
    } else {
      throw Exception('Failed to load search query');
    }
  }


  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    final url = '${baseUrl}movie/$movieId?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return MovieDetailsModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<List<dynamic>> getMovieCast(int movieId) async {
    final url = '${baseUrl}movie/$movieId/credits?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final castData = json.decode(response.body);
      print(castData);
      return castData['cast'];
    } else {
      throw Exception('Failed to load movie cast');
    }
  }

  Future<MovieRecommendationsModel> getMovieRecommendations(int movieId) async {
    final url = '${baseUrl}movie/$movieId/recommendations?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return MovieRecommendationsModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load  recommended movies');
  }

  Future<ActorDetailsModel> getActorDetails(int actorID) async {
    final response = await http.get(
      Uri.parse('${baseUrl}person/$actorID?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ActorDetailsModel.fromJson(json);
    } else {
      throw Exception('Failed to load actor details');
    }
  }

  Future<List<Movie>> getActorRecentProjects(int actorID) async {
    final response = await http.get(
      Uri.parse('${baseUrl}person/$actorID/movie_credits?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('API response: $json');
      final castList = json['cast'] as List;
      return castList.map((cast) {
        try {
          return Movie.fromMap(cast);
        } catch (e) {
          print('Error parsing movie: $e');
          return null;
        }
      }).where((movie){
        return movie != null &&
            movie.title.isNotEmpty &&
            movie.posterPath.isNotEmpty &&
            movie.backDropPath.isNotEmpty &&
            movie.overview.isNotEmpty;
      }).toList().cast<Movie>();
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to load recent projects');
    }
  }

  Future<List<Map<String, dynamic>>> getMovieGenres() async {
    final url = '${baseUrl}genre/movie/list?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['genres'] as List;
      return data.map((genre) => {
        'id': genre['id'],
        'name': genre['name'],
      }).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final url = '${baseUrl}discover/movie?api_key=$apiKey&with_genres=$genreId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'] as List;
      return data.map((movieData) => Movie.fromMap(movieData)).toList();
    } else {
      throw Exception('Failed to load movies by genre');
    }
  }


  Future<List<Movie>> getMoviesByFilter({int? genreId, int? year}) async {
    String url = '${baseUrl}discover/movie?api_key=$apiKey';

    if (genreId != null) {
      url += '&with_genres=$genreId';
    }
    if (year != null) {
      url += '&primary_release_year=$year';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((movie) => Movie.fromMap(movie)).toList();
    } else {
      throw Exception('Failed to load movies by filters');
    }
  }

}

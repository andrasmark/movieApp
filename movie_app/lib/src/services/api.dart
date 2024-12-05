import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/movie_model.dart';

//const apiKey = '105a15aabd0ce3c2236844044fa22856';
const apiKey = 'ff8b6c84a784e6e6f7b289816d0ef15a';

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
}

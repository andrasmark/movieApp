import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

const apiKey = 'ff8b6c84a784e6e6f7b289816d0ef15a';

class Api{

  final upComingApiUrl = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';
  final topRatedApiUrl = 'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
  final popularApiUrl = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
  final baseUrl = 'https://api.themoviedb.org/3/';

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

  Future<List<Movie>> getSearchResults(String searchString) async{
    var endPoint = "search/movie?query=$searchString";
    final url = "$baseUrl$endPoint$apiKey";
    final response = await http.get(Uri.parse(url),headers: {
      'Authorization':
          "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmZjhiNmM4NGE3ODRlNmU2ZjdiMjg5ODE2ZDBlZjE1YSIsIm5iZiI6MTcyOTc1NDM1Ni40MjEsInN1YiI6IjY3MTlmNGY0ZTgzM2Q5MmVmMDVmZDJjNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Y9ZKHGPyHqQkfvpzLE_q5WfJSkY6Iu3ntMxpgwzys08"
    });
    if(response.statusCode == 200){
      log("Success");
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    }
    else{
      throw Exception('Failed to load search query');
    }

  }



}
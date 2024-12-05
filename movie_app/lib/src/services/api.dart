
import 'dart:convert';
import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/models/movie_details_model.dart';
import 'package:movie_app/models/movie_recommendations_model.dart';
import 'package:http/http.dart' as http;

const apiKey = 'ff8b6c84a784e6e6f7b289816d0ef15a';
const baseUrl = 'https://api.themoviedb.org/3/';

class Api{

  final upComingApiUrl = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';
  final topRatedApiUrl = 'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
  final popularApiUrl = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';

  Future<List<Movie>> getUpcomingMovies() async{
    final response = await http.get(Uri.parse(upComingApiUrl));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    }else{
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<List<Movie>> getPopularMovies() async{
    final response = await http.get(Uri.parse(popularApiUrl));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    }else{
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async{
    final response = await http.get(Uri.parse(topRatedApiUrl));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['results'];
      List<Movie> movies = data.map((movie) => Movie.fromMap(movie)).toList();
      return movies;
    }else{
      throw Exception('Failed to load top rated movies');
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

}
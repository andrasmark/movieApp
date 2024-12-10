import 'package:flutter/material.dart';
import 'package:movie_app/src/components/MovieCardWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:movie_app/src/models/movie_details_model.dart';
import 'package:movie_app/src/components/MovieCardWidget.dart';
import 'package:movie_app/src/models/movie_recommendations_model.dart';
import 'package:movie_app/src/models/movie_model.dart';
import '../services/api.dart';

const String imageUrl = 'https://image.tmdb.org/t/p/w500';

class MovieDetailsPage extends StatefulWidget {
  static String id = 'movie_details_page';
  final int movieID;

  const MovieDetailsPage({Key? key, required this.movieID}) : super(key: key);

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsPage> {
  Api api = Api();

  late Future<MovieDetailsModel> movieDetails;
  late Future<MovieRecommendationsModel> movieRecommendationModel;
  late Future<List<dynamic>> movieCast;

  double userRating = 0.0;
  bool isAddedToWatchlist = false;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  fetchInitialData() {
    movieDetails = api.getMovieDetails(widget.movieID);
    movieRecommendationModel = api.getMovieRecommendations(widget.movieID);
    movieCast = api.getMovieCast(widget.movieID);
  }

  Movie convertResultToMovie(Result result) {
    return Movie(
      id: result.id ?? 0,
      title: result.title ?? 'NULL',
      overview: result.overview ?? 'NULL',
      backDropPath: result.backdropPath ?? 'NULL',
      posterPath: result.posterPath ?? 'NULL',
    );
  }

  void toggleWatchlist() {
    setState(() {
      isAddedToWatchlist = !isAddedToWatchlist;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAddedToWatchlist
              ? 'Added to Watchlist!'
              : 'Removed from Watchlist!',
        ),
      ),
    );
  }

  void showRatingDialog() {
    double tempRating = userRating;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate this Movie'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < tempRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        tempRating = index + 1.0;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  userRating = tempRating;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: movieDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final movie = snapshot.data!;
              String genresText =
                  movie.genres.map((genre) => genre.name).join(', ');

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: movie.backdropPath != null && movie.backdropPath.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Title
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Movie release year and genres
                        Row(
                          children: [
                            Text(
                              movie.releaseDate.year.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Text(
                              genresText,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Movie Description
                        Text(
                          movie.overview ?? 'No description available.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Cast section
                        FutureBuilder<List<dynamic>>(
                          future: movieCast,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Text('Failed to load cast.');
                            } else if (snapshot.hasData) {
                              final cast = snapshot.data!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: const Text(
                                      "Cast",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: cast.length,
                                      itemBuilder: (context, index) {
                                        final actor = cast[index];
                                        final profilePath =
                                            actor['profile_path'];

                                        return Container(
                                          width: 120,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: profilePath != null
                                                      ? 'https://image.tmdb.org/t/p/w500$profilePath'
                                                      : 'https://via.placeholder.com/150',
                                                  height: 140,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(height: 0),
                                              Text(
                                                actor['name'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                actor['character'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const Text("No cast data available.");
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: showRatingDialog,
                          child: const Text('RATE MOVIE'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: toggleWatchlist,
                          child: Text(
                            isAddedToWatchlist
                                ? 'ADDED TO WATCHLIST'
                                : 'ADD TO WATCHLIST',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Recommended movies section
                  FutureBuilder(
                    future: movieRecommendationModel,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final recommendations = snapshot.data!.results;
                        final movies = recommendations
                            .map((result) => convertResultToMovie(result))
                            .toList();
                        if (movies.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 15.0),
                              child: const Text(
                                "More like this",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                              itemCount: recommendations.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                childAspectRatio: 2 / 3,
                              ),
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                if(movie.id != 0 &&
                                    movie.title != 'NULL' &&
                                    movie.overview != 'NULL' &&
                                    movie.posterPath != 'NULL' &&
                                    movie.backDropPath != 'NULL') {
                                  return MovieCardWidget(movie: movie);
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      }
                      return const Text("No recommendations available.");
                    },
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

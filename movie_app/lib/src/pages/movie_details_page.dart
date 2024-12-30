import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/src/components/MovieCardWidget.dart';
import 'package:movie_app/src/models/movie_details_model.dart';
import 'package:movie_app/src/models/movie_model.dart';

import '../models/movie_recommendations_model.dart';
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
  late Future<List<dynamic>> movieCast;
  late Future<MovieRecommendationsModel> movieRecommendationModel;
  late Future<double> averageRatingFuture;
  late Future<Map<String, dynamic>> ratingsFuture;

  final TextEditingController ratingController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser!;
  double userRating = 0.0;

  bool isAddedToWatchlist = false;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    checkIfInWatchlist();
  }

  fetchInitialData() {
    movieDetails = api.getMovieDetails(widget.movieID);
    movieRecommendationModel = api.getMovieRecommendations(widget.movieID);
    movieCast = api.getMovieCast(widget.movieID);
    averageRatingFuture = fetchAverageRating();
    ratingsFuture = fetchRatingsAndUsers();
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

  Future<void> checkIfInWatchlist() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final watchlist = List<int>.from(userDoc['watchlist'] ?? []);
        setState(() {
          isAddedToWatchlist = watchlist.contains(widget.movieID);
        });
      }
    } catch (e) {
      print('Error checking watchlist: $e');
    }
  }

  void toggleWatchlist() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final movieId = widget.movieID;

      if (isAddedToWatchlist) {
        await userRef.update({
          'watchlist': FieldValue.arrayRemove([movieId]),
        });
      } else {
        await userRef.update({
          'watchlist': FieldValue.arrayUnion([movieId]),
        });
      }

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update watchlist. Please try again.'),
        ),
      );
      print('Error updating watchlist: $e');
    }
  }

  //For the averageRating
  Future<double> fetchAverageRating() async {
    final movieId = widget.movieID.toString();
    final movieRef =
        FirebaseFirestore.instance.collection('movies').doc(movieId);
    final movieDoc = await movieRef.get();

    if (movieDoc.exists && movieDoc.data()!.containsKey('averageRating')) {
      return movieDoc['averageRating'] as double;
    }
    return 0.0;
  }

  //For the list of users who have rated
  Future<Map<String, dynamic>> fetchRatingsAndUsers() async {
    final movieId = widget.movieID.toString();
    final movieRef =
        FirebaseFirestore.instance.collection('movies').doc(movieId);
    final movieDoc = await movieRef.get();

    if (movieDoc.exists) {
      final ratings = Map<String, dynamic>.from(movieDoc['ratings'] ?? {});
      final Map<String, String> userNames = {};

      for (final userId in ratings.keys) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        userNames[userId] =
            userDoc.exists ? userDoc['userName'] : 'Unknown User';
      }

      return ratings
          .map((key, value) => MapEntry(userNames[key] ?? key, value));
    }
    return {};
  }

  Future<void> rateMovie(double rating) async {
    final movieId = widget.movieID.toString();
    final movieRef =
        FirebaseFirestore.instance.collection('movies').doc(movieId);
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Update user's ratedMovies
    await userRef.update({
      'ratedMovies.$movieId': rating,
    });

    // Update movie's ratings and calculate new average
    final movieDoc = await movieRef.get();
    if (movieDoc.exists) {
      final ratings = Map<String, dynamic>.from(movieDoc['ratings'] ?? {});
      ratings[user.uid] = rating;

      final averageRating = ratings.values.fold<double>(
            0.0,
            (sum, r) => sum + (r as double),
          ) /
          ratings.length;

      await movieRef.update({
        'ratings': ratings,
        'averageRating': averageRating,
      });
    } else {
      await movieRef.set({
        'ratings': {user.uid: rating},
        'averageRating': rating,
      });
    }

    setState(() {
      userRating = rating;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating submitted!')),
    );
  }

  void showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempRating = userRating;
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
                  }));
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                rateMovie(tempRating);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.blue),
              ),
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
                      imageUrl: movie.backdropPath != null &&
                              movie.backdropPath.isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 10, right: 10),
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
                        // Average Rating
                        FutureBuilder<double>(
                          future: averageRatingFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Failed to load average rating',
                                style: TextStyle(color: Colors.grey),
                              );
                            } else {
                              final averageRating = snapshot.data!;
                              if (averageRating > 0) {
                                return Text(
                                  'Average Rating: ${averageRating.toStringAsFixed(1)} / 5',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                return Text(
                                  'No one rated this movie yet',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<Map<String, dynamic>>(
                          future: ratingsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Failed to load ratings',
                                style: TextStyle(color: Colors.grey),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              final ratings = snapshot.data!;
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 120,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: ratings.entries.map((entry) {
                                      final userId = entry.key;
                                      final userRating = entry.value as double;

                                      return Container(
                                        width: 180,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.account_circle,
                                              size: 40,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              userId,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children:
                                                  List.generate(5, (index) {
                                                return Icon(
                                                  index < userRating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 18,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }
                            return const Text(
                              'No ratings available.',
                              style: TextStyle(color: Colors.grey),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: showRatingDialog,
                          child: const Text(
                            'RATE MOVIE',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: toggleWatchlist,
                          child: Text(
                            isAddedToWatchlist
                                ? 'ADDED TO WATCHLIST'
                                : 'ADD TO WATCHLIST',
                            style: TextStyle(color: Colors.blue),
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
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              itemCount: recommendations.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 15,
                                childAspectRatio: 2 / 3,
                              ),
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                if (movie.id != 0 &&
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

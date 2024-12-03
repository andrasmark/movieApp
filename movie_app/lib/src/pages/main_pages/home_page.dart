import 'package:flutter/material.dart';
import 'package:movie_app/src/services/api.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../components/NavBar.dart';
import '../../services/firebase.dart';
import 'movies_page.dart';
import '../../../models/movie_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String id = 'home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;

  late Future<List<Movie>> popularMovies;
  late Future<List<Movie>> upcomingMovies;
  late Future<List<Movie>> topRatedMovies;

  @override
  void initState() {
    upcomingMovies = Api().getUpcomingMovies();
    topRatedMovies = Api().getTopRatedMovies();
    popularMovies = Api().getPopularMovies();
    
    getIds();
    super.initState();
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
      switch (index) {
        case 1:
          Navigator.pushReplacementNamed(context, MoviesPage.id);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, SocialPage.id);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, ProfilePage.id);
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        titleTextStyle: const TextStyle(
          fontSize: 25,
          fontFamily: 'Moderustic',
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming',
                style: TextStyle(color: Colors.black),
              ),
              FutureBuilder<List<Movie>>(
                future: upcomingMovies,
                builder: (context, snaphot) {
                  if (!snaphot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final movies = snaphot.data!;
                  return CarouselSlider.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index, moviesIndex) {
                      final movie = movies[index];
                      return Container(
                        width: 188,
                        margin:EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                              "https://image.tmdb.org/t/p/original/${movie.posterPath}"),
                        ),
                      );
                    },
                    options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 1.4,
                        autoPlayInterval: const Duration(seconds: 4)),
                  );
                },
              ),
              const Text(
                'Trending',
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 200,
                child: FutureBuilder<List<Movie>>(
                  future: popularMovies,
                  builder: (context, snaphot) {
                    if (!snaphot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final movies = snaphot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return Container(
                          width: 150,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              "https://image.tmdb.org/t/p/original/${movie.posterPath}",
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Text(
                'Top rated',
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 200,
                child: FutureBuilder<List<Movie>>(
                  future: topRatedMovies,
                  builder: (context, snaphot) {
                    if (!snaphot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final movies = snaphot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return Container(
                          width: 150,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              "https://image.tmdb.org/t/p/original/${movie.posterPath}",
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }
}

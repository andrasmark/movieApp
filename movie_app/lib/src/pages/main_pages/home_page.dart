import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'movies_page.dart';

import '../../components/NavBar.dart';
import '../../services/firebase.dart';
import '../../components/MovieCardWidget.dart';
import '../../models/movie_model.dart';
import 'package:movie_app/src/services/api.dart';

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

    //getIds();
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<List<Movie>>(
                  future: upcomingMovies,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final movies = snapshot.data!;
                    return CarouselSlider.builder(
                      itemCount: movies.length,
                      itemBuilder: (context, index, realIndex) {
                        final movie = movies[index];
                        return MovieCardWidget(movie: movie);
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 1.4,
                        autoPlayInterval: const Duration(seconds: 4),
                      ),
                    );
                  },
                ),
                const Text(
                  'Trending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 200,
                  child: FutureBuilder<List<Movie>>(
                    future: popularMovies,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return MovieCardWidget(movie: movie);
                        },
                      );
                    },
                  ),
                ),
                const Text(
                    'Top rated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 200,
                  child: FutureBuilder<List<Movie>>(
                    future: topRatedMovies,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return MovieCardWidget(movie: movie);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }

}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/src/models/movie_model.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'package:movie_app/src/services/api.dart';
import 'package:movie_app/src/components/NavBar.dart';
import 'package:movie_app/src/components/MovieCardWidget.dart';

class MoviesPage extends StatefulWidget {
  static String id = 'movies_page';

  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final int _selectedIndex = 1;
  int? _selectedGenre;
  int? _selectedYear;
  TextEditingController searchController = TextEditingController();
  Api apiServices = Api();
  List<Map<String, dynamic>> genres = [];
  List<Movie> movies = [];
  List<Movie> searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadPopularMovies();
  }

  Future<void> _loadGenres() async {
    try {
      final genreList = await apiServices.getMovieGenres();
      setState(() {
        genres = genreList;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadPopularMovies() async {
    try {
      final trendingMovies = await apiServices.getPopularMovies();
      setState(() {
        searchResults = trendingMovies.where((movie) {
          return movie.id != 0 &&
              movie.title != 'Unknown Title' &&
              movie.backDropPath.isNotEmpty &&
              movie.posterPath.isNotEmpty &&
              movie.overview.isNotEmpty;
        }).toList();
      });
    } catch (e) {
      print(e);
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      apiServices.getPopularMovies().then((results) {
        setState(() {
          searchResults = results.where((movie) {
            return movie.id != 0 &&
                movie.title != 'Unknown Title' &&
                movie.backDropPath.isNotEmpty &&
                movie.posterPath.isNotEmpty &&
                movie.overview.isNotEmpty;
          }).toList();
        });
      });
    } else {
      apiServices.getSearchResults(query).then((results) {
        setState(() {
          searchResults = results.where((movie) {
            return movie.id != 0 &&
                movie.title != 'Unknown Title' &&
                movie.backDropPath.isNotEmpty &&
                movie.posterPath.isNotEmpty &&
                movie.overview.isNotEmpty;
          }).toList();
        });
      });
    }
  }

  Future<void> _loadMovies() async {
    try {
      if (_selectedGenre == null && _selectedYear == null) return;

      final moviesList = await apiServices.getMoviesByFilter(
        genreId: _selectedGenre,
        year: _selectedYear,
      );

      final filteredMovies = moviesList.where((movie) {
        return movie.id != 0 &&
            movie.title != 'NULL' &&
            movie.backDropPath != 'NULL' &&
            movie.backDropPath.isNotEmpty &&
            movie.posterPath != 'NULL' &&
            movie.posterPath.isNotEmpty;
      }).toList();

      setState(() {
        movies = filteredMovies;
      });
    } catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, HomePage.id);
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
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoSearchTextField(
              padding: const EdgeInsets.all(10),
              controller: searchController,
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              suffixIcon: const Icon(
                Icons.cancel,
                color: Colors.grey,
              ),
              style: const TextStyle(color: Colors.white),
              backgroundColor: Colors.grey.withOpacity(0.3),
              onChanged: (value) {
                search(value);
              },
            ),
            const SizedBox(height: 20),
            searchResults.isEmpty
                ? SizedBox(
              height: 250,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final movie = searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: MovieCardWidget(movie: movie),
                        );
                      },
                      childCount: searchResults.length,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(
              height: 250,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3 / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final movie = searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(),
                          child: MovieCardWidget(movie: movie),
                        );
                      },
                      childCount: searchResults.length,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      hint: const Text('Select Genre'),
                      value: _selectedGenre,
                      items: genres.map((genre) {
                        return DropdownMenuItem<int>(
                          value: genre['id'],
                          child: Text(genre['name']),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _selectedGenre = value;
                        });
                        _loadMovies();
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = int.tryParse(value);
                        });
                        _loadMovies();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  if (movie.id != 0 &&
                      movie.title != 'NULL' &&
                      movie.backDropPath != 'NULL' &&
                      movie.backDropPath.isNotEmpty &&
                      movie.posterPath != 'NULL' &&
                      movie.posterPath.isNotEmpty) {
                    return MovieCardWidget(movie: movie);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:movie_app/src/models/movie_model.dart';
import 'package:movie_app/src/pages/movie_details_page.dart';


class MovieCardWidget extends StatelessWidget {
  final Movie movie;

  const MovieCardWidget({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to movie details page via movieID
        Navigator.pushNamed(
          context,
          MovieDetailsPage.id,
          arguments: movie.id,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

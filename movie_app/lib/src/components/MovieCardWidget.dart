import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../pages/movie_details_page.dart'; // Update with the correct import path for MovieDetailsPage

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
          MovieDetailsPage.id, // Ensure MovieDetailsPage.id is defined
          arguments: movie.id, // Pass movie ID as an argument
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 2 / 3, // Adjust for poster dimensions
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}', // Use the poster path from the API
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

import 'package:flutter/material.dart';

class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({super.key});
  static String id = 'movie_details_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie title
            const Text(
              'Movie Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Short description
            const Text(
              'This is a short description of the movie. '
                  'It gives a brief overview of the storyline or key details.'
                  'Long test text Long test text Long test text Long test text'
                  'Long test text Long test text Long test text Long test text',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Rate movie button
            ElevatedButton(
              onPressed: () {
                //  TODO: Watchlist Button's action, implement here later
              },
              child: const Text('Rate Movie'),
            ),
            const SizedBox(height: 8),
            // Add to watchlist button
            ElevatedButton(
              onPressed: () {
                // Add functionality for watchlist here
              },
              child: const Text('Add to Watchlist'),
            ),
            const SizedBox(height: 24),
            // Actor section
            const Text(
              'Actors in the movie:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Grid view for actors
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 6, // Replace with the actual length of the actor's list
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Background color
                          border: Border.all(color: Colors.grey[500]!, width: 1), // Optional border
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Actor ${index + 1}'), // Replace with actor's name
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

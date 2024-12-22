import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> rateMovie(String movieId, double rating) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // Update user's ratedMovies
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'ratedMovies.$movieId': rating,
  });

  // Update movie's ratings and calculate new average
  final movieRef = FirebaseFirestore.instance.collection('movies').doc(movieId);
  final movieDoc = await movieRef.get();

  if (movieDoc.exists) {
    final ratings = Map<String, dynamic>.from(movieDoc['ratings'] ?? {});
    ratings[userId] = rating;

    // Calculate average rating
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
    // If movie doesn't exist, create it
    await movieRef.set({
      'ratings': {userId: rating},
      'averageRating': rating,
    });
  }
}

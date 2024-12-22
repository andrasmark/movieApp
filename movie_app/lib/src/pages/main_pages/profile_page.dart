import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/NavBar.dart';
import '../../components/rated_movie_card_widget.dart';
import '../../models/movie_details_model.dart';
import '../../services/api.dart';
import 'home_page.dart';
import 'movies_page.dart';
import 'social_page.dart';

class ProfilePage extends StatefulWidget {
  static String id = 'profile_page';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 3;
  Map<String, dynamic>? userDetails;

  List<MovieDetailsModel> ratedMoviesList = [];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, HomePage.id);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, MoviesPage.id);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, SocialPage.id);
          break;
      }
    });
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final snapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (snapshot.exists) {
          setState(() {
            userDetails = snapshot.data();

            // Initialize ratedMoviesList with the movies fetched from Firestore
            final ratedMoviesMap = snapshot['ratedMovies'] ?? {};
            ratedMoviesList = [];

            for (String movieId in ratedMoviesMap.keys) {
              // Fetch the movie details and add it to the list
              Api().getMovieDetails(int.parse(movieId)).then((movieDetail) {
                setState(() {
                  ratedMoviesList.add(movieDetail);
                });
              }).catchError((e) {
                print('Error fetching movie details: $e');
              });
            }
          });
        } else {
          print('User document does not exist in Firestore.');
        }
      } else {
        print('No user is authenticated.');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Implement Edit Profile functionality
            },
          ),
        ],
      ),
      body: userDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.account_circle, size: 100),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Username: ${userDetails?['userName'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Bio: ${userDetails?['userBio'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "My Ratings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ratedMoviesList.length,
                      itemBuilder: (context, index) {
                        final movie = ratedMoviesList[index];
                        return RatedMovieCardWidget(movie: movie);
                      },
                    ),
                  )
                ],
              ),
            ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }
}

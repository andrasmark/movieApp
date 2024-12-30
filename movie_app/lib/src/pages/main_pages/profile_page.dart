import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/NavBar.dart';
import '../../components/rated_movie_card_widget.dart';
import '../../models/movie_details_model.dart';
import '../../services/api.dart';
import '../authentication/login_page.dart';
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
  List<MovieDetailsModel> watchlist = [];

  TextEditingController userNameController = TextEditingController();
  TextEditingController userBioController = TextEditingController();

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
          final data = snapshot.data() ?? {};
          setState(() {
            userDetails = data;

            // Handle rated movies
            final ratedMoviesMap = data['ratedMovies'] ?? {};
            ratedMoviesList = [];
            for (String movieId in ratedMoviesMap.keys) {
              Api()
                  .getMovieDetails(int.tryParse(movieId) ?? 0)
                  .then((movieDetail) {
                if (movieDetail != null) {
                  setState(() {
                    ratedMoviesList.add(movieDetail);
                  });
                }
              }).catchError((e) {
                print('Error fetching rated movie details: $e');
              });
            }

            // Handle watchlist
            final watchlistMovieIds = List<int>.from(data['watchlist'] ?? []);
            watchlist = [];
            for (int movieId in watchlistMovieIds) {
              Api().getMovieDetails(movieId).then((movieDetail) {
                if (movieDetail != null) {
                  setState(() {
                    watchlist.add(movieDetail);
                  });
                }
              }).catchError((e) {
                print('Error fetching watchlist movie details: $e');
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

  void _showEditProfileDialog() {
    if (userDetails == null) return;

    // Pre-fill the text controllers with the current values
    userNameController.text = userDetails?['userName'] ?? '';
    userBioController.text = userDetails?['userBio'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(color: Colors.blue),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: userBioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 4,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                final updatedUserName = userNameController.text;
                final updatedUserBio = userBioController.text;

                // Update firestore with the new details
                final user = _auth.currentUser;
                if (user != null) {
                  try {
                    await _firestore.collection('users').doc(user.uid).update({
                      'userName': updatedUserName,
                      'userBio': updatedUserBio,
                    });

                    setState(() {
                      // Update local userDetails state
                      userDetails?['userName'] = updatedUserName;
                      userDetails?['userBio'] = updatedUserBio;
                    });

                    Navigator.pop(context);
                  } catch (e) {
                    print('Error updating user profile: $e');
                  }
                }
              },
              child: Text(
                "Save",
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
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              print('User logged out');
              Navigator.pushReplacementNamed(context, LoginPage.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out.'),
                ),
              );
            },
            icon: Icon(Icons.logout),
            color: Colors.blue,
          ),
        ],
      ),
      body: userDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Bio: ${userDetails?['userBio'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "My Ratings",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ratedMoviesList.isEmpty
                        ? Text(
                            "No rated movies yet.",
                            style: TextStyle(fontSize: 16),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: ratedMoviesList.length,
                              itemBuilder: (context, index) {
                                final movie = ratedMoviesList[index];
                                return RatedMovieCardWidget(movie: movie);
                              },
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      "My Watchlist",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    watchlist.isEmpty
                        ? Text(
                            "No movies in the watchlist yet.",
                            style: TextStyle(fontSize: 16),
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: watchlist.length,
                              itemBuilder: (context, index) {
                                final movie = watchlist[index];
                                return RatedMovieCardWidget(movie: movie);
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

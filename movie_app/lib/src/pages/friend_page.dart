import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/rated_movie_card_widget.dart';
import '../models/movie_details_model.dart';
import '../services/api.dart';
import '../services/firebase.dart';

class FriendPage extends StatefulWidget {
  final String friendId;

  FriendPage({required this.friendId});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  bool isFriend = false;
  bool isLoading = true;

  Map<String, dynamic>? friendDetails;
  List<MovieDetailsModel> ratedMoviesList = [];
  List<MovieDetailsModel> watchlist = [];

  @override
  void initState() {
    super.initState();
    fetchFriendDetails();
    checkFriendshipStatus();
  }

  Future<void> fetchFriendDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        setState(() {
          friendDetails = data;

          // Initialize ratedMoviesList
          final ratedMoviesMap = data?['ratedMovies'] ?? {};
          ratedMoviesList = [];
          for (String movieId in ratedMoviesMap.keys) {
            final movieIdInt = int.tryParse(movieId) ?? 0;
            Api().getMovieDetails(movieIdInt).then((movieDetail) {
              setState(() {
                ratedMoviesList.add(movieDetail);
              });
            }).catchError((e) {
              print('Error fetching movie details: $e');
            });
          }

          final watchlistMovieIds = (data?['watchlist'] ?? []).map((id) {
            return id is int ? id : (id as double).toInt();
          }).toList();
          watchlist = [];
          for (int movieId in watchlistMovieIds) {
            Api().getMovieDetails(movieId).then((movieDetail) {
              setState(() {
                watchlist.add(movieDetail);
              });
            }).catchError((e) {
              print('Error fetching watchlist movie details: $e');
            });
          }
        });
      } else {
        print('Friend document does not exist.');
      }
    } catch (e) {
      print('Error fetching friend details: $e');
    }
  }

  Future<void> checkFriendshipStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final friendsList = List<String>.from(userDoc.data()?['friends'] ?? []);
        setState(() {
          isFriend = friendsList.contains(widget.friendId);
          isLoading = false;
        });
      } catch (e) {
        print('Error checking friendship status: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> toggleFriendship() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isFriend) {
        await removeFriend(widget.friendId);
      } else {
        await addFriend(widget.friendId);
      }
      setState(() {
        isFriend = !isFriend;
        isLoading = false;
      });
    } catch (e) {
      print('Error toggling friendship: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend's Profile"),
        actions: [],
      ),
      body: friendDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.account_circle, size: 100),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: toggleFriendship,
                                child: Text(
                                  isFriend ? 'Remove Friend' : 'Add Friend',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Username and Bio
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Username: ${friendDetails?['userName'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Bio: ${friendDetails?['userBio'] ?? 'N/A'}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Rated Movies
                    Text(
                      "Rated Movies",
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
                    SizedBox(height: 20),
                    // Watchlist
                    Text(
                      "Watchlist",
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
    );
  }
}

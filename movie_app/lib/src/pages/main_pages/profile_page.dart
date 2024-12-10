import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/NavBar.dart';
import 'home_page.dart';
import 'movies_page.dart';
import 'social_page.dart';

class ProfilePage extends StatefulWidget {
  static String id = 'profile_page';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _selectedIndex = 3;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Fetch user details on initialization
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
        setState(() {
          userDetails = snapshot.data();
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement Edit Profile functionality
            },
          ),
        ],
      ),
      body: userDetails == null
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(Icons.account_circle, size: 100),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Username: ${userDetails?['userName'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Bio: ${userDetails?['userBio'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "My Ratings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10, // Replace with actual data count
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: const Column(
                            children: [
                              Placeholder(fallbackHeight: 60), // Movie poster
                              Text('Movie Title', textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "My Friends",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5, // Replace with actual friends count
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: Text("Friend ${index + 1}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }
}

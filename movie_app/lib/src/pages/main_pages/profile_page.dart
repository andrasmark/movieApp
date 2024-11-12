import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';

import '../../components/NavBar.dart';
import 'home_page.dart';
import 'movies_page.dart';

class ProfilePage extends StatefulWidget {
  static String id = 'profile_page';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

  void _onNavBarItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.account_circle, size: 100),
            ),
            SizedBox(height: 10),
            Text(
              "Username",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Bio or description text goes here...",
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
                itemCount: 10, // Replace with actual data count
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Placeholder(fallbackHeight: 60), // Movie poster
                        Text('Movie Title', textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "My Friends",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual friends count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.account_circle),
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

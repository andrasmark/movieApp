import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';

import '../../components/NavBar.dart';
import '../../components/friends_list.dart';
import '../../components/recommended_friends_list.dart';
import '../../components/users_with_same_taste_list.dart';
import 'movies_page.dart';

class SocialPage extends StatefulWidget {
  static String id = 'social_page';

  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final int _selectedIndex = 2;

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
        case 3:
          Navigator.pushReplacementNamed(context, ProfilePage.id);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "My Friends",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Friend list placeholder
            Container(
              height: 200,
              child: FriendsList(),
            ),
            const Text(
              "Recommended Friends",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 200,
              child: RecommendedFriendsList(),
            ),
            const Text(
              "Users who like the same movies as you",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 200,
              child: UsersWithSameTasteList(),
            )
          ],
        ),
      ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }
}

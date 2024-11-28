import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';

import '../../components/NavBar.dart';

class MoviesPage extends StatefulWidget {
  static String id = 'movies_page';

  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final int _selectedIndex = 1;

  void _onNavBarItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, HomePage.id);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, SocialPage.id);
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
      appBar: AppBar(title: const Text('Movies')),
      body: const Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Movies',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Search history",
            textAlign: TextAlign.start,
          ),
          Text('TODO'),
        ],
      ),
      bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
    );
  }
}

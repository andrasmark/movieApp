import 'package:flutter/material.dart';

import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/movies_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';

import '../../src/components/NavBar.dart';

class ActorPage extends StatefulWidget {
  static String id = 'actor_page';

  const ActorPage({super.key});

  @override
  State<ActorPage> createState() => _ActorPageState();
}

class _ActorPageState extends State<ActorPage> {
  final int _selectedIndex = 1; // Például: kijelölés a NavBar-ban

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
        case 3:
          Navigator.pushReplacementNamed(context, ProfilePage.id);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actor Name"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Implement info button functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.account_circle, size: 100),
            ),
            const SizedBox(height: 10),
            const Text(
              "Actor Name",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Short bio about the actor goes here...",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent Projects",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[300],
                    ),
                    child: const Column(
                      children: [
                        Placeholder(
                          fallbackHeight: 80,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Movie Title',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Role',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/movies_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: HomePage(),
      routes: {
        HomePage.id: (context) => HomePage(),
        MoviesPage.id: (context) => MoviesPage(),
        SocialPage.id: (context) => SocialPage(),
        ProfilePage.id: (context) => ProfilePage(),
      },
    );
  }
}

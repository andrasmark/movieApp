import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/authentication/login_page.dart';
import 'package:movie_app/src/pages/authentication/registration_page.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/movies_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'package:movie_app/src/pages/welcome_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Use system theme (light/dark)
      home: WelcomePage(),
      routes: {
        HomePage.id: (context) => HomePage(),
        MoviesPage.id: (context) => MoviesPage(),
        SocialPage.id: (context) => SocialPage(),
        ProfilePage.id: (context) => ProfilePage(),
        LoginPage.id: (context) => LoginPage(),
        RegistrationPage.id: (context) => RegistrationPage(),
      },
    );
  }
}

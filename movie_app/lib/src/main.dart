import 'package:flutter/material.dart';
import '../layouts/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App - KZ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        useMaterial3: true,
        canvasColor: Colors.white10,
      ),
      home: const MyHomePage(title: 'Test Home Page - KZ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const Center(
      child: Text(
        'Home Screen',
        style: TextStyle(color: Colors.white), // Change text color here
      ),
    ),
    const Center(
      child: Text(
        'Movies Screen',
        style: TextStyle(color: Colors.white),
      ),
    ),
    const Center(
      child: Text(
        'Friends Screen',
        style: TextStyle(color: Colors.white),
      ),
    ),
    const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: Colors.black26,
    );
  }
}

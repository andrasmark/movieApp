import 'package:flutter/material.dart';

BottomNavigationBar NavBar(
    int selectedIndex, void Function(int) onNavBarItemTapped) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onNavBarItemTapped,
    selectedItemColor: Colors.grey,
    unselectedItemColor: Colors.blueAccent,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
          size: 30,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.movie,
          size: 30,
        ),
        label: 'Movies',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.people,
          size: 30,
        ),
        label: 'Social',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.person,
          size: 30,
        ),
        label: 'Profile',
      ),
    ],
  );
}

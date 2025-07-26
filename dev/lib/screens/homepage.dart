import 'package:flutter/material.dart';
import 'package:bbf_app/screens/nav_pages/settings/settings.dart';
import 'package:bbf_app/screens/nav_pages/arabicschool/arabicschool.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/prayertimes.dart';
import 'package:bbf_app/screens/nav_pages/project/projects.dart';

class NavBarShell extends StatefulWidget {
  const   NavBarShell({super.key});

  @override
  State<NavBarShell> createState() => _NavBarShellState();
}

class _NavBarShellState extends State<NavBarShell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    Projects(),       // Screen 0
    PrayerTimes(),    // Screen 1
    ArabicSchool(),   // Screen 2
    Settings(),       // Screen 3
  ];

  static final List<String> _titles = <String>[
    'Projects',
    'Prayer Times',
    'Arabic School',
    'Settings',
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
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Prayer Times'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Arabic School'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

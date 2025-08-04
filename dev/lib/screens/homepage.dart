import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/nav_pages/settings/settings.dart';
import 'package:bbf_app/screens/nav_pages/arabicschool/arabicschool.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/prayertimes.dart';
import 'package:bbf_app/screens/nav_pages/project/projects.dart';
import 'package:provider/provider.dart';


class NavBarShell extends StatefulWidget {
  const NavBarShell({super.key});

  @override
  State<NavBarShell> createState() => _NavBarShellState();
}



class _NavBarShellState extends State<NavBarShell> {
  final AuthService authService = AuthService();
  final SettingsService firestoreService = SettingsService();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserTheme();
  }

  // get the theme from backend and set it accordingly
  // TODO: In the future, the theme should be loaded when the app is initialized.
  Future<void> _loadUserTheme() async {
    final user = authService.currentUser;
    if (user != null) {
      final String mode = await firestoreService.getUserThemeMode();
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.setTheme(mode);
    }
  }


  static final List<Widget> _pages = <Widget>[
    Projects(),       // Screen 0
    PrayerTimes(),    // Screen 1
    ArabicSchool(),   // Screen 2
    Settings(),       // Screen 3
  ];

  static final List<String> _titles = <String>[
    'Projekte',
    'Gebetszeiten',
    'Arabische Schule',
    'Einstellungen',
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projekte'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Gebetszeiten'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Arabische Schule'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}

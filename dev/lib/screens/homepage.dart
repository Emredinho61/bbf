import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/screens/nav_pages/qiblah/qiblah.dart';
import 'package:bbf_app/screens/nav_pages/settings/settings.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/nav_pages/arabicschool/arabicschool.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/prayertimes_tab/prayertimes.dart';
import 'package:bbf_app/screens/nav_pages/project/projects.dart';
import 'package:provider/provider.dart';

class NavBarShell extends StatefulWidget {
  const NavBarShell({super.key});

  @override
  State<NavBarShell> createState() => _NavBarShellState();
}

class _NavBarShellState extends State<NavBarShell> {
  final AuthService authService = AuthService();
  final SettingsService settingsService = SettingsService();

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserTheme();
  }

  // get the theme from backend and set it accordingly
  Future<void> _loadUserTheme() async {
    final user = authService.currentUser;
    if (user != null) {
      final String mode = await settingsService.getUserThemeMode();
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.setTheme(mode);
    }
  }

  static final List<Widget> _pages = <Widget>[
    Projects(),
    ArabicSchool(),
    PrayerTimes(),
    SettingsPage(),
    CompassWithQiblah(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: isDark ? Colors.grey.shade700 : Colors.green.shade200,
        color: isDark ? Colors.grey.shade800 : Colors.green.shade300,
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          _onItemTapped(index);
        },
        items: [
          Icon(Icons.work),
          Icon(Icons.school),
          Icon(Icons.access_time, size: 30,),
          Icon(Icons.settings),
          Icon(Icons.compass_calibration),
        ],
      ),
    );
  }
}

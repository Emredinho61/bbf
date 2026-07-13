import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/screens/nav_pages/project/projects_page.dart';
import 'package:bbf_app/screens/nav_pages/qiblah/qiblah.dart';
import 'package:bbf_app/screens/nav_pages/settings/settings.dart';
import 'package:bbf_app/screens/nav_pages/donations/donation_main.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/prayertimes_tab/prayertimes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    AllProjects(),
    DonationOverview(),
    PrayerTimes(),
    CompassWithQiblah(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isActive(int index) {
    return _selectedIndex == index;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? BColors.navbarDark : BColors.navbarLight;
    final inactiveColor = isDark ? Colors.grey.shade200 : Colors.grey.shade800;
    final activeColor = isDark ? BColors.primary : BColors.primary;

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurvedNavigationBar(
            index: _selectedIndex,
            backgroundColor: Colors.transparent,
            color: backgroundColor,
            buttonBackgroundColor: activeColor,
            animationDuration: const Duration(milliseconds: 350),
            onTap: _onItemTapped,
            items: [
              Icon(
                Icons.work_outline,
                color: _isActive(0) ? Colors.white : inactiveColor,
              ),
              Icon(
                Icons.construction,
                color: _isActive(1) ? Colors.white : inactiveColor,
              ),
              Icon(
                Icons.access_time_outlined,
                size: 30.sp,
                color: _isActive(2) ? Colors.white : inactiveColor,
              ),
              Icon(
                Icons.explore_outlined,
                color: _isActive(3) ? Colors.white : inactiveColor,
              ),
              Icon(
                Icons.menu_outlined,
                color: _isActive(4) ? Colors.white : inactiveColor,
              ),
            ],
          ),
          // Fills the Android system navigation bar area so it doesn't
          // overlap with the app nav bar on edge-to-edge Android devices.
          Container(
            height: MediaQuery.viewPaddingOf(context).bottom,
            color: backgroundColor,
          ),
        ],
      ),
    );
  }
}

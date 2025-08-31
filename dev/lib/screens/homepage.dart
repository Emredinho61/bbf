import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/screens/nav_pages/settings/settings.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
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
  final SettingsService settingsService = SettingsService();

  int _selectedIndex = 0;

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
    PrayerTimes(), // Screen 0
    Projects(), // Screen 1
    ArabicSchool(), // Screen 2
    SettingsPage(), // Screen 3
  ];

  // static final List<String> _titles = <String>[
  //   'Projekte',
  //   'Gebetszeiten',
  //   'Arabische Schule',
  //   'Einstellungen',
  // ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      //TODO: Reconsider the implementation of an AppBar, maybe not necessary
      // appBar: AppBar(title: Text(_titles[_selectedIndex]), centerTitle: true),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: isDark ? Colors.grey.shade700 : Colors.green.shade200,
        color: isDark ? Colors.grey.shade800 : Colors.green.shade300,
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          _onItemTapped(index);
        },
        items: [
          Icon(Icons.access_time),
          Icon(Icons.work),
          Icon(Icons.school),
          Icon(Icons.settings),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projekte'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.access_time),
      //       label: 'Gebetszeiten',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.school),
      //       label: 'Bildung',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Einstellungen',
      //     ),
      //   ],
      // ),
    );
  }
}

// class BottomNavWithAnimatedIconState extends StatefulWidget {
//   const BottomNavWithAnimatedIconState({super.key});

//   @override
//   State<BottomNavWithAnimatedIconState> createState() =>
//       __BottomNavWithAnimatedIconStateState();
// }

// class __BottomNavWithAnimatedIconStateState
//     extends State<BottomNavWithAnimatedIconState> {
//   int _selectedIndex = 0;

//   List<SMIBool> riveIconInputs = [];
//   static final List<Widget> _pages = <Widget>[
//     Projects(), // Screen 0
//     PrayerTimes(), // Screen 1
//     ArabicSchool(), // Screen 2
//     SettingsPage(), // Screen 3
//   ];
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           padding: EdgeInsets.all(12),
//           margin: EdgeInsets.symmetric(horizontal: 24),
//           decoration: BoxDecoration(
//             color: Color(0xFF17203A),
//             borderRadius: BorderRadius.all(Radius.circular(24)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: List.generate(
//               bottomNavItems.length,
//               (index) => GestureDetector(
//                 onTap: () {
//                   _onItemTapped(index);
//                   riveIconInputs[index].change(true);
//                   Future.delayed(Duration(seconds: 1), () {
//                     riveIconInputs[index].change(false);
//                   });
//                 },
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [

//                     AnimatedBar(isActive: index == _selectedIndex),
//                     SizedBox(
//                       height: 36,
//                       width: 36,
//                       child: Opacity(
//                         opacity: index == _selectedIndex ? 1.0 : 0.5,
//                         child: RiveAnimation.asset(
//                           bottomNavItems[index].rive.src,
//                           artboard: bottomNavItems[index].rive.artboard,
//                           onInit: (artboard) {
//                             StateMachineController? controller =
//                                 StateMachineController.fromArtboard(
//                                   artboard,
//                                   bottomNavItems[index].rive.stateMachineName,
//                                 );

//                             artboard.addController(controller!);
//                             riveIconInputs.add(
//                               controller.findInput<bool>('active') as SMIBool,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AnimatedBar extends StatelessWidget {
//   AnimatedBar({
//     super.key,
//     required this.isActive,
//   });
//   late bool isActive = isActive;
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//     margin: EdgeInsets.only(bottom: 2),
//     height: 4,
//      width: isActive ? 20 : 0,
//       decoration: BoxDecoration(
//         color: BColors.primary,
//          borderRadius: BorderRadius.all(Radius.circular(12))),);
//   }
// }

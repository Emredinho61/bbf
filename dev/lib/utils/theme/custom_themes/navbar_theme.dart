import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class BBottomNavBarTheme {
  static BottomNavigationBarThemeData bottomNavigationBarLightTheme =
      BottomNavigationBarThemeData(
        backgroundColor: BColors.navbarLight,
        unselectedItemColor: Colors.grey,
        selectedItemColor: BColors.primary,
      );

  static BottomNavigationBarThemeData bottomNavigationBarDarkTheme =
      BottomNavigationBarThemeData(
        backgroundColor: BColors.navbarDark,
        unselectedItemColor: Colors.grey.shade200,
        selectedItemColor: BColors.primary,
      );
}

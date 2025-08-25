import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/card_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/navbar_theme.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/utils/theme/custom_themes/elevate_button_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/text_field_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/text_theme.dart';

class BAppTheme
{
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter 
    fontFamily: 'Poppins', 
    brightness: Brightness.light,
    // scaffoldBackgroundColor: Colors.grey.shade300,
    appBarTheme: AppBarTheme(backgroundColor: BColors.appbarLight, elevation: 3, shadowColor: BColors.primary),
    // bottomNavigationBarTheme: BBottomNavBarTheme.bottomNavigationBarLightTheme,
    cardTheme: BCardTheme.cardLightThemeData,
    textTheme: BTextTheme.lightTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: BTextFieldTheme.inputDecorationLightTheme,
    bottomSheetTheme: BBottomSheetTheme.lightBottomSheetThemeData
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter 
    fontFamily: 'Poppins', 
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade800,
    appBarTheme: AppBarTheme(backgroundColor: BColors.appbarDark, elevation: 3, shadowColor: BColors.primary),
    // bottomNavigationBarTheme: BBottomNavBarTheme.bottomNavigationBarDarkTheme,
    cardTheme: BCardTheme.cardDarkThemeData,
    textTheme: BTextTheme.darkTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: BTextFieldTheme.inputDecorationDarkTheme,
    bottomSheetTheme: BBottomSheetTheme.darkBottomSheetThemeData,
  );

}
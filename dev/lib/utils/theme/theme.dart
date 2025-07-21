import 'package:flutter/material.dart';
import 'package:namer_app/utils/theme/custom_themes/elevate_button_theme.dart';
import 'package:namer_app/utils/theme/custom_themes/text_theme.dart';

class BAppTheme
{
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter 
    fontFamily: 'Poppins', 
    brightness: Brightness.light,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.grey.shade300,
    textTheme: BTextTheme.lightTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.lightElevatedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter 
    fontFamily: 'Poppins', 
    brightness: Brightness.dark,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.grey.shade800,
    textTheme: BTextTheme.darkTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.darkElevatedButtonTheme,
  );

}
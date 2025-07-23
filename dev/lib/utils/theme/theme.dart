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
    scaffoldBackgroundColor: Colors.grey.shade300,
    textTheme: BTextTheme.lightTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: BTextFieldTheme.inputDecorationTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter 
    fontFamily: 'Poppins', 
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade800,
    textTheme: BTextTheme.darkTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.darkElevatedButtonTheme,
  );

}
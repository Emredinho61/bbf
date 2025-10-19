import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/card_theme.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/utils/theme/custom_themes/elevate_button_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/text_field_theme.dart';
import 'package:bbf_app/utils/theme/custom_themes/text_theme.dart';

class BAppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // latest Material Design in Flutter
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    cardTheme: BCardTheme.cardLightThemeData,
    textTheme: BTextTheme.lightTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: BTextFieldTheme.inputDecorationLightTheme,
    bottomSheetTheme: BBottomSheetTheme.lightBottomSheetThemeData,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade800,
    appBarTheme: AppBarTheme(
      elevation: 3,
      shadowColor: BColors.primary,
    ),
    cardTheme: BCardTheme.cardDarkThemeData,
    textTheme: BTextTheme.darkTextTheme,
    elevatedButtonTheme: BElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: BTextFieldTheme.inputDecorationDarkTheme,
    bottomSheetTheme: BBottomSheetTheme.darkBottomSheetThemeData,
  );
}

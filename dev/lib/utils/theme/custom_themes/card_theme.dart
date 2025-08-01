import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class BCardTheme
{
  static CardThemeData cardLightThemeData = CardThemeData(
    shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), 
          side: BorderSide(color: BColors.primary),),
    elevation: 4, 
    color: BColors.cardLight
  );

  static CardThemeData cardDarkThemeData = CardThemeData(
    shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), 
          side: BorderSide(color: BColors.primary),),
    elevation: 4, 
    color: BColors.cardDark
  );
}
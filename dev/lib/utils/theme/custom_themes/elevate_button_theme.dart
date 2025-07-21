import 'package:flutter/material.dart';

class BElevatedButtonTheme 
{
  BElevatedButtonTheme._();

  static ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 3, 
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 151, 186, 124), 
      disabledForegroundColor: Colors.grey, 
      disabledBackgroundColor: Colors.grey,
      side: const BorderSide(color: Colors.green), 
      padding: EdgeInsets.symmetric(vertical: 10), 
      textStyle: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      )
    );

    static ElevatedButtonThemeData darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom( 
      elevation: 3, 
      foregroundColor: Colors.white,
      backgroundColor: Colors.green, 
      disabledForegroundColor: Colors.grey, 
      disabledBackgroundColor: Colors.grey,
      side: const BorderSide(color: Colors.green), 
      padding: EdgeInsets.symmetric(vertical: 10), 
      textStyle: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
}
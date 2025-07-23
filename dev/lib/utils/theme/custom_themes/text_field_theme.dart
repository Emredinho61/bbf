import 'package:flutter/material.dart';
import 'package:bbf_app/utils/constants/colors.dart';

class BTextFieldTheme
{
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    labelStyle: TextStyle().copyWith(fontSize:14, color: Colors.black), 
    hintStyle: TextStyle().copyWith(fontSize:14, color: Colors.black),
    errorStyle: TextStyle().copyWith(fontStyle: FontStyle.normal),

    border: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color:Colors.grey),
    ),

    enabledBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color:Colors.grey),
    ),

    focusedBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color: BColors.primary),
    ),

    errorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color:Colors.red),
    ),

    focusedErrorBorder: OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(width: 1, color:Colors.orange),
    ),


  );
}
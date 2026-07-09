import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    // copyWith: vorhandene TextStyle wird kopiert,
    // und es werden gezielt einzelne Eigenschaft verändert
    headlineLarge: TextStyle().copyWith(
      fontSize: 32.0.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: TextStyle().copyWith(
      fontSize: 24.0.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    headlineSmall: TextStyle().copyWith(
      fontSize: 22.0.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodyLarge: TextStyle().copyWith(
      fontSize: 18.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 16.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 14.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelLarge: TextStyle().copyWith(
      fontSize: 12.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 10.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: 8.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(
      fontSize: 32.0.sp,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle().copyWith(
      fontSize: 24.0.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    headlineSmall: TextStyle().copyWith(
      fontSize: 24.0.sp,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodyLarge: TextStyle().copyWith(
      fontSize: 18.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: TextStyle().copyWith(
      fontSize: 16.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodySmall: TextStyle().copyWith(
      fontSize: 14.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelLarge: TextStyle().copyWith(
      fontSize: 12.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelMedium: TextStyle().copyWith(
      fontSize: 10.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    labelSmall: TextStyle().copyWith(
      fontSize: 8.0.sp,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  );
}

import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class BBottomSheetTheme
{
  static BottomSheetThemeData lightBottomSheetThemeData = BottomSheetThemeData(
    backgroundColor: BColors.secondary,
  );

  static BottomSheetThemeData darkBottomSheetThemeData = BottomSheetThemeData(
    backgroundColor: Colors.grey.shade800,
  );
}
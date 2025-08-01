import 'package:bbf_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = BAppTheme.lightTheme;
  ThemeData get themeData => _themeData;

  void setTheme(String mode) {
    if (mode == 'dark') {
      _themeData = BAppTheme.darkTheme;
    } else {
      _themeData = BAppTheme.lightTheme;
    }
    notifyListeners();
  }
  
  void toggleTheme()
  {
    if(_themeData == BAppTheme.lightTheme)
    {
      _themeData = BAppTheme.darkTheme;
    }
    else 
    {
      _themeData = BAppTheme.lightTheme;
    }
    notifyListeners();
  }

  
}
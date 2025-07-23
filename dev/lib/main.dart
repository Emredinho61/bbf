// lib/main.dart

import 'package:flutter/material.dart';
import 'package:bbf_app/screens/validation/welcome.dart';
import 'package:bbf_app/utils/theme/theme.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) 
  {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: BAppTheme.lightTheme, 
      darkTheme: BAppTheme.darkTheme,
      home: Welcome(),
    );
  }
}

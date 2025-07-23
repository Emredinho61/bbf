// lib/main.dart

import 'package:flutter/material.dart';
import 'package:namer_app/screens/homepage.dart';
import 'package:namer_app/screens/validation/welcome.dart';
import 'package:namer_app/utils/theme/theme.dart';

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
      routes: {
        '/homepage': (context) => HomePage()
      },
    );
  }
}

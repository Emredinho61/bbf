// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:namer_app/utils/theme/theme.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) 
  {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: BAppTheme.lightTheme, 
      darkTheme: BAppTheme.darkTheme,
    );
  }
}

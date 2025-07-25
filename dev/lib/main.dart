// lib/main.dart

import 'package:bbf_app/screens/nav_pages/project/projects.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/screens/validation/welcome.dart';
import 'package:bbf_app/utils/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
} 


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
        '/homepage': (context) => HomePage(),
        '/projects' : (context) => Projects()
      },
    );
  }
}

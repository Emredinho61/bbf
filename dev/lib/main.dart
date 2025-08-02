// lib/main.dart
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/screens/validation/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';


main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp()));
} 


class MyApp extends StatelessWidget {
  final SettingsService firestoreService = SettingsService(); 
  @override
  Widget build(context) 
  {
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData, 
      home: AuthPage(),
      routes: {
        '/homepage': (context) => NavBarShell(),

      },
    );
  }
}

// lib/main.dart
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/workmanager_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/screens/validation/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:workmanager/workmanager.dart';

main() async {
  final now = DateTime.now();
  final nextMidnight = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: 1));
  final initialDelay = nextMidnight.difference(now);
  WidgetsFlutterBinding.ensureInitialized();
  await permissionNotification();
  await initializeNotification();
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
  "1",
  prayerNotificationTask,
  frequency: Duration(hours: 24),
  initialDelay: Duration(seconds: 10),
  constraints: Constraints(
    networkType: NetworkType.notRequired,
  ),
);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

Future<void> permissionNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestExactAlarmsPermission();
}

Future<void> initializeNotification() async {
  NotificationServices notificationServices = NotificationServices();
  await notificationServices.initNotification();
}

class MyApp extends StatelessWidget {
  final SettingsService firestoreService = SettingsService();
  @override
  Widget build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: AuthPage(),
      routes: {
        '/homepage': (context) => NavBarShell(),
        '/authpage': (context) => AuthPage(),
      },
    );
  }
}

// lib/main.dart
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/screens/validation/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferencesService.instance.initPrefs();

  await AndroidAlarmManager.initialize();

  // initialize App
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ask for notification permission
  await permissionNotification();

  // initialize all Notification settings
  await initializeNotification();

  FirebaseMessaging.instance.subscribeToTopic("test");

  initializeDateFormatting().then(
    (_) => runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: MyApp(),
      ),
    ),
  );

  //   final int prayerTimesId = 0;
  //   final int prePrayerTimesId = 1;

  //   final now = DateTime.now();

  //   await AndroidAlarmManager.periodic(
  //     const Duration(hours: 24),
  //     prayerTimesId,
  //     automaticNotifications,
  //     startAt: DateTime(now.year, now.month, now.day + 1),
  //   );

  //   await AndroidAlarmManager.periodic(
  //     const Duration(hours: 24),
  //     prePrayerTimesId,
  //     automaticPreNotifications,
  //     startAt: DateTime(now.year, now.month, now.day + 1),
  //   );
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

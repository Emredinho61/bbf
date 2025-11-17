// lib/main.dart
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:bbf_app/utils/helper/notification_provider.dart';
import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
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
  await setupNotifications();

  FirebaseMessaging.instance.subscribeToTopic("test");

  initializeDateFormatting().then(
    (_) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LoadingProvider()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

// Future<void> permissionNotification() async {
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   // Android 13+ Request-Permission
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >()
//       ?.requestNotificationsPermission();

//   // iOS Request-Permission
//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }

Future<void> permissionNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final android = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await android?.requestNotificationsPermission();

  await android?.requestExactAlarmsPermission();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

Future<void> setupNotifications() async {
  NotificationServices notificationServices = NotificationServices();
  PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  List<Map<String, String>> csvData = await prayerTimesHelper.loadCSV();
  await notificationServices.initNotification();
  await notificationServices.rescheduleEverything(csvData);
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

// lib/main.dart
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:bbf_app/utils/helper/notification_provider.dart';
import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/screens/validation/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  await SharedPreferencesService.instance.initPrefs();

  // initialize App
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // get prayertimes CSV file either from storage or cache
  try {
    await ensureCSVIsCached().timeout(const Duration(seconds: 6));
  } catch (e) {
    debugPrint('CSV download failed (will retry on next launch): $e');
  }

  // ask for notification permission
  await permissionNotification();

  // initialize all Notification settings
  try {
    await setupNotifications().timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Notification setup failed: $e');
  }

  FirebaseMessaging.instance.subscribeToTopic("test");
  FlutterForegroundTask.initCommunicationPort();

  initializeDateFormatting().then(
    (_) => runApp(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => LoadingProvider()),
          ],
          child: MyApp(),
        ),
      ),
    ),
  );
}

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

Future<void> ensureCSVIsCached() async {
  PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  await prayerTimesHelper.ensureCSVIsCached();
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
      home: NavBarShell(),
      routes: {
        '/homepage': (context) => NavBarShell(),
        '/authpage': (context) => AuthPage(),
      },
    );
  }
}

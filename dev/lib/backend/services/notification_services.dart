import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'package:bbf_app/utils/helper/scheduler_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  SchedulerHelper schedulerHelper = SchedulerHelper();
  List<Map<String, String>> csvData = [];
  List<String> prayerNames = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

  Future<void> initNotification() async {
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // IOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialization
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> displayNotification() async {
    // Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    // IOS
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    // Combining Android & IOS
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      'plain body',
      notificationDetails,
      payload: 'item x',
    );
  }

  Future<void> scheduledNotification(
    int id,
    String title,
    String body,
    DateTime notificationTime,
  ) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(
      notificationTime,
      tz.local,
    );
    // Only schedule if Notification is activated
    final currentSettings = schedulerHelper.getCurrentPrayerSettings(
      'notify_${title.toLowerCase()}',
    );
    if (!currentSettings) {
      print('$title notification ist deaktiviert, wird nicht geplant.');
      return;
    }

    // Only schedule if Notification is in future
    if (notificationTime.isBefore(DateTime.now())) return;

    // schedule Notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzNotificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print('Prayer scheduled for id $id at Time $notificationTime');
  }

  // schedule Notifications for the next four days
  Future<void> scheduleAllNotifications() async {
    final today = DateTime.now();
    // delete all Notifications before scheduling new once
    await flutterLocalNotificationsPlugin.cancelAll();

    // Plan the next 4 days
    for (int i = 0; i < 4; i++) {
      final day = today.add(Duration(days: i));
      await scheduleDailyPrayers(day);
    }
  } 

  Future<void> scheduleDailyPrayers(DateTime date) async {
    // loading all prayer times from csv file
    csvData = await prayerTimesHelper.loadCSV();

    // getting prayer times as Datetimes for the given day
    List<DateTime> prayerTimes = await prayerTimesHelper.getAnyDayPrayerTimesAsDateTimes(csvData, date);

    // iterate through prayerTimes and schedule them
    for (int i= 0; i < prayerNames.length; i++)
    {
      final notificationId = date.day * 10 + i;
      scheduledNotification(notificationId, prayerNames[i], 'Gebetszeit eingetroffen', prayerTimes[i]);
    }
  }

  // delete Notification
  void deleteNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Prayer Notification deleted for id $id');
  }
}

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
  List<String> prayerNames = [
    'Fajr',
    'Sunrise',
    'Dhur',
    'Asr',
    'Maghrib',
    'Isha',
  ];

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
      'notify_$title',
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

  Future<void> scheduledPreNotification(
    int id,
    String title,
    String body,
    DateTime notificationTime,
    String preLabel,
  ) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    tz.TZDateTime tzNotificationTime = tz.TZDateTime.from(
      notificationTime,
      tz.local,
    );

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
          'pre_prayer_channel',
          'Pre-Prayer Notifications',
          channelDescription: 'Notifications before prayer times',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print(
      'Pre-prayer notification scheduled: '
      '$title ($preLabel) at $notificationTime | id=$id',
    );
  }

  // schedule Notifications for the next four days
  Future<void> scheduleAllNotifications(
    List<Map<String, String>> csvData,
  ) async {
    final today = DateTime.now();

    // Plan the next 4 days
    for (int i = 0; i < 4; i++) {
      final day = today.add(Duration(days: i));
      await scheduleDailyPrayers(csvData, day);
    }
  }

  // schedule Pre Notifications for the next four days
  Future<void> scheduleAllPreNotifications(
    List<Map<String, String>> csvData,
  ) async {
    final today = DateTime.now();

    // Plan the next 4 days
    for (int i = 0; i < 4; i++) {
      final day = today.add(Duration(days: i));
      await scheduleDailyPrePrayers(csvData, day);
    }
  }

  Future<void> deleteAllNotifications() async {
    // delete all Notifications before scheduling new once
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> rescheduleEverything(List<Map<String, String>> csvData) async {
    await deleteAllNotifications();
    await scheduleAllNotifications(csvData);
    await scheduleAllPreNotifications(csvData);
  }

  Future<void> scheduleDailyPrayers(
    List<Map<String, String>> csvData,
    DateTime date,
  ) async {
    // getting prayer times as Datetimes for the given day
    List<DateTime> prayerTimes = await prayerTimesHelper
        .getAnyDayPrayerTimesAsDateTimes(csvData, date);

    // iterate through prayerTimes and schedule them
    for (int i = 0; i < prayerNames.length; i++) {
      final notificationId = date.day * 10 + i;
      scheduledNotification(
        notificationId,
        prayerNames[i],
        'Gebetszeit eingetroffen',
        prayerTimes[i],
      );
    }
  }

  // schedule Pre Prayer Notifications for a certain given day
  Future<void> scheduleDailyPrePrayers(
    List<Map<String, String>> csvData,
    DateTime date,
  ) async {
    // convert prayer times from Strings into Datetime
    List<DateTime> prayerTimes = await prayerTimesHelper
        .getAnyDayPrayerTimesAsDateTimes(csvData, date);

    final Map<String, Duration> preOptions = {
      '5 Minuten': Duration(minutes: 5),
      '10 Minuten': Duration(minutes: 10),
      '15 Minuten': Duration(minutes: 15),
      '20 Minuten': Duration(minutes: 20),
      '30 Minuten': Duration(minutes: 30),
      '45 Minuten': Duration(minutes: 45),
    };

    // iterate through every pre notification and look for which prayer the user wants a pre notification
    for (var entry in preOptions.entries) {
      final String preLabel = entry.key; // e.g '5 Minuten'
      final Duration preDuration = entry.value; // e.g 'Duration(minutes:5)'

      // now iterate through every prayer and check if user wants a prayer pre Notification
      for (int i = 0; i < prayerTimes.length; i++) {
        // get User settings for this prayer
        final userSetting = schedulerHelper.getUsersPrePrayerSettings(
          'notifyPre_${prayerNames[i]}',
        ); // e.g '10 Minuten'

        // if user settings doesnt match the current pre Time notification, skip
        if (userSetting != preLabel) continue;

        // since the current user setting matches the current pre time, then schedule a notification
        final preTime = prayerTimes[i].subtract(preDuration);

        final notificationId = date.day * 100 + i * 10 + preDuration.inMinutes;

        await scheduledPreNotification(
          notificationId,
          prayerNames[i],
          'Noch $preLabel bis ${prayerNames[i]}',
          preTime,
          preLabel,
        );
      }
    }
  }

  // delete Notification
  void deleteNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Prayer Notification deleted for id $id');
  }
}

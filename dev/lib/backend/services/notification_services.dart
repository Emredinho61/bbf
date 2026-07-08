import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
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

  // ------------------------------- Notifications for Prayers -----------------------------

  // schedule a single prayer notification
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

  // schedule a single pre notification
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

  // Cancels and reschedules only the notifications for a single prayer,
  // leaving all other prayers' notifications untouched.
  Future<void> rescheduleSinglePrayer(
    String prayerName,
    List<Map<String, String>> csvData,
  ) async {
    final int prayerIndex = prayerNames.indexOf(prayerName);
    if (prayerIndex == -1) return;

    final today = DateTime.now();

    for (int dayOffset = 0; dayOffset < 4; dayOffset++) {
      final day = today.add(Duration(days: dayOffset));

      // Cancel this prayer's main notification
      final prayerId = day.day * 10 + prayerIndex;
      await flutterLocalNotificationsPlugin.cancel(prayerId);

      // Cancel all possible pre-prayer notification IDs for this prayer
      for (final minutes in [5, 10, 15, 20, 30, 45]) {
        await flutterLocalNotificationsPlugin.cancel(
          day.day * 100 + prayerIndex * 10 + minutes,
        );
      }

      // Reschedule the main prayer notification
      final List<DateTime> prayerTimes =
          await prayerTimesHelper.getAnyDayPrayerTimesAsDateTimes(csvData, day);
      if (prayerIndex >= prayerTimes.length) continue;

      await scheduledNotification(
        prayerId,
        getNotificationTitleForPrayer(prayerName),
        getNotificationBodyForPrayer(prayerName),
        prayerTimes[prayerIndex],
      );

      // Reschedule the pre-prayer notification if one is set
      final userSetting =
          schedulerHelper.getUsersPrePrayerSettings('notifyPre_$prayerName');
      final Map<String, Duration> preOptions = {
        '5 Minuten': const Duration(minutes: 5),
        '10 Minuten': const Duration(minutes: 10),
        '15 Minuten': const Duration(minutes: 15),
        '20 Minuten': const Duration(minutes: 20),
        '30 Minuten': const Duration(minutes: 30),
        '45 Minuten': const Duration(minutes: 45),
      };
      final preDuration = preOptions[userSetting];
      if (preDuration == null) continue; // 'Keine' → nothing to schedule

      final preId = day.day * 100 + prayerIndex * 10 + preDuration.inMinutes;
      await scheduledPreNotification(
        preId,
        getNotificationTitleForPrePrayer(prayerName, userSetting),
        getNotificationBodyForPrePrayer(prayerName, userSetting),
        prayerTimes[prayerIndex].subtract(preDuration),
        userSetting,
      );
    }
  }

  // schedule Notifications for a certain given day
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
        getNotificationTitleForPrayer(prayerNames[i]),
        getNotificationBodyForPrayer(prayerNames[i]),
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
          getNotificationTitleForPrePrayer(prayerNames[i], preLabel),
          getNotificationBodyForPrePrayer(prayerNames[i], preLabel),
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

  // get suitable notification title for prayers
  String getNotificationTitleForPrayer(String prayerName) {
    if (prayerName == 'Sunrise') {
      return 'Die Sonne ist aufgegangen 🌞';
    }
    return 'Es ist Zeit für das $prayerName Gebet 🕌';
  }

  // get suitable notification body for prayers
  String getNotificationBodyForPrayer(String prayerName) {
    if (prayerName == 'Sunrise') {
      return 'Hast du das Fajr Gebet verrichtet ?';
    }
    return 'Versuche, dein Gebet pünktlich zu verrichten.';
  }

  // get suitable notification Title for pre prayers
  String getNotificationTitleForPrePrayer(String prayerName, String preTime) {
    if (prayerName == 'Sunrise') {
      return '⏳ Noch $preTime bis zum Sonnenaufgang';
    }
    return '⏳ Noch $preTime bis $prayerName';
  }

  // get suitable notification body for pre prayers
  String getNotificationBodyForPrePrayer(String prayerName, String preTime) {
    if (prayerName == 'Fajr') {
      return 'Bereite dich auf das Fajr Gebet vor.';
    }
    return 'Nicht zu lange verzögern — das Gebet wartet auf dich.';
  }

  //------------------------------ Notifications for Events -----------------------------

  // Derives a stable notification id from an event's id and the date of the
  // specific occurrence it belongs to. Since a repeating event has the same
  // id for every occurrence, the date is part of the hash so each occurrence
  // gets its own id and can be scheduled/cancelled independently. The id is
  // offset away from the small int ranges used by the prayer notifications
  // above so the two don't collide.
  int getEventNotificationId(String eventId, DateTime eventDate) {
    final dateKey = '${eventDate.year}-${eventDate.month}-${eventDate.day}';
    final hash = Object.hash(eventId, dateKey);
    return 1000000 + (hash.abs() % 100000000);
  }

  // Schedules a reminder notification for a single occurrence of a calendar
  // event, firing 24 hours before it starts.
  Future<void> scheduleEventNotification(
    String eventId,
    String eventTitle,
    DateTime eventDate,
    int beginHour,
    int beginMinute,
  ) async {
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      beginHour,
      beginMinute,
    );
    final notificationTime = eventDateTime.subtract(const Duration(hours: 24));

    // Only schedule if the reminder would fire in the future
    if (notificationTime.isBefore(DateTime.now())) {
      print(
        'Notification für Event "$eventTitle" am $eventDate liegt in der '
        'Vergangenheit, wird nicht geplant.',
      );
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    final notificationId = getEventNotificationId(eventId, eventDate);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Morgen: $eventTitle',
      'Das Event "$eventTitle" findet morgen statt.',
      tzNotificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Event Notifications',
          channelDescription: 'Erinnerungen an Kalender-Events',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print(
      'Event-Notification geplant: "$eventTitle" am $eventDate '
      '(id=$notificationId) für $tzNotificationTime',
    );
  }

  // Schedules reminder notifications for every future occurrence of the
  // event identified by [eventId] (its title). Reuses CalendarService's
  // getAllEvents(), which already resolves repeat/frequency/exceptions into
  // one DateTime per occurrence, so the repetition rules don't get
  // duplicated here.
  Future<void> scheduleAllFutureEventNotifications(String eventId) async {
    final CalendarService calendarService = CalendarService();
    final Map<DateTime, List<Event>> allEvents = await calendarService
        .getAllEvents();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    for (final entry in allEvents.entries) {
      final eventDate = entry.key;

      // skip occurrences that already happened
      if (eventDate.isBefore(startOfToday)) continue;

      for (final event in entry.value) {
        if (event.id != eventId) continue;

        // event.time has the format "HH:mm - HH:mm"
        final beginTimeStr = event.time.split(' - ').first;
        final beginTimeParts = beginTimeStr.split(':');
        final beginHour = int.parse(beginTimeParts[0]);
        final beginMinute = int.parse(beginTimeParts[1]);

        await scheduleEventNotification(
          event.id,
          event.title,
          eventDate,
          beginHour,
          beginMinute,
        );
      }
    }
  }

  // Cancels every currently scheduled reminder notification for the event
  // identified by [eventId], across all of its occurrences (past and
  // future). Used both for the "Benachrichtigungen aus" choice and as a
  // clean slate before applying a newly chosen notification mode, so
  // switching modes never leaves stray notifications from the old mode.
  Future<void> cancelEventNotifications(String eventId) async {
    final CalendarService calendarService = CalendarService();
    final Map<DateTime, List<Event>> allEvents = await calendarService
        .getAllEvents();

    for (final entry in allEvents.entries) {
      final eventDate = entry.key;

      for (final event in entry.value) {
        if (event.id != eventId) continue;

        final notificationId = getEventNotificationId(eventId, eventDate);
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      }
    }
    print('Alle Event-Notifications für "$eventId" wurden gelöscht.');
  }
}
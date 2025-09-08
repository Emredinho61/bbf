import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'notification_services.dart';

PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();

NotificationServices notificationServices = NotificationServices();

@pragma('vm:entry-point')
Future<void> automaticNotifications() async {
  await prayerTimesHelper.initPrefs();
  List<DateTime> todaysPrayerTimes = await prayerTimesHelper
      .getTodaysPrayerTimesAsDateTimes();
  print("Found prayer times");
  for (int i = 0; i < todaysPrayerTimes.length; i++) {
    if (prayerTimesHelper.isNotificationEnabledWithId(i)) {
      await notificationServices.scheduledNotification(
        i,
        'Gebetszeit',
        prayerTimesHelper.notificationMessage(i),
        todaysPrayerTimes[i],
      );
      print("Scheduled notification for index $i");
    }
  }
}

@pragma('vm:entry-point')
Future<void> automaticPreNotifications() async {
  print('preNotifcations are going to be scheduled');
  await prayerTimesHelper.initPrefs();
  // List of all prePrayerNames
  List<String> prePrayerNames = [
    'preFajr',
    'preSunrise',
    'preDhur',
    'preAsr',
    'preMaghrib',
    'preIsha',
  ];

  // List of all prePrayerTimes
  List<int> prePrayerTimes = [];

  // List of all prayerNames
  List<String> prayerNames = [
    'Fajr',
    'Sunrise',
    'Dhur',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // List all prayertimes
  List<DateTime?> prayerTimes = [];

  // List of all calculated prePrayerTimes (prayerTime - prePrayerTime)
  List<DateTime?> calculatedPrePrayerTimes = [];

  // Iterate through the prePrayerNames list and get the current preTime
  for (int i = 0; i < prePrayerNames.length; i++) {
    prePrayerTimes.add(prayerTimesHelper.getPreTime(prePrayerNames[i]));
  }

  // Iterate through the prayerNames list and get the prayerTime of next day
  for (int i = 0; i < prayerNames.length; i++) {
    final prayerTime = await prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
      prayerNames[i],
    );
    prayerTimes.add(prayerTime);
  }

  // Calculate actual pre Prayer Time
  for (int i = 0; i < prePrayerNames.length; i++) {
    DateTime calculatedPrePrayerTime = prayerTimes[i]!.subtract(
      Duration(minutes: prePrayerTimes[i]),
    );

    calculatedPrePrayerTimes.add(calculatedPrePrayerTime);
    print('${prePrayerNames[i]} : ${calculatedPrePrayerTimes[i]}');
  }

  // schedule the notifications
  for (int i = 0; i < calculatedPrePrayerTimes.length; i++) {
    if (calculatedPrePrayerTimes[i] == prayerTimes[i]) {
      continue;
    }
    await notificationServices.scheduledNotification(
      prayerTimesHelper.assignIdForPrePrayerNotification(i),
      'Gebetszeit',
      'Nächstes Gebet in...',
      calculatedPrePrayerTimes[i]!,
    );
    print(
      "Scheduled notification for index $i with following Time ${calculatedPrePrayerTimes[i]}",
    );
  }
}

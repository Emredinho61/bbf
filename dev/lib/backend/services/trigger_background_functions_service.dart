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

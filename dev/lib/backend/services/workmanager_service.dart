import 'package:bbf_app/utils/helper/get_prayer_times.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

GetPrayerTimesHelper getPrayerTimesHelper = GetPrayerTimesHelper();

NotificationServices notificationServices = NotificationServices();

const String prayerNotificationTask = "dailyPrayerNotifications";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("[WorkManager] callbackDispatcher triggered for task: $task");

    tzData.initializeTimeZones();
    print("[WorkManager] Timezones initialized");

    if (task == prayerNotificationTask) {
      print("[WorkManager] Calculating today's prayer times...");
      final now = DateTime.now();
      List<DateTime> todaysPrayerTimes = [DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          20
        )];
          // await getPrayerTimesHelper.getTodaysPrayerTimes();

      print("[WorkManager] Found ${todaysPrayerTimes.length} prayer times:");
      for (int i = 0; i < todaysPrayerTimes.length; i++) {
        print(
            " - ${i}: ${todaysPrayerTimes[i].hour}:${todaysPrayerTimes[i].minute}");

        await notificationServices.scheduledNotification(
          i,
          'Erinnerung',
          'Gebetszeit',
          todaysPrayerTimes[i],
        );
        print("[WorkManager] Scheduled notification for index $i");
      }
    }

    print("[WorkManager] Task $task completed");
    return Future.value(true);
  });
}


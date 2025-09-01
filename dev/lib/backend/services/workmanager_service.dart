import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_services.dart';

PrayerTimesHelper getPrayerTimesHelper = PrayerTimesHelper();

NotificationServices notificationServices = NotificationServices();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Your background task logic goes here
    if (task == 'test') {
      print(
        "Background task is running==========================================================================================>",
      );
      List<DateTime> todaysPrayerTimes = await getPrayerTimesHelper
          .getTodaysPrayerTimesAsDateTimes();

      print("[WorkManager] Found ${todaysPrayerTimes.length} prayer times");
      for (int i = 0; i < todaysPrayerTimes.length; i++) {
        await notificationServices.scheduledNotification(
          i,
          'Erinnerung',
          'Gebetszeit',
          todaysPrayerTimes[i],
        );
        print("[WorkManager] Scheduled notification for index $i");
      }
    }
    return Future.value(true);
  });
}

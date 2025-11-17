import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/utils/helper/prayer_times_helper.dart';

class SchedulerService {
  List<Map<String, String>> csvData = [];
  PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  NotificationServices notificationServices = NotificationServices();
  List<String> prayerNames = [
    'Fajr',
    'Sunrise',
    'Dhur',
    'Asr',
    'Maghrib',
    'Isha',
  ];
  Future<void> scheduleDailyPrayers(DateTime date) async {
    // loading all prayer times from csv file
    csvData = await prayerTimesHelper.loadCSV();

    // getting prayer times as Datetimes for the given day
    List<DateTime> prayerTimes = await prayerTimesHelper
        .getAnyDayPrayerTimesAsDateTimes(csvData, date);

    // iterate through prayerTimes and schedule them
    for (int i = 0; i < prayerNames.length; i++) {
      final notificationId = date.day * 10 + i;
      notificationServices.scheduledNotification(
        notificationId,
        prayerNames[i],
        'Gebetszeit eingetroffen',
        prayerTimes[i],
      );
    }
  }
}

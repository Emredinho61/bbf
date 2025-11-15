import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class SchedulerHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  Future<void> activatePrayerNotification(String prayer) async {
    await prefsWithCache.setBool(prayer, true);
  }

   Future<void> deactivatePrayerNotification(String prayer) async {
    await prefsWithCache.setBool(prayer, false);
  }

  bool getCurrentPrayerSettings(String prayer) {
    return prefsWithCache.getBool(prayer) ?? true;
  }

}

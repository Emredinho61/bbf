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

  String getUsersPrePrayerSettings(String prayer) {
    return prefsWithCache.getString(prayer) ?? 'Keine';
  }

  Future<void> setUsersPrePrayerSettings(String prayer, String minutes) async {
    await prefsWithCache.setString(prayer, minutes);
  }

  Future<void> setAllUsersPrePrayerSettings(String minutes) async {
    List<String> allPrePrayers = [
      'notifyPre_Fajr',
      'notifyPre_Sunrise',
      'notifyPre_Dhur',
      'notifyPre_Asr',
      'notifyPre_Maghrib',
      'notifyPre_Isha',
    ];

    for (int i = 0; i < allPrePrayers.length; i++) {
      await setUsersPrePrayerSettings(allPrePrayers[i], minutes);
    }
  }

  Future<void> setAllUsersPrayerSettings(bool mode) async {
    List<String> allPrayers = [
      'notify_Fajr',
      'notify_Sunrise',
      'notify_Dhur',
      'notify_Asr',
      'notify_Maghrib',
      'notify_Isha',
    ];

    for (int i = 0; i < allPrayers.length; i++) {
      await prefsWithCache.setBool(allPrayers[i], mode);
    }
  }
}

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class SchedulerHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  Future<void> togglePrayerSettings(String prayer) async {
    final currentSettings = prefsWithCache.getBool(prayer) ?? false;
    await prefsWithCache.setBool(prayer, !currentSettings);
  }

  bool getCurrentPrayerSettings(String prayer) {
    return prefsWithCache.getBool(prayer) ?? true;
  }

}

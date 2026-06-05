import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class SettingsHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  bool getIshaSettings() {
    return prefsWithCache.getBool('ishaSettings') ?? false;
  }

  Future<void> setIshaSetting(bool ishaSettings) async {
    return prefsWithCache.setBool('ishaSettings', ishaSettings);
  }
}

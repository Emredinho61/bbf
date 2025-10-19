import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class CheckUserHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  Future<void> setCheckUsersPrefs(bool isAdmin) async {
    await prefsWithCache.setBool('userRole', isAdmin);
  }

  bool getUsersPrefs() {
    return prefsWithCache.getBool('userRole') ?? false;
  }
}

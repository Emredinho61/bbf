import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class AuthPageHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  bool isUserGuest() {
    return prefsWithCache.getBool('isUserGuest') ?? false;
  }

  Future<void> setUserAsAGuest() async {
    await prefsWithCache.setBool('isUserGuest', true);
  }

  Future<void> setGuestAsUser() async {
    await prefsWithCache.setBool('isUserGuest', false);
  }

  String getGuestsId() {
    return prefsWithCache.getString('guestId') ?? '';
  }

  Future<void> setGuestsId(String guestId) async {
    await prefsWithCache.setString('guestId', guestId);
  }
}

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class InformationPageHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  // get Status whether user opened information page or not
  bool getStatus() {
    return prefsWithCache.getBool('Status') ?? false;
  }

  // status = false means that the page was not opened since the push of a new information
  Future<void> setStatus(bool status) async {
    await prefsWithCache.setBool('Status', status);
  }
}

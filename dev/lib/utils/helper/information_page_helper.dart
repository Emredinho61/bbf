import 'dart:ffi';

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

class InformationPageHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  // save the sum number of all information
  Future<void> setTotalInformationNumber(int sum) async {
    await prefsWithCache.setInt('informationNumber', sum);
  }

  // get total sum of information
  int getTotalInformationNumber() {
    return prefsWithCache.getInt('informationNumber') ?? 0;
  }

  int getTotalInformationNumberFromBackend() {
    return prefsWithCache.getInt('informationNumberFromBackend') ?? 0;
  }

  Future<void> setTotalInformationNumberFromBackend(int sum) {
    return prefsWithCache.setInt('informationNumberFromBackend', sum);
  }

  // get Status whether user opened information page or not
  bool getStatus() {
    return prefsWithCache.getBool('Status') ?? false;
  }

  // status = false means that the page was not opened since the push of a new information
  Future<void> setStatus(bool status) async {
    await prefsWithCache.setBool('Status', status);
  }
}

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:bbf_app/utils/helper/scheduler_helper.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class PrayerTimesHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  PrayertimesService? _prayertimesService;
  SchedulerHelper schedulerHelper = SchedulerHelper();

  PrayertimesService get prayertimesService {
    _prayertimesService ??= PrayertimesService();
    return _prayertimesService!;
  }

 Future<List<Map<String, String>>> loadCSV() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/prayer_times.csv");

  final rawData = await file.readAsString();

  final lines = LineSplitter.split(rawData).toList();
  final headers = lines.first.split(',');

  final List<Map<String, String>> rows = [];

  for (var i = 1; i < lines.length; i++) {
    final values = lines[i].split(',');

    final Map<String, String> row = {};

    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = values[j];
    }

    rows.add(row);
  }

  return rows;
}


  Map<String, String> getTodaysPrayerTimesAsStringMap(
    List<Map<String, String>> csvData,
  ) {
    final now = DateTime.now();
    final todayStr = DateFormat('dd.MM.yyyy').format(now);
    final todayRow = csvData.firstWhere(
      (row) => row['Date'] == todayStr,
      orElse: () => {},
    );
    return todayRow;
  }

  Map<String, String> getAnyDayPrayerTimesAsStringMap(
    List<Map<String, String>> csvData,
    DateTime day,
  ) {
    final todayStr = DateFormat('dd.MM.yyyy').format(day);
    final todayRow = csvData.firstWhere(
      (row) => row['Date'] == todayStr,
      orElse: () => {},
    );
    return todayRow;
  }

  Map<String, String> getPrayerTimesForDay(
    List<Map<String, String>> csvData,
    DateTime givenDay,
  ) {
    final day = givenDay;
    final todayStr = DateFormat('dd.MM.yyyy').format(day);

    final todayRow = csvData.firstWhere(
      (row) => row['Date'] == todayStr,
      orElse: () => {},
    );

    final oldMap = Map<String, String>.from(todayRow);
    oldMap.remove('Date');

    final LinkedHashMap<String, String> newMap = LinkedHashMap();

    oldMap.forEach((key, value) {
      if (key == 'Sunrise') {
        newMap['Shuruq'] = value;
      } else {
        newMap[key] = value;
      }
    });

    return newMap;
  }

  Future<List<DateTime>> getTodaysPrayerTimesAsDateTimes(
    List<Map<String, String>> csvData,
  ) async {
    List<DateTime> prayerTimes = [];
    // load csv File
    // await loadCSV();

    // get todayRow
    final todayRow = getTodaysPrayerTimesAsStringMap(csvData);

    final prayerKeys = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr != null) {
        final prayerTime = convertStringTimeIntoDateTime(timeStr);
        prayerTimes.add(prayerTime);
      }
    }
    return prayerTimes;
  }

  Future<List<DateTime>> getAnyDayPrayerTimesAsDateTimes(
    List<Map<String, String>> csvData,
    DateTime date,
  ) async {
    List<DateTime> prayerTimes = [];

    // get todayRow
    final todayRow = getAnyDayPrayerTimesAsStringMap(csvData, date);

    final prayerKeys = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr != null) {
        final prayerTime = convertStringTimeIntoAnyDateTime(timeStr, date);
        prayerTimes.add(prayerTime);
      }
    }
    return prayerTimes;
  }

  DateTime convertStringTimeIntoDateTime(String timeStr) {
    final now = DateTime.now();

    final timeParts = timeStr.split(':');
    final prayerTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    return prayerTime;
  }

  DateTime convertStringTimeIntoAnyDateTime(String timeStr, DateTime date) {
    final timeParts = timeStr.split(':');
    final prayerTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    return prayerTime;
  }

  Future<DateTime?> getCertainPrayerTimeAsDateTimes(
    String name,
    List<Map<String, String>> csvData,
  ) async {
    // get todayRow
    final todayRow = getTodaysPrayerTimesAsStringMap(csvData);

    late final DateTime? prayerTime;

    final now = DateTime.now();

    final timeStr = todayRow[name];
    if (timeStr != null) {
      final timeParts = timeStr.split(':');
      prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } else {
      prayerTime = null;
    }
    return prayerTime;
  }

  int getCurrentPreTimeAsIndex(String prayerName) {
    // String currentPreTime = (prefsWithCache.get(prayerName) as String);
    String currentPreTime = schedulerHelper.getUsersPrePrayerSettings(
      prayerName,
    );
    int currentIndex = 0;
    switch (currentPreTime) {
      case 'Keine':
        currentIndex = 0;
      case '5 Minuten':
        currentIndex = 1;
      case '10 Minuten':
        currentIndex = 2;
      case '15 Minuten':
        currentIndex = 3;
      case '20 Minuten':
        currentIndex = 4;
      case '30 Minuten':
        currentIndex = 5;
      case '45 Minuten':
        currentIndex = 6;
      default:
    }
    return currentIndex;
  }

  String convertPrayerNameIntoPrePrayerName(String prayerName) {
    String prePrayerName = '';
    switch (prayerName) {
      case 'Fajr':
        prePrayerName = 'notifyPre_Fajr';
      case 'Sunrise':
        prePrayerName = 'notifyPre_Sunrise';
      case 'Dhur':
        prePrayerName = 'notifyPre_Dhur';
      case 'Asr':
        prePrayerName = 'notifyPre_Asr';
      case 'Maghrib':
        prePrayerName = 'notifyPre_Maghrib';
      case 'Isha':
        prePrayerName = 'notifyPre_Isha';
      default:
    }
    return prePrayerName;
  }

  // Since the UI is displayed as a string for the user,
  // we need to convert the String into int so we can calculate the pre Time
  int convertPreTimeStringIntoInt(String preTimeString) {
    int preTime = 0;
    switch (preTimeString) {
      case 'Keine':
        preTime = 0;
      case '5 Minuten':
        preTime = 5;
      case '10 Minuten':
        preTime = 10;
      case '15 Minuten':
        preTime = 15;
      case '20 Minuten':
        preTime = 20;
      case '30 Minuten':
        preTime = 30;
      case '45 Minuten':
        preTime = 45;
      default:
    }
    return preTime;
  }

  // returns the correct pre prayer topic based on prayer name and preTime
  String getPrePrayerTopic(String prayerName, int preTime) {
    const allowedTimes = [5, 10, 15, 20, 30, 45];
    if (allowedTimes.contains(preTime)) {
      return '$prayerName$preTime';
    }
    return '';
  }

  // if User decides to change preNotification time, then this function is updating it
  Future<void> updatePreNotification(String prayerName, int minutes) async {
    final preTimes = [5, 10, 15, 20, 30, 45];
    String prePrayerName = convertPrayerNameIntoPrePrayerName(prayerName);

    // get the current pre time
    final currentPreTime = (prefsWithCache.get(prePrayerName) as int?) ?? 0;

    // Check, if the new time is any different from the old
    // if not, return
    if (currentPreTime == minutes) return;

    await prefsWithCache.setInt(prePrayerName, minutes);
    // else unsubscribe every topic
    for (int i = 0; i < preTimes.length; i++) {
      final preTimeTopic = getPrePrayerTopic(prayerName, preTimes[i]);
      await FirebaseMessaging.instance.unsubscribeFromTopic(preTimeTopic);
      print('Unsubscribing from $preTimeTopic');
    }

    // then set the new time
    final updatedPrePrayerTopic = getPrePrayerTopic(prayerName, minutes);

    // only subscribe, if new minutes is not 0
    if (minutes != 0) {
      await FirebaseMessaging.instance.subscribeToTopic(updatedPrePrayerTopic);
      print('Subscribed to Topic: $updatedPrePrayerTopic');
    }
  }

  Future<void> updateAllPreNotifications(int minutes) async {
    final allPrayers = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
    for (String prayerName in allPrayers) {
      await updatePreNotification(prayerName, minutes);
    }
  }

  Future<void> activateNotification(String name) async {
    // first, get the current Mode
    final currentMode = (prefsWithCache.get(name) as bool?) ?? false;

    // if its already true, there is no need to activate it again
    if (currentMode == true) return;

    // if it was false, then update it to true
    final updatedMode = !currentMode;
    await prefsWithCache.setBool(name, updatedMode);

    // subscribe to topic
    await FirebaseMessaging.instance.subscribeToTopic(name);
  }

  Future<void> deactivateNotification(String name) async {
    // first, get the current Mode
    final currentMode = (prefsWithCache.get(name) as bool?) ?? false;

    // if its already false, there is no need to activate it again
    if (currentMode == false) return;

    // if it was true, then update it to false
    final updatedMode = !currentMode;
    await prefsWithCache.setBool(name, updatedMode);

    // and unsubscribe to topic
    await FirebaseMessaging.instance.unsubscribeFromTopic(name);
  }

  Future<void> activateAllNotifications() async {
    final allPrayers = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

    for (String prayerName in allPrayers) {
      await activateNotification(prayerName);
    }
  }

  Future<void> deactivateAllNotifications() async {
    final allPrayers = ['Fajr', 'Sunrise', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

    for (String prayerName in allPrayers) {
      await deactivateNotification(prayerName);
    }
  }

  // checks if the notifications are enabled for prayer times
  bool isNotificationEnabled(String prayerName) {
    return (prefsWithCache.get(prayerName) as bool?) ?? false;
  }

  String getFridaysPrayer1Preference() {
    String fridayPrayer1 =
        (prefsWithCache.get('FridaysPrayer1') as String?) ?? '';
    return fridayPrayer1;
  }

  String getFridaysPrayer2Preference() {
    String fridayPrayer2 =
        (prefsWithCache.get('FridaysPrayer2') as String?) ?? '';
    return fridayPrayer2;
  }

  String getFajrIqamaPreference() {
    String fajrIqama = (prefsWithCache.get('FajrIqama') as String?) ?? '10';
    return fajrIqama;
  }

  String getDhurIqamaPreference() {
    String dhurIqama = (prefsWithCache.get('DhurIqama') as String?) ?? '10';
    return dhurIqama;
  }

  String getAsrIqamaPreference() {
    String asrIqama = (prefsWithCache.get('AsrIqama') as String?) ?? '10';
    return asrIqama;
  }

  String getMaghribIqamaPreference() {
    String maghribIqama =
        (prefsWithCache.get('MaghribIqama') as String?) ?? '10';
    return maghribIqama;
  }

  String getIshaIqamaPreference() {
    String ishaIqama = (prefsWithCache.get('IshaIqama') as String?) ?? '10';
    return ishaIqama;
  }

  String getCertainIqamaPreference(String prayer) {
    String iqama = (prefsWithCache.get('${prayer}Iqama') as String?) ?? '10';
    return iqama;
  }

  Future<void> setIqamaPreference(String prayer, String iqamaTime) async {
    switch (prayer) {
      case 'Fajr':
        prefsWithCache.setString('FajrIqama', iqamaTime);
      case 'Dhur':
        prefsWithCache.setString('DhurIqama', iqamaTime);
      case 'Asr':
        prefsWithCache.setString('AsrIqama', iqamaTime);
      case 'Maghrib':
        prefsWithCache.setString('MaghribIqama', iqamaTime);
      case 'Isha':
        prefsWithCache.setString('IshaIqama', iqamaTime);

      default:
    }
  }

  Future<void> setFridaysPrayerPreference(String prayer, String time) async {
    switch (prayer) {
      case 'FridaysPrayer1':
        prefsWithCache.setString('FridaysPrayer1', time);
      case 'FridaysPrayer2':
        prefsWithCache.setString('FridaysPrayer2', time);
      default:
    }
  }

  Future<void> resetPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveCachedYear(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("cached_prayer_times_year", year);
  }

  Future<int?> getCachedYear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("cached_prayer_times_year");
  }

  // This function downloads the correct CSV file based on the year which is stored in firebase storage
  Future<String> downloadCSV(int year) async {
    final ref = FirebaseStorage.instance.ref().child(
      "prayer_times/prayer_times_$year.csv",
    );

    final data = await ref.getData(); // raw data
    return String.fromCharCodes(data!); // raw data converted into a readable string
  }

  // saves csv file into cache, so we dont need to download it everytime from storage, when we need to access it
  Future<void> saveCSVToCache(String csv) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/prayer_times.csv");

    await file.writeAsString(csv);
  }

  Future<void> ensureCSVIsCached() async {
    final cachedYear = await getCachedYear();

    // we check, if the file which is cached is the correct file based on the current year
    if (cachedYear == DateTime.now().year) return;

    // if its not the current year (e.g its already next year), then we need do download the new one from firebase and saved it to Cache
    final csv = await downloadCSV(DateTime.now().year);
    await saveCSVToCache(csv);

    // save that year for future checkings in the cache 
    await saveCachedYear(DateTime.now().year);
  }

}

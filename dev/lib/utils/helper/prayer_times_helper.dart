import 'dart:convert';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesHelper {
  late final SharedPreferencesWithCache prefsWithCache;
  PrayertimesService? _prayertimesService;

  PrayertimesService get prayertimesService {
    _prayertimesService ??= PrayertimesService();
    return _prayertimesService!;
  }

  Future<void> initPrefs() async {
    prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  List<Map<String, String>> csvData = [];

  Future<List<Map<String, String>>> loadCSV() async {
    final rawData = await rootBundle.loadString(
      'assets/files/csv_files/prayer_times.csv',
    ); // the data is being loaded as a string
    final lines = LineSplitter.split(
      rawData,
    ).toList(); // Seperates the data at every linebreak to strings
    // ["Tag,Fajr,Dhur,Asr,Maghrib,Isha",
    // "1,05:12,12:45,15:50,19:10,20:30",]

    final headers = lines.first.split(
      ';',
    ); // first row is being splitted at every comma
    //["Tag", "Fajr", "Dhur", "Asr", "Maghrib", "Isha"]
    final List<Map<String, String>> rows = [];

    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(
        ';',
      ); // ["1","05:12","12:45","15:50","19:10","20:30"]
      final Map<String, String> row = {};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j];
        // {
        // "Tag": "1",
        // "Fajr": "05:12",
        // "Dhur": "12:45",
        // "Asr": "15:50",
        // "Maghrib": "19:10",
        // "Isha": "20:30"
        //}
      }
      rows.add(row);
    }
    csvData = rows;
    return csvData;
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
    final prayerTimes = Map<String, String>.from(todayRow);
    prayerTimes.remove('Date');

    return prayerTimes;
  }

  Future<List<DateTime>> getTodaysPrayerTimesAsDateTimes() async {
    List<DateTime> prayerTimes = [];
    // load csv File
    await loadCSV();

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

  Future<DateTime?> getCertainPrayerTimeAsDateTimes(String name) async {
    // load csv File
    await loadCSV(); // TODO: Need to optimize, dont want to load CSV File every time

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

  // this is used for the Notification settings UI. When opening the UI, the current setted preTime should be displayed
  Future<int> getCurrentPreTimeAsIndex(String prayerName) async {
    String prePrayerName = convertPrayerNameIntoPrePrayerName(prayerName);
    int? currentPreTime = (prefsWithCache.get(prePrayerName) as int?) ?? 0;
    int currentIndex = 0;
    switch (currentPreTime) {
      case 0:
        currentIndex = 0;
      case 5:
        currentIndex = 1;
      case 10:
        currentIndex = 2;
      case 15:
        currentIndex = 3;
      case 20:
        currentIndex = 4;
      case 30:
        currentIndex = 5;
      case 45:
        currentIndex = 6;
      default:
    }
    return currentIndex;
  }

  // currently not used
  Future<void> setPrePrayerTime(String prePrayerString) async {
    int prePrayerTime = convertPreTimeStringIntoInt(prePrayerString);
    await prefsWithCache.setInt(prePrayerString, prePrayerTime);
  }

  Future<void> activateNotification(
    String name,
    int id,
    DateTime prayerTime,
  ) async {
    // first, get the current Mode
    final currentMode = (prefsWithCache.get(name) as bool?) ?? false;

    // if its already true, there is no need to activate it again
    if (currentMode == true) return;

    // if it was false, then update it to true
    final updatedMode = !currentMode;
    await prefsWithCache.setBool(name, updatedMode);

    // and schedule the notifcation
    await notificationServices.scheduledNotification(
      id,
      'Erinnerung',
      prayerTimesHelper.notificationMessage(id),
      prayerTime,
    );
  }

  String convertPrayerNameIntoPrePrayerName(String prayerName) {
    String prePrayerName = '';
    switch (prayerName) {
      case 'Fajr':
        prePrayerName = 'preFajr';
      case 'Sunrise':
        prePrayerName = 'preSunrise';
      case 'Dhur':
        prePrayerName = 'preDhur';
      case 'Asr':
        prePrayerName = 'preAsr';
      case 'Maghrib':
        prePrayerName = 'preMaghrib';
      case 'Isha':
        prePrayerName = 'preIsha';
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

  Future<void> updatePreNotification(
    String prayerName,
    DateTime prayerTime,
    int minutes,
  ) async {
    String prePrayerName = convertPrayerNameIntoPrePrayerName(prayerName);

    // get the current pre time
    final currentPreTime = (prefsWithCache.get(prePrayerName) as int?) ?? 0;

    // Check, if the new time is any different from the old
    // if not, return
    if (currentPreTime == minutes) return;

    // else set the new time
    await prefsWithCache.setInt(prePrayerName, minutes);

    // Calculate the preNotification using the actual prayerTime - the selected minutes
    DateTime prePrayerTime = prayerTime.subtract(Duration(minutes: minutes));

    // assign unique id for prePrayerTime
    final int id = convertNameIntoId(prePrayerName);

    // delete the old notification
    notificationServices.deleteNotification(id);

    // and schedule the notifcation, if the user didnt decided to choose 'Keine'
    if (minutes != 0) {
      await notificationServices.scheduledNotification(
        id,
        'Erinnerung',
        'Noch $minutes Minuten bis zum nächsten Gebet',
        prePrayerTime,
      );
    }
  }

  Future<void> deactivateNotification(String name, int id) async {
    // first, get the current Mode
    final currentMode = (prefsWithCache.get(name) as bool?) ?? false;

    // if its already false, there is no need to activate it again
    if (currentMode == false) return;

    // if it was true, then update it to false
    final updatedMode = !currentMode;
    await prefsWithCache.setBool(name, updatedMode);

    // and delete the notification
    notificationServices.deleteNotification(id);
  }

  // currently not used
  Future<void> updateNotification(
    String name,
    int id,
    DateTime prayerTime,
  ) async {
    final currentMode = (prefsWithCache.get(name) as bool?) ?? false;
    final updatedMode = !currentMode;
    await prefsWithCache.setBool(name, updatedMode);
    if (updatedMode == false) {
      notificationServices.deleteNotification(id);
    } else {
      await notificationServices.scheduledNotification(
        id,
        'Erinnerung',
        prayerTimesHelper.notificationMessage(id),
        prayerTime,
      );
    }
  }

  // checks if the notifications are enabled for prayer times
  bool isNotificationEnabled(String prayerName) {
    return (prefsWithCache.get(prayerName) as bool?) ?? false;
  }

  // checks if the notifications are enabled for pre prayer times
  bool isPreNotificationEnabled(String prePrayerName) {
    final currentPreTime = (prefsWithCache.get(prePrayerName) as int?) ?? 0;
    if (currentPreTime == 0) return false;
    return true;
  }

  // get the preTime of a certain pre Prayer Name
  int getPreTime(String prePrayerName) {
    final int preTime = (prefsWithCache.get(prePrayerName) as int?) ?? 0;
    return preTime;
  }

  bool isNotificationEnabledWithId(int id) {
    String name = '';
    switch (id) {
      case 0:
        name = 'Fajr';
      case 1:
        name = 'Sunrise';
      case 2:
        name = 'Dhur';
      case 3:
        name = 'Asr';
      case 4:
        name = 'Maghrib';
      case 5:
        name = 'Isha';
      default:
    }
    return (prefsWithCache.get(name) as bool?) ?? false;
  }

  // Assign for every Notification Case an unique id
  int convertNameIntoId(String name) {
    int id = 0;
    switch (name) {
      case 'Fajr':
        id = 0;
      case 'Sunrise':
        id = 1;
      case 'Dhur':
        id = 2;
      case 'Asr':
        id = 3;
      case 'Maghrib':
        id = 4;
      case 'Isha':
        id = 5;
      case 'preFajr':
        id = 10;
      case 'preSunrise':
        id = 11;
      case 'preDhur':
        id = 12;
      case 'preAsr':
        id = 13;
      case 'preMaghrib':
        id = 14;
      case 'preIsha':
        id = 15;
      default:
    }
    return id;
  }

  String notificationMessage(int id) {
    String message = '';
    switch (id) {
      case 0:
        message = 'Zeit für das Fajr Gebet';
      case 1:
        message = 'Die Sonne ist aufgegangen';
      case 2:
        message = 'Zeit für das Dhur Gebet';
      case 3:
        message = 'Zeit für das Asr Gebet';
      case 4:
        message = 'Zeit für das Maghrib Gebet';
      case 5:
        message = 'Zeit für das Isha Gebet';
      default:
    }
    return message;
  }

  int assignIdForPrePrayerNotification(int id) {
    int prePrayerId = 0;
    switch (id) {
      case 0:
        prePrayerId = 10;
      case 1:
        prePrayerId = 11;
      case 2:
        prePrayerId = 12;
      case 3:
        prePrayerId = 13;
      case 4:
        prePrayerId = 14;
      case 5:
        prePrayerId = 15;
      default:
    }
    return prePrayerId;
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
    String fajrIqama = (prefsWithCache.get('FajrIqama') as String?) ?? '';
    return fajrIqama;
  }

  String getDhurIqamaPreference() {
    String dhurIqama = (prefsWithCache.get('DhurIqama') as String?) ?? '';
    return dhurIqama;
  }

  String getAsrIqamaPreference() {
    String asrIqama = (prefsWithCache.get('AsrIqama') as String?) ?? '';
    return asrIqama;
  }

  String getMaghribIqamaPreference() {
    String maghribIqama = (prefsWithCache.get('MaghribIqama') as String?) ?? '';
    return maghribIqama;
  }

  String getIshaIqamaPreference() {
    String ishaIqama = (prefsWithCache.get('IshaIqama') as String?) ?? '';
    return ishaIqama;
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
}

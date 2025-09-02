import 'dart:convert';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesHelper {
  late final SharedPreferencesWithCache prefsWithCache;

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

  Future<List<DateTime>> getTodaysPrayerTimesAsDateTimes() async {
    List<DateTime> prayerTimes = [];
    // load csv File
    await loadCSV();

    // get todayRow
    final todayRow = getTodaysPrayerTimesAsStringMap(csvData);

    final now = DateTime.now();

    final prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr != null) {
        final timeParts = timeStr.split(':');
        final prayerTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
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
    await loadCSV();

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
        'Gebetszeit',
        'Erinnerung',
        prayerTime,
      );
    }
  }

  bool isNotificationEnabled(String name) {
    return (prefsWithCache.get(name) as bool?) ?? false;
  }

  bool isNotificationEnabledWithId(int id) {
    String name = '';
    switch (id) {
      case 0:
        name = 'Fajr';
      case 1:
        name = 'Dhur';
      case 2:
        name = 'Asr';
      case 3:
        name = 'Maghrib';
      case 4:
        name = 'Isha';
      default:
    }
    return (prefsWithCache.get(name) as bool?) ?? false;
  }

  int convertNameIntoId(String name) {
    int id = 0;
    switch (name) {
      case 'Fajr':
        id = 0;
      case 'Dhur':
        id = 1;
      case 'Asr':
        id = 2;
      case 'Maghrib':
        id = 3;
      case 'Isha':
        id = 4;
      default:
    }
    return id;
  }
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class GetPrayerTimesHelper {
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

  Map<String, String> _getTodaysPrayerRow() {
    final now = DateTime.now();
    final todayStr = DateFormat('dd.MM.yyyy').format(now);
    final todayRow = csvData.firstWhere(
      (row) => row['Date'] == todayStr,
      orElse: () => {},
    );
    return todayRow;
  }

  Future<List<DateTime>> getTodaysPrayerTimes() async {
    List<DateTime> prayerTimes = [];
    // load csv File
    await loadCSV();

    // get todayRow
    final todayRow = _getTodaysPrayerRow();

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
}

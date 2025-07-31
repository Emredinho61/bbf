import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrayerTimes extends StatefulWidget {
  const PrayerTimes({super.key});

  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  List<Map<String, String>> csvData = []; 
  // e.g: [{'Tag': '1', 'Fajr': '03:45', 'Dhur': '13:50', ..},{'Tag': '2', 'Fajr': '03:46', 'Dhur': '13:51', ..} ] 

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  // function to format csv to a list of maps
  Future<void> loadCSV() async {
    final rawData = await rootBundle.loadString('assets/files/data.csv');
    final lines = LineSplitter.split(rawData).toList();

    final headers = lines.first.split(','); // only first row for header (day, fajr, dhur, ..)
    final List<Map<String, String>> rows = [];

    // iterating through all the rows and for each row we will have the following map structure:
    // {'Tag': '1', 'Fajr': '03:45', 'Dhur': '13:50', ..}
    for (var i = 1; i < lines.length; i++) { // skipping the headers 
      final values = lines[i].split(','); // ['1', '03:45', ..]
      final Map<String, String> row = {};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j]; // creates key-value pairs such as {'Tag': '1', 'Fajr': '03:45', 'Dhur': '13:50', ..}
      }
      rows.add(row);
    }

    setState(() {
      csvData = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().day; // Takes the day of the current date
    
    // returns the row of the matching day
    // Type is a Map<String, String>. e.g: {'Fajr': '03:45'}
    final todayRow = csvData.firstWhere(
      (row) => row['Tag'] == today.toString(),
      orElse: () => {}, // Empty Map
    );
    return Scaffold(
      body: csvData.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text('Fajr: ${todayRow['Fajr']}'), // returns the value of key = 'Fajr'
                Text('Dhur: ${todayRow['Dhur']}'),
                Text('Asr: ${todayRow['Asr']}'),
                Text('Maghrib: ${todayRow['Maghrib']}'),
                Text('Isha: ${todayRow['Isha']}'),
              ],
            ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:hijri_calendar/hijri_calendar.dart';

class PrayerTimes extends StatefulWidget {
  const PrayerTimes({super.key});

  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  List<Map<String, String>> csvData = [];
  late Timer _timer;
  Duration timeUntilNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadCSV().then((_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Map<String, String> _getTodaysPrayerTimes() {
    final now = DateTime.now();
    final todayStr = DateFormat('dd.MM.yyyy').format(now);
    final todayRow = csvData.firstWhere(
      (row) => row['Date'] == todayStr,
      orElse: () => {},
    );
    return todayRow;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
  }

  Future<void> loadCSV() async {
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

    setState(() {
      csvData = rows;
    });
  }

  String _showNextPrayer() {
    final now = DateTime.now();

    final todayRow = _getTodaysPrayerTimes();

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
        if (prayerTime.isAfter(now)) {
          return key;
        }
      }
    }
    return 'Fajr';
  }

  bool _checkForCurrentPrayer(String prayer) {
    final now = DateTime.now();
    final todayRow = _getTodaysPrayerTimes();

    final prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
    String currentKey = "";
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
        if (now.isAfter(prayerTime)) {
          currentKey = key;
        }
      }
    }
    if (currentKey == prayer) {
      return true;
    } else if (currentKey == "" && prayer == 'Isha') {
      return true;
    }
    return false;
  }

  Duration _calculateNextPrayerDuration() {
    final now = DateTime.now();
    final tomorrowStr = DateFormat(
      'dd.MM.yyyy',
    ).format(now.add(Duration(days: 1)));

    final todayRow = _getTodaysPrayerTimes();

    final tomorrowRow = csvData.firstWhere(
      (row) => row['Date'] == tomorrowStr,
      orElse: () => {},
    );

    final tomorrowDate = now.add(Duration(days: 1));
    final fajrTimeStr = tomorrowRow['Fajr'];
    final fajrTimeParts = fajrTimeStr!.split(':');
    final fajrPrayTime = DateTime(
      tomorrowDate.year,
      tomorrowDate.month,
      tomorrowDate.day,
      int.parse(fajrTimeParts[0]),
      int.parse(fajrTimeParts[1]),
    );

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
        if (prayerTime.isAfter(now)) {
          return prayerTime.difference(now);
        }
      }
    }
    return (fajrPrayTime.difference(now));
  }

  Widget _buildPrayerRow(String name, String? time, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        border: _checkForCurrentPrayer(name)
            ? Border.all(color: Colors.white)
            : Border.all(color: BColors.primary),
        color: isActive
            ? BColors.primary
            : Theme.of(context).brightness == Brightness.dark
            ? BColors.prayerRowDark
            : BColors.prayerRowLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: _checkForCurrentPrayer(name) ? 22 : 18,
            ),
          ),
          Row(
            children: [
              Text(
                time ?? "--:--",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _checkForCurrentPrayer(name) ? 22 : 18,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayRow = _getTodaysPrayerTimes();
    final hijridate = HijriCalendarConfig.now();

    String countdownText =
        "${timeUntilNextPrayer.inHours.remainder(60).toString().padLeft(2, '0')}:${timeUntilNextPrayer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timeUntilNextPrayer.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

    return Scaffold(
      body: csvData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'BBF - Freiburg',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_showNextPrayer()} in',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(color: BColors.primary),
                ),
                Text(
                  countdownText,
                  style: TextStyle(
                    color: BColors.primary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hijridate.hDay} ${hijridate.getLongMonthName()} ${hijridate.hYear} | ${now.day}. ${_getMonthName(now.month)}',
                  style: TextStyle(color: BColors.primary, fontSize: 13),
                ),

                const SizedBox(height: 16),
                _buildPrayerRow(
                  'Fajr',
                  todayRow['Fajr'],
                  _checkForCurrentPrayer("Fajr"),
                ),
                _buildPrayerRow(
                  'Dhuhr',
                  todayRow['Dhur'],
                  _checkForCurrentPrayer("Dhur"),
                ),
                _buildPrayerRow(
                  'Asr',
                  todayRow['Asr'],
                  _checkForCurrentPrayer("Asr"),
                ),
                _buildPrayerRow(
                  'Maghrib',
                  todayRow['Maghrib'],
                  _checkForCurrentPrayer("Maghrib"),
                ),
                _buildPrayerRow(
                  'Isha',
                  todayRow['Isha'],
                  _checkForCurrentPrayer("Isha"),
                ),
              ],
            ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bbf_app/utils/constants/colors.dart';

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
    loadCSV();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
  }

  Future<void> loadCSV() async {
    final rawData = await rootBundle.loadString('assets/files/data.csv');
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

    setState(() {
      csvData = rows;
    });
  }

  Duration _calculateNextPrayerDuration() {
    final today = DateTime.now().day;
    final now = DateTime.now();
    print(now);
    final todayRow = csvData.firstWhere(
      (row) => row['Tag'] == today.toString(),
      orElse: () => {},
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
    return Duration.zero;
  }

  Widget _buildPrayerRow(String name, String? time, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? BColors.primary : Theme.of(context).brightness == Brightness.dark? BColors.prayerRowDark : BColors.prayerRowLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              )),
          Row(
            children: [
              Text(time ?? "--:--",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  )),
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
    final today = DateTime.now().day;
    final now = DateTime.now();
    final todayRow = csvData.firstWhere(
      (row) => row['Tag'] == today.toString(),
      orElse: () => {},
    );

    String countdownText =
        "${timeUntilNextPrayer.inHours.remainder(60).toString().padLeft(2, '0')}:${timeUntilNextPrayer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timeUntilNextPrayer.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

    return Scaffold(
      body: csvData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Bildung und Begegnung - BBF',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Freiburg',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  countdownText,
                  style: TextStyle(
                      color: BColors.primary,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '<Next Prayer Placeholder> in',
                  style: TextStyle(color: BColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  '<Hidschri Date Placeholder> | ${now.day}, ${_getMonthName(now.month)}',
                  style: TextStyle(color: BColors.primary, fontSize: 13),
                ),

                const SizedBox(height: 16),
                _buildPrayerRow('Fajr', todayRow['Fajr'], false),
                _buildPrayerRow('Dhuhr', todayRow['Dhur'], false),
                _buildPrayerRow('Asr', todayRow['Asr'], true),
                _buildPrayerRow('Maghrib', todayRow['Maghrib'], false),
                _buildPrayerRow('Isha', todayRow['Isha'], false),
              ],
            ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  PrayertimesService prayertimesService = PrayertimesService();
  Duration timeUntilNextPrayer = Duration.zero;
  bool isIqamaRunning = false;
  List<Map<String, String>> csvData = [];
  String fridayPrayer1 = prayerTimesHelper.getFridaysPrayer1Preference();
  String fridayPrayer2 = prayerTimesHelper.getFridaysPrayer2Preference();
  String fajrIqama = prayerTimesHelper.getFajrIqamaPreference();
  String dhurIqama = prayerTimesHelper.getDhurIqamaPreference();
  String asrIqama = prayerTimesHelper.getAsrIqamaPreference();
  String maghribIqama = prayerTimesHelper.getMaghribIqamaPreference();
  String ishaIqama = prayerTimesHelper.getIshaIqamaPreference();
  final prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    loadCSV().then((_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
    loadIqamaAndFridayTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  void loadIqamaAndFridayTimes() async {
    final results = await Future.wait([
      prayertimesService.getFridayPrayer1(),
      prayertimesService.getFridayPrayer2(),
      prayertimesService.getFajrIqama(),
      prayertimesService.getDhurIqama(),
      prayertimesService.getAsrIqama(),
      prayertimesService.getMaghribIqama(),
      prayertimesService.getIshaIqama(),
    ]);

    if (!mounted) return;
    if (fridayPrayer1 != results[0]) {
      await prayerTimesHelper.setFridaysPrayerPreference(
        'FridaysPrayer1',
        results[0],
      );
      setState(() {
        fridayPrayer1 = results[0];
      });
    }
    if (fridayPrayer2 != results[1]) {
      await prayerTimesHelper.setFridaysPrayerPreference(
        'FridaysPrayer2',
        results[1],
      );
      setState(() {
        fridayPrayer2 = results[1];
      });
    }
    if (fajrIqama != results[2]) {
      await prayerTimesHelper.setIqamaPreference('Fajr', results[2]);
      setState(() {
        fajrIqama = results[2];
      });
    }
    if (dhurIqama != results[3]) {
      await prayerTimesHelper.setIqamaPreference('Dhur', results[3]);
      setState(() {
        dhurIqama = results[3];
      });
    }
    if (asrIqama != results[4]) {
      await prayerTimesHelper.setIqamaPreference('Asr', results[4]);
      setState(() {
        asrIqama = results[4];
      });
    }
    if (maghribIqama != results[5]) {
      await prayerTimesHelper.setIqamaPreference('Maghrib', results[5]);
      setState(() {
        maghribIqama = results[5];
      });
    }
    if (ishaIqama != results[6]) {
      await prayerTimesHelper.setIqamaPreference('Isha', results[6]);
      setState(() {
        ishaIqama = results[6];
      });
    }
    setState(() {
      fridayPrayer1 = results[0];
      fridayPrayer2 = results[1];
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
  }

  Text _currentDate(
    HijriCalendarConfig hijridate,
    DateTime now,
    bool isDark,
    double scale,
  ) {
    return Text(
      '${hijridate.hDay} ${hijridate.getLongMonthName()} ${hijridate.hYear} | ${now.day}. ${_getMonthName(now.month)}',
      style: TextStyle(
        color: isDark ? Colors.white : BColors.primary,
        fontSize: 20 * scale,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }

  Text _countdownToNextPrayer(String countdownText, bool isDark, double scale) {
    return Text(
      countdownText,
      style: TextStyle(
        color: BColors.primary,
        fontSize: scale * 100,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _showNextPrayer() {
    final now = DateTime.now();

    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr != null) {
        final prayerTime = prayerTimesHelper.convertStringTimeIntoDateTime(
          timeStr,
        );
        if (prayerTime.isAfter(now)) {
          return key;
        }
      }
    }
    return 'Fajr';
  }

  Text _showNextPrayerText(
    BuildContext context,
    bool isDark,
    bool isIqamaRunning,
    double size,
  ) {
    if (!isIqamaRunning) {
      return Text(
        '${_showNextPrayer()} in',
        style: TextStyle(
          fontSize: 60 * size,
          color: BColors.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      'Iqama in',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontSize: 60 * size,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : BColors.primary,
      ),
    );
  }

  Text _adhanTime(String? time, bool isActive, double scale) {
    return Text(
      time ?? "--:--",
      style: TextStyle(
        color: Colors.white,
        fontSize: isActive ? 48 * scale : 44 * scale,
      ),
    );
  }

  Text _iqamaTime(String iqamaTime, bool isActive, double scale) {
    return Text(
      '+$iqamaTime',
      style: TextStyle(
        color: Colors.white,
        fontSize: isActive ? 28 * scale : 24 * scale,
      ),
    );
  }

  Text _prayerName(String name, bool isActive, double scale) {
    return Text(
      name,
      style: TextStyle(
        color: Colors.white,
        fontSize: isActive ? 38 * scale : 34 * scale,
      ),
    );
  }

  String getCountDownText(Duration timeUntilNextPrayer, bool isIqamaRunning) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(timeUntilNextPrayer.inHours.remainder(60));
    final minutes = twoDigits(timeUntilNextPrayer.inMinutes.remainder(60));
    final seconds = twoDigits(timeUntilNextPrayer.inSeconds.remainder(60));

    if (!isIqamaRunning) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Duration _calculateNextPrayerDuration() {
    final now = DateTime.now();

    // this is used to get the difference time between isha and next day fajr
    final tomorrowStr = DateFormat(
      'dd.MM.yyyy',
    ).format(now.add(Duration(days: 1)));

    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);

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

    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr == null) {
        continue;
      }

      final prayerTime = prayerTimesHelper.convertStringTimeIntoDateTime(
        timeStr,
      );
      final iqamaMinutes = prayerTimesHelper.getCertainIqamaPreference(key);
      final prayerIqamaEndTime = prayerTime.add(
        Duration(minutes: int.parse(iqamaMinutes)),
      );

      // Check for the current prayerTime if the now is between prayerTime and prayerIqama ending time.
      // If this is the case, then give the difference between now and the end of prayerIqama
      if (now.isAfter(prayerTime) && now.isBefore(prayerIqamaEndTime)) {
        isIqamaRunning = true;
        return prayerIqamaEndTime.difference(now);
      }

      // else just display the difference time between now and next prayer
      if (prayerTime.isAfter(now)) {
        isIqamaRunning = false;
        return prayerTime.difference(now);
      }
    }
    return (fajrPrayTime.difference(now));
  }

  bool _checkForCurrentPrayer(String prayer) {
    final now = DateTime.now();
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);

    String currentKey = "";
    for (final key in prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr != null) {
        final prayerTime = prayerTimesHelper.convertStringTimeIntoDateTime(
          timeStr,
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

  Widget _buildPrayerBlock(
    String name,
    String? time,
    bool isActive,
    String iqamaTime,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 40 * scale,
        horizontal: 100 * scale,
      ),
      decoration: BoxDecoration(
        border: isActive
            ? Border.all(color: Colors.white)
            : Border.all(color: BColors.primary),
        color: isActive
            ? BColors.primary
            : Theme.of(context).brightness == Brightness.dark
            ? BColors.prayerRowDark
            : BColors.prayerRowLight,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        children: [
          _prayerName(name, isActive, scale),
          Column(
            children: [
              _adhanTime(time, isActive, scale),
              _iqamaTime(iqamaTime, isActive, scale),
            ],
          ),
        ],
      ),
    );
  }

  Row _prayerTimesPage(
    Map<String, String> todayRow,
    BuildContext context,
    bool isDark,
    double scale,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPrayerBlock(
          'Fajr',
          todayRow['Fajr'],
          _checkForCurrentPrayer("Fajr"),
          fajrIqama,
          scale,
        ),
        SizedBox(width: 20 * scale),
        _buildPrayerBlock(
          'Dhur',
          todayRow['Dhur'],
          _checkForCurrentPrayer("Dhur"),
          dhurIqama,
          scale,
        ),
        SizedBox(width: 20 * scale),
        _buildPrayerBlock(
          'Asr',
          todayRow['Asr'],
          _checkForCurrentPrayer("Asr"),
          asrIqama,
          scale,
        ),
        SizedBox(width: 20 * scale),
        _buildPrayerBlock(
          'Maghrib',
          todayRow['Maghrib'],
          _checkForCurrentPrayer("Maghrib"),
          maghribIqama,
          scale,
        ),
        SizedBox(width: 20 * scale),
        _buildPrayerBlock(
          'Isha',
          todayRow['Isha'],
          _checkForCurrentPrayer("Isha"),
          ishaIqama,
          scale,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 1920).clamp(0.5, 2.0);

    final now = DateTime.now();
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    final hijridate = HijriCalendarConfig.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String countdownText = getCountDownText(
      timeUntilNextPrayer,
      isIqamaRunning,
    );

    return Scaffold(
      body: csvData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [Colors.green.shade900, Colors.grey.shade700]
                      : [Colors.grey.shade300, Colors.green.shade200],
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20 * scale),
                      Text(
                        'BBF Verein - Freiburg',
                        style: TextStyle(
                          fontSize: 80 * scale,
                          color: BColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      _showNextPrayerText(
                        context,
                        isDark,
                        isIqamaRunning,
                        scale,
                      ),
                      SizedBox(height: 10 * scale),
                      _countdownToNextPrayer(countdownText, isDark, scale),
                      SizedBox(height: 5 * scale),
                      _currentDate(hijridate, now, isDark, scale),
                      SizedBox(height: 120 * scale),
                      _prayerTimesPage(todayRow, context, isDark, scale),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

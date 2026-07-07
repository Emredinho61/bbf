// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/screens/homepage.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  final PrayertimesService prayertimesService = PrayertimesService();

  List<Map<String, String>> csvData = [];
  Duration timeUntilNextPrayer = Duration.zero;
  bool isIqamaRunning = false;

  String fridayPrayer1 = prayerTimesHelper.getFridaysPrayer1Preference();
  String fridayPrayer2 = prayerTimesHelper.getFridaysPrayer2Preference();
  String fajrIqama   = prayerTimesHelper.getFajrIqamaPreference();
  String dhurIqama   = prayerTimesHelper.getDhurIqamaPreference();
  String asrIqama    = prayerTimesHelper.getAsrIqamaPreference();
  String maghribIqama = prayerTimesHelper.getMaghribIqamaPreference();
  String ishaIqama   = prayerTimesHelper.getIshaIqamaPreference();

  static const _prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

  late Timer _timer;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCSV().then((_) => setState(() {
      timeUntilNextPrayer = _calcCountdown();
    }));
    _loadRemoteTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => timeUntilNextPrayer = _calcCountdown());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadCSV() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/prayer_times.csv');
    if (!await file.exists()) {
      debugPrint('MonitorPage: CSV nicht gefunden');
      return;
    }
    final raw = await file.readAsString();
    final lines = LineSplitter.split(raw).toList();
    final headers = lines.first.split(',');
    final rows = <Map<String, String>>[];
    for (var i = 1; i < lines.length; i++) {
      final vals = lines[i].split(',');
      final row = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = vals[j];
      }
      rows.add(row);
    }
    setState(() => csvData = rows);
  }

  void _loadRemoteTimes() async {
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
    setState(() {
      fridayPrayer1  = results[0];
      fridayPrayer2  = results[1];
      fajrIqama      = results[2];
      dhurIqama      = results[3];
      asrIqama       = results[4];
      maghribIqama   = results[5];
      ishaIqama      = results[6];
    });
    await prayerTimesHelper.setFridaysPrayerPreference('FridaysPrayer1', results[0]);
    await prayerTimesHelper.setFridaysPrayerPreference('FridaysPrayer2', results[1]);
    await prayerTimesHelper.setIqamaPreference('Fajr',    results[2]);
    await prayerTimesHelper.setIqamaPreference('Dhur',    results[3]);
    await prayerTimesHelper.setIqamaPreference('Asr',     results[4]);
    await prayerTimesHelper.setIqamaPreference('Maghrib', results[5]);
    await prayerTimesHelper.setIqamaPreference('Isha',    results[6]);
  }

  // ── Timer logic ───────────────────────────────────────────────────────────

  Duration _calcCountdown() {
    if (csvData.isEmpty) return Duration.zero;
    final now = DateTime.now();
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);

    for (final key in _prayerKeys) {
      final timeStr = todayRow[key];
      if (timeStr == null) continue;
      final prayerTime = prayerTimesHelper.convertStringTimeIntoDateTime(timeStr);
      final iqamaMin = int.tryParse(prayerTimesHelper.getCertainIqamaPreference(key)) ?? 10;
      final iqamaEnd = prayerTime.add(Duration(minutes: iqamaMin));

      if (now.isAfter(prayerTime) && now.isBefore(iqamaEnd)) {
        isIqamaRunning = true;
        return iqamaEnd.difference(now);
      }
      if (prayerTime.isAfter(now)) {
        isIqamaRunning = false;
        return prayerTime.difference(now);
      }
    }

    // After Isha → count to tomorrow's Fajr
    isIqamaRunning = false;
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr = DateFormat('dd.MM.yyyy').format(tomorrow);
    final tomorrowRow = csvData.firstWhere((r) => r['Date'] == tomorrowStr, orElse: () => {});
    final fajrStr = tomorrowRow['Fajr'] ?? todayRow['Fajr'] ?? '03:00';
    final parts = fajrStr.split(':');
    final fajrTomorrow = DateTime(
      tomorrow.year, tomorrow.month, tomorrow.day,
      int.parse(parts[0]), int.parse(parts[1]),
    );
    return fajrTomorrow.difference(now);
  }

  String _countdownText() {
    String pad(int n) => n.toString().padLeft(2, '0');
    final h = pad(timeUntilNextPrayer.inHours.remainder(24));
    final m = pad(timeUntilNextPrayer.inMinutes.remainder(60));
    final s = pad(timeUntilNextPrayer.inSeconds.remainder(60));
    return isIqamaRunning ? '$m:$s' : '$h:$m:$s';
  }

  String _nextPrayerKey() {
    if (csvData.isEmpty) return 'Fajr';
    final now = DateTime.now();
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    for (final key in _prayerKeys) {
      final t = todayRow[key];
      if (t != null && prayerTimesHelper.convertStringTimeIntoDateTime(t).isAfter(now)) {
        return key;
      }
    }
    return 'Fajr';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static const _weekdays  = ['Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag','Sonntag'];
  static const _months    = ['Januar','Februar','März','April','Mai','Juni',
                              'Juli','August','September','Oktober','November','Dezember'];
  static const _displayNames = <String, String>{
    'Fajr': 'Fajr', 'Dhur': 'Dhuhr', 'Asr': 'Asr', 'Maghrib': 'Maghrib', 'Isha': 'Isha',
  };

  String _iqamaFor(String key) {
    switch (key) {
      case 'Fajr':    return fajrIqama;
      case 'Dhur':    return dhurIqama;
      case 'Asr':     return asrIqama;
      case 'Maghrib': return maghribIqama;
      default:        return ishaIqama;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (csvData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size   = MediaQuery.of(context).size;
    final scale  = (size.width / 1280).clamp(0.35, 2.0);
    final now    = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? BColors.backgroundColorDark : BColors.backgroundColor;
    final fg     = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final todayRow   = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    final hijri      = HijriCalendarConfig.now();
    final nextKey    = _nextPrayerKey();

    final germanDate = '${_weekdays[now.weekday - 1]}, ${now.day}. ${_months[now.month - 1]} ${now.year}';
    final hijriDate  = '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32 * scale, 20 * scale, 32 * scale, 16 * scale),
          child: Column(
            children: [
              // ── Top: Shuruk | Clock | Friday ──────────────
              Expanded(
                flex: 55,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left – Shuruk
                    Expanded(flex: 2, child: _shurukBlock(todayRow, scale, fg)),

                    // Center – title + countdown + dates
                    Expanded(flex: 5, child: _centerBlock(scale, fg, germanDate, hijriDate, nextKey)),

                    // Right – Friday prayer
                    Expanded(flex: 2, child: _fridayBlock(scale, fg)),
                  ],
                ),
              ),

              SizedBox(height: 20 * scale),

              // ── Bottom: 5 prayer cards ─────────────────────
              Expanded(
                flex: 38,
                child: Row(
                  children: [
                    for (int i = 0; i < _prayerKeys.length; i++) ...[
                      Expanded(
                        child: _prayerCard(
                          key: _prayerKeys[i],
                          time: todayRow[_prayerKeys[i]],
                          iqama: _iqamaFor(_prayerKeys[i]),
                          isActive: _prayerKeys[i] == nextKey,
                          scale: scale,
                          isDark: isDark,
                        ),
                      ),
                      if (i < _prayerKeys.length - 1) SizedBox(width: 12 * scale),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 10 * scale),

              // ── Footer: back link ──────────────────────────
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NavBarShell()),
                ),
                child: Text(
                  '← Zurück zur App',
                  style: TextStyle(
                    color: BColors.primary.withOpacity(0.55),
                    fontSize: 13 * scale,
                    decoration: TextDecoration.underline,
                    decorationColor: BColors.primary.withOpacity(0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section widgets ───────────────────────────────────────────────────────

  Widget _shurukBlock(Map<String, String> todayRow, double scale, Color fg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.nightlight_round, color: fg, size: 40 * scale),
        SizedBox(height: 10 * scale),
        Text(
          'Shuruk',
          style: TextStyle(color: fg.withOpacity(0.8), fontSize: 22 * scale, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6 * scale),
        Text(
          todayRow['Sunrise'] ?? '--:--',
          style: TextStyle(color: fg, fontSize: 36 * scale, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _centerBlock(double scale, Color fg, String germanDate, String hijriDate, String nextKey) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BBF Verein - Freiburg',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: fg,
            fontSize: 26 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 14 * scale),

        // Big countdown
        Text(
          _countdownText(),
          style: TextStyle(
            color: BColors.primary,
            fontSize: 88 * scale,
            fontWeight: FontWeight.bold,
            height: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: 8 * scale),

        // Label below clock
        Text(
          isIqamaRunning
              ? 'Iqama läuft'
              : 'Nächstes Gebet: ${_displayNames[nextKey] ?? nextKey}',
          style: TextStyle(color: fg.withOpacity(0.5), fontSize: 15 * scale),
        ),
        SizedBox(height: 14 * scale),

        // German date
        Text(
          germanDate,
          style: TextStyle(color: fg.withOpacity(0.85), fontSize: 18 * scale),
        ),
        SizedBox(height: 4 * scale),

        // Hijri date
        Text(
          hijriDate,
          style: TextStyle(color: fg.withOpacity(0.55), fontSize: 16 * scale),
        ),
      ],
    );
  }

  Widget _fridayBlock(double scale, Color fg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Freitagsgebet',
          textAlign: TextAlign.center,
          style: TextStyle(color: fg.withOpacity(0.8), fontSize: 20 * scale, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10 * scale),
        Text(
          fridayPrayer1.isEmpty ? '--:--' : fridayPrayer1,
          style: TextStyle(color: fg, fontSize: 34 * scale, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          width: 70 * scale,
          child: Divider(color: fg.withOpacity(0.25), thickness: 1.5),
        ),
        SizedBox(height: 8 * scale),
        Text(
          fridayPrayer2.isEmpty ? '--:--' : fridayPrayer2,
          style: TextStyle(color: fg, fontSize: 34 * scale, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _prayerCard({
    required String key,
    required String? time,
    required String iqama,
    required bool isActive,
    required double scale,
    required bool isDark,
  }) {
    final cardBg   = isActive ? BColors.primary : (isDark ? BColors.prayerRowDark : Colors.white);
    final textCol  = (isActive || isDark) ? Colors.white : const Color(0xFF1C1C1E);
    final iqamaBg  = Colors.white.withOpacity(isActive ? 0.2 : (isDark ? 0.1 : 0.0));
    final iqamaCol = isActive || isDark ? Colors.white : BColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16 * scale),
        border: isActive
            ? null
            : Border.all(color: BColors.primary.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? BColors.primary.withOpacity(0.35)
                : Colors.black.withOpacity(isDark ? 0.18 : 0.07),
            blurRadius: 18 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _displayNames[key] ?? key,
            style: TextStyle(
              color: textCol.withOpacity(0.85),
              fontSize: 20 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            time ?? '--:--',
            style: TextStyle(
              color: textCol,
              fontSize: 34 * scale,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: iqamaBg,
              border: Border.all(color: iqamaCol.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(20 * scale),
            ),
            child: Text(
              '+$iqama',
              style: TextStyle(
                color: iqamaCol,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

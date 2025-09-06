import 'dart:async';
import 'dart:convert';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/underlined_text.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar/calendar.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/monthlypdf.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

class PrayerTimes extends StatefulWidget {
  const PrayerTimes({super.key});

  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  final PrayertimesService prayertimesService = PrayertimesService();

  List<Map<String, String>> csvData = [];

  late Timer _timer;

  Duration timeUntilNextPrayer = Duration.zero;

  final prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];

  String fridayPrayer1 = '';
  String fridayPrayer2 = '';
  String fajrIqama = '';
  String dhurIqama = '';
  String asrIqama = '';
  String maghribIqama = '';
  String ishaIqama = '';

  @override
  void initState() {
    super.initState();
    loadCSV().then((_) {
      setState(() {
        timeUntilNextPrayer = _calculateNextPrayerDuration();
      });
    });
    loadPrayer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> openPdf() async {
    final byteData = await rootBundle.load(
      'assets/files/pdf_files/Curriculum_Vitae_Emre.pdf',
    );

    // creating a temporary file to store the data in the local storage of the app
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Curriculum_Vitae_Emre.pdf');

    // write data in file
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    // open pdf
    OpenFilex.open(file.path);
  }

  String getShuruqTimes() {
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    return todayRow['Sunrise']!;
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

  Duration _calculateNextPrayerDuration() {
    final now = DateTime.now();
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
      if (timeStr != null) {
        final prayerTime = prayerTimesHelper.convertStringTimeIntoDateTime(
          timeStr,
        );
        if (prayerTime.isAfter(now)) {
          return prayerTime.difference(now);
        }
      }
    }
    return (fajrPrayTime.difference(now));
  }

  void loadPrayer() async {
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
      fridayPrayer1 = results[0];
      fridayPrayer2 = results[1];
      fajrIqama = results[2];
      dhurIqama = results[3];
      asrIqama = results[4];
      maghribIqama = results[5];
      ishaIqama = results[6];
    });
  }

  Widget _buildPrayerRow(
    String name,
    String? time,
    bool isActive,
    String iqamaTime,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        border: isActive
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
            style: TextStyle(color: Colors.white, fontSize: isActive ? 22 : 18),
          ),
          Row(
            children: [
              Text(
                time ?? "--:--",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isActive ? 22 : 18,
                ),
              ),
              const SizedBox(width: 4),
              Transform.translate(
                offset: Offset(0, 2),
                child: Text(
                  '+$iqamaTime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isActive ? 16 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NotificationSettings(
                context: context,
                prayerKeys: prayerKeys,
                name: name,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    final hijridate = HijriCalendarConfig.now();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    String countdownText =
        "${timeUntilNextPrayer.inHours.remainder(60).toString().padLeft(2, '0')}:${timeUntilNextPrayer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(timeUntilNextPrayer.inSeconds.remainder(60)).toString().padLeft(2, '0')}";

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Text(
                      'BBF Verein - Freiburg',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${_showNextPrayer()} in',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: isDark ? Colors.white : BColors.primary,
                          ),
                    ),
                    Text(
                      countdownText,
                      style: TextStyle(
                        color: isDark ? Colors.white : BColors.primary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${hijridate.hDay} ${hijridate.getLongMonthName()} ${hijridate.hYear} | ${now.day}. ${_getMonthName(now.month)}',
                      style: TextStyle(
                        color: isDark ? Colors.white : BColors.primary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: BColors.primary,
                              labelColor: Colors.black,
                              tabs: [Text('Gebetszeiten'), Text('Kalender')],
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  ListView(
                                    children: [
                                      Column(
                                        children: [
                                          _buildPrayerRow(
                                            'Fajr',
                                            todayRow['Fajr'],
                                            _checkForCurrentPrayer("Fajr"),
                                            fajrIqama,
                                          ),
                                          _buildPrayerRow(
                                            'Dhur',
                                            todayRow['Dhur'],
                                            _checkForCurrentPrayer("Dhur"),
                                            dhurIqama,
                                          ),
                                          _buildPrayerRow(
                                            'Asr',
                                            todayRow['Asr'],
                                            _checkForCurrentPrayer("Asr"),
                                            asrIqama,
                                          ),
                                          _buildPrayerRow(
                                            'Maghrib',
                                            todayRow['Maghrib'],
                                            _checkForCurrentPrayer("Maghrib"),
                                            maghribIqama,
                                          ),
                                          _buildPrayerRow(
                                            'Isha',
                                            todayRow['Isha'],
                                            _checkForCurrentPrayer("Isha"),
                                            ishaIqama,
                                          ),
                                          SizedBox(height: 6),

                                          SizedBox(
                                            width: 250,
                                            child: Divider(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),

                                          SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? BColors.prayerRowDark
                                                      : BColors.prayerRowLight,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: BColors.primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Shuruq ${getShuruqTimes()}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              actions: [
                                                                FutureBuilder(
                                                                  future: prayerTimesHelper
                                                                      .getCertainPrayerTimeAsDateTimes(
                                                                        "Sunrise",
                                                                      ),
                                                                  builder:
                                                                      (
                                                                        context,
                                                                        asyncSnapshot,
                                                                      ) {
                                                                        return NotificationSettingsPage(
                                                                          name:
                                                                              "Sunrise",
                                                                          id: prayerTimesHelper.convertNameIntoId(
                                                                            "Sunrise",
                                                                          ),
                                                                          prayerTime:
                                                                              asyncSnapshot.data,
                                                                        );
                                                                      },
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        child:
                                                            prayerTimesHelper
                                                                .isNotificationEnabled(
                                                                  'Sunrise',
                                                                )
                                                            ? Icon(
                                                                Icons
                                                                    .notifications_none,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .notifications_off,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? BColors.prayerRowDark
                                                      : BColors.prayerRowLight,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: BColors.primary,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: Text(
                                                    'Jumua\'a $fridayPrayer1 | $fridayPrayer2',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          TextButton.icon(
                                            onPressed: () {
                                              generateMonthlyPrayerPdf(
                                                csvData,
                                                fridayPrayer1,
                                                fridayPrayer2,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.picture_as_pdf,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              size: 24,
                                            ),
                                            label: UnderlinedText(
                                              content: Text(
                                                'Monat PDF',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ListView(children: [CalenderView()]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

class NotificationSettings extends StatelessWidget {
  late final String name;
  NotificationSettings({
    super.key,
    required this.context,
    required this.prayerKeys,
    required this.name,
  });

  final BuildContext context;
  final List<String> prayerKeys;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),

          builder: (context) {
            return BDraggableScrollableSheet(
              scrollViewRequired: false,
              content: DefaultTabController(
                initialIndex: prayerKeys.indexOf(name),
                length: 5,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      indicatorColor: BColors.primary,
                      labelColor: BColors.primary,
                      unselectedLabelColor: isDark
                          ? Colors.white
                          : Colors.black,
                      tabs: [
                        Tab(text: 'Fajr'),
                        Tab(text: 'Dhur'),
                        Tab(text: 'Asr'),
                        Tab(text: 'Maghrib'),
                        Tab(text: 'Isha'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          FutureBuilder(
                            future: prayerTimesHelper
                                .getCertainPrayerTimeAsDateTimes("Fajr"),
                            builder: (context, asyncSnapshot) {
                              return NotificationSettingsPage(
                                name: "Fajr",
                                id: prayerTimesHelper.convertNameIntoId("Fajr"),
                                prayerTime: asyncSnapshot.data,
                              );
                            },
                          ),
                          FutureBuilder(
                            future: prayerTimesHelper
                                .getCertainPrayerTimeAsDateTimes("Dhur"),
                            builder: (context, asyncSnapshot) {
                              return NotificationSettingsPage(
                                name: "Dhur",
                                id: prayerTimesHelper.convertNameIntoId("Dhur"),
                                prayerTime: asyncSnapshot.data,
                              );
                            },
                          ),
                          FutureBuilder(
                            future: prayerTimesHelper
                                .getCertainPrayerTimeAsDateTimes("Asr"),
                            builder: (context, asyncSnapshot) {
                              return NotificationSettingsPage(
                                name: "Asr",
                                id: prayerTimesHelper.convertNameIntoId("Asr"),
                                prayerTime: asyncSnapshot.data,
                              );
                            },
                          ),
                          FutureBuilder(
                            future: prayerTimesHelper
                                .getCertainPrayerTimeAsDateTimes("Maghrib"),
                            builder: (context, asyncSnapshot) {
                              return NotificationSettingsPage(
                                name: "Maghrib",
                                id: prayerTimesHelper.convertNameIntoId(
                                  "Maghrib",
                                ),
                                prayerTime: asyncSnapshot.data,
                              );
                            },
                          ),
                          FutureBuilder(
                            future: prayerTimesHelper
                                .getCertainPrayerTimeAsDateTimes("Isha"),
                            builder: (context, asyncSnapshot) {
                              return NotificationSettingsPage(
                                name: "Isha",
                                id: prayerTimesHelper.convertNameIntoId("Isha"),
                                prayerTime: asyncSnapshot.data,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: prayerTimesHelper.isNotificationEnabled(name)
          ? Icon(Icons.notifications_none, color: Colors.white)
          : Icon(Icons.notifications_off, color: Colors.white),
    );
  }
}

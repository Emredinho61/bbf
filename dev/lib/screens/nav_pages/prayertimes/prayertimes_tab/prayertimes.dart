import 'dart:async';
import 'dart:convert';
import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/shared_preferences_service.dart';
import 'package:bbf_app/components/draggable_scrollable_sheet.dart';
import 'package:bbf_app/components/underlined_text.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/calendar.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/information_tab/information_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/prayertimes_tab/notification_settings.dart';
import 'package:bbf_app/utils/helper/calendar_page_helper.dart';
import 'package:bbf_app/utils/helper/information_page_helper.dart';
import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'package:bbf_app/utils/helper/scheduler_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/monthlypdf.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import "package:bbf_app/components/donations/donation_tile.dart";

import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(PrayerNotificationHandler());
}

@pragma('vm:entry-point')
class PrayerNotificationHandler extends TaskHandler {
  PrayerTimesHelper? _prayerTimesHelper;

  Future<void> _ensureInitialized() async {
    if (_prayerTimesHelper == null) {
      await SharedPreferencesService.instance.initPrefs();
      _prayerTimesHelper = PrayerTimesHelper();
    }
  }

  Future<List<Map<String, String>>> _loadCsvData() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/prayer_times.csv");

    if (!await file.exists()) {
      print("CSV file not found");
      return [];
    }

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

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final csvData = await _loadCsvData();

    if (csvData.isEmpty) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'ERROR',
        notificationText: 'CSV EMPTY',
      );
      return;
    }

    if (_prayerTimesHelper == null) {
      await _ensureInitialized();
    }
    final todayRow = _prayerTimesHelper!.getTodaysPrayerTimesAsStringMap(
      csvData,
    );

    final notificationBody =
        "Fajr: ${todayRow['Fajr']} | "
        "Dhuhr: ${todayRow['Dhur']} | "
        "Asr: ${todayRow['Asr']} | "
        "Maghrib: ${todayRow['Maghrib']} | "
        "Isha: ${todayRow['Isha']}";
    FlutterForegroundTask.updateService(
      notificationTitle: 'Gebetszeiten Freiburg',
      notificationText: notificationBody,
    );
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    final csvData = await _loadCsvData();

    if (csvData.isEmpty) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'ERROR',
        notificationText: 'CSV EMPTY',
      );
      return;
    }

    if (_prayerTimesHelper == null) {
      await _ensureInitialized();
    }
    final todayRow = _prayerTimesHelper!.getTodaysPrayerTimesAsStringMap(
      csvData,
    );

    final notificationBody =
        "Fajr: ${todayRow['Fajr']} | "
        "Dhuhr: ${todayRow['Dhur']} | "
        "Asr: ${todayRow['Asr']} | "
        "Maghrib: ${todayRow['Maghrib']} | "
        "Isha: ${todayRow['Isha']}";

    FlutterForegroundTask.updateService(
      notificationTitle: 'Gebetszeiten Freiburg',
      notificationText: notificationBody,
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

class PrayerTimes extends StatefulWidget {
  const PrayerTimes({super.key});

  @override
  State<PrayerTimes> createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  /* Initializing variables and objects */
  final PrayertimesService prayertimesService = PrayertimesService();
  final InformationService informationService = InformationService();

  final SchedulerHelper schedulerHelper = SchedulerHelper();

  final PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  final InformationPageHelper informationPageHelper = InformationPageHelper();
  final NotificationServices notificationServices = NotificationServices();
  final CalendarService calendarService = CalendarService();
  final CalendarPageHelper calendarPageHelper = CalendarPageHelper();

  int informationSum = 0;
  late String fridayPrayer1;
  late String fridayPrayer2;
  late String fajrIqama;
  late String dhurIqama;
  late String asrIqama;
  late String maghribIqama;
  late String ishaIqama;

  List<Map<String, String>> csvData = [];
  List<Map<String, dynamic>> _allInformation = [];

  late Timer _timer;

  Duration timeUntilNextPrayer = Duration.zero;
  bool isIqamaRunning = false;

  final prayerKeys = ['Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha'];
  // when page is opened, the following is initialized
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _startTimer();
    await _initIqamaAndFridaysTimes();
    await loadCSV();

    await startPrayerNotificationService();

    setState(() {
      timeUntilNextPrayer = _calculateNextPrayerDuration();
    });
    loadIqamaAndFridayTimes();
    _initPage();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initIqamaAndFridaysTimes() async {
    setState(() {
      informationSum = informationPageHelper
          .getTotalInformationNumberFromBackend();

      fridayPrayer1 = prayerTimesHelper.getFridaysPrayer1Preference();
      fridayPrayer2 = prayerTimesHelper.getFridaysPrayer2Preference();
      fajrIqama = prayerTimesHelper.getFajrIqamaPreference();
      dhurIqama = prayerTimesHelper.getDhurIqamaPreference();
      asrIqama = prayerTimesHelper.getAsrIqamaPreference();
      maghribIqama = prayerTimesHelper.getMaghribIqamaPreference();
      ishaIqama = prayerTimesHelper.getIshaIqamaPreference();
    });
  }

  Future<void> _initPage() async {
    await _loadInformation();
    await _loadInformationSum();
  }

  // loads all Information from backend
  Future<void> _loadInformation() async {
    final data = await informationService.getAllInformation();
    setState(() {
      _allInformation = data;
    });
  }

  Future<void> _loadInformationSum() async {
    final informationSumFromBackend = _allInformation.length;
    if (informationSumFromBackend != informationSum) {
      informationPageHelper.setTotalInformationNumberFromBackend(
        informationSumFromBackend,
      );
      setState(() {
        informationSum = informationSumFromBackend;
      });
    }
  }

  /* Defining all nessecary functions */
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

  Future<void> startPrayerNotificationService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'prayer_times_channel',
        channelName: 'Prayer Times',
        channelDescription: 'Shows daily prayer times',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );

    final todayRow = prayerTimesHelper.getTodaysPrayerTimesAsStringMap(csvData);
    final notificationBody =
        "Fajr: ${todayRow['Fajr']} | "
        "Dhuhr: ${todayRow['Dhur']} | "
        "Asr: ${todayRow['Asr']} | "
        "Maghrib: ${todayRow['Maghrib']} | "
        "Isha: ${todayRow['Maghrib']}";
    print(notificationBody);

    await FlutterForegroundTask.startService(
      notificationTitle: 'Gebetszeiten Freiburg',
      notificationText: notificationBody,
      callback: startCallback,
    );
  }

  Future<void> loadCSV() async {
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

  // Prayer Row contains the prayer name, adhan & iqama Time,
  // notification settings Icon for setting prayer and pre-prayer Notifications
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
          _prayerName(name, isActive),
          Row(
            children: [
              _adhanTime(time, isActive),
              const SizedBox(width: 4),
              _iqamaTime(iqamaTime, isActive),
              const SizedBox(width: 8),
              _notificationSettingsIcon(name, csvData),
            ],
          ),
        ],
      ),
    );
  }

  // opens Notification setting if Icon is tapped
  NotificationSettings _notificationSettingsIcon(
    String name,
    List<Map<String, String>> csvData,
  ) {
    return NotificationSettings(
      context: context,
      prayerKeys: prayerKeys,
      name: name,
      csvData: csvData,
    );
  }

  Text _adhanTime(String? time, bool isActive) {
    return Text(
      time ?? "--:--",
      style: TextStyle(color: Colors.white, fontSize: isActive ? 22 : 18),
    );
  }

  Transform _iqamaTime(String iqamaTime, bool isActive) {
    return Transform.translate(
      offset: Offset(0, 2),
      child: Text(
        '+$iqamaTime',
        style: TextStyle(color: Colors.white, fontSize: isActive ? 16 : 12),
      ),
    );
  }

  Text _prayerName(String name, bool isActive) {
    return Text(
      name,
      style: TextStyle(color: Colors.white, fontSize: isActive ? 22 : 18),
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

  /* Beginning of Main Page UI containing prayertimes page, calender page and info page */
  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _mosqueName(context, isDark),
                    const SizedBox(height: 14),
                    _showNextPrayerText(context, isDark, isIqamaRunning),
                    _countdownToNextPrayer(countdownText, isDark),
                    const SizedBox(height: 3),
                    _currentDate(hijridate, now, isDark),

                    const SizedBox(height: 16),
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            TabBar(
                              dividerColor: isDark
                                  ? Colors.white54
                                  : BColors.secondary,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              indicatorColor: BColors.primary,
                              labelColor: isDark ? Colors.white : Colors.black,
                              tabs: [
                                Text(
                                  'Gebetszeiten',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  'Kalender',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                informationPageHelper
                                            .getTotalInformationNumber() ==
                                        informationSum
                                    ? Text(
                                        'Information',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      )
                                    : Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Text(
                                            'Information',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          Positioned(
                                            right: -8,
                                            top: -6,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _prayerTimesPage(todayRow, context, isDark),
                                  _calenderPage(),
                                  _informationPage(),
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
  /* Here is the end of Main Page UI containing prayertimes page, calender page and info page */

  // This Page contains all the Information the mosque wants to share with the users
  InformationPage _informationPage() => InformationPage();

  // This Page shows a calender showing prayer Times for selected day
  ListView _calenderPage() => ListView(children: [CalenderView()]);

  /* prayertimes tab begins here */
  ListView _prayerTimesPage(
    Map<String, String> todayRow,
    BuildContext context,
    bool isDark,
  ) {
    return ListView(
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
            _divider(context),
            SizedBox(height: 6),
            _shuruqAndJumuaRow(context, isDark),
            SizedBox(height: 4),
            _monthlyPrayerAndKhutbaPDFs(context),
            SizedBox(height: 4),
            popUpDonationButton(context),
          ],
        ),
      ],
    );
  }

  Row _monthlyPrayerAndKhutbaPDFs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // generates a pdf from current months prayertimes
        _monthlyPrayerPdfs(context),

        const SizedBox(width: 12),

        // button to upload latest Khutba
        // _uploadKhutbaButton(context),
      ],
    );
  }

  Widget popUpDonationButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("Deine Spende zählt!", style: TextStyle(fontSize: 18)),
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Spenden'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButtonForPayPal(isDark: isDark),

                  SizedBox(height: 10),

                  DividerWithText(isDark: isDark),

                  SizedBox(height: 10),

                  BankInfoCard(isDark: isDark),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  TextButton _monthlyPrayerPdfs(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showMonthPickerDialog(context),
      icon: Icon(
        Icons.picture_as_pdf,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        size: 24,
      ),
      label: UnderlinedText(
        content: Text(
          'Monat PDF',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  List<Map<String, int>> _extractAvailableMonths(
    List<Map<String, String>> csvData,
  ) {
    final Set<String> seen = {};
    final List<Map<String, int>> result = [];

    for (final row in csvData) {
      if (row['Date'] == null) continue;

      final parts = row['Date']!.split('.');
      if (parts.length != 3) continue;

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) continue;

      final key = "$month-$year";
      if (!seen.contains(key)) {
        seen.add(key);
        result.add({"month": month, "year": year});
      }
    }

    // Sort by year -> month
    result.sort((a, b) {
      if (a['year'] == b['year']) return a['month']!.compareTo(b['month']!);
      return a['year']!.compareTo(b['year']!);
    });

    return result;
  }

  String _monthName(int month) {
    const months = [
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember",
    ];
    return months[month - 1];
  }

  void _showMonthPickerDialog(BuildContext context) {
    final availableMonths = _extractAvailableMonths(csvData);

    int? selectedMonth = availableMonths.isNotEmpty
        ? availableMonths.first['month']
        : null;
    int? selectedYear = availableMonths.isNotEmpty
        ? availableMonths.first['year']
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Monat auswählen"),
          content: DropdownButtonFormField<Map<String, int>>(
            value: availableMonths.first,
            items: availableMonths.map((entry) {
              return DropdownMenuItem(
                value: entry,
                child: Text("${_monthName(entry['month']!)} ${entry['year']}"),
              );
            }).toList(),
            onChanged: (value) {
              selectedMonth = value?['month'];
              selectedYear = value?['year'];
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedMonth != null && selectedYear != null) {
                  generateMonthlyPrayerPdf(
                    csvData,
                    fridayPrayer1,
                    fridayPrayer2,
                    selectedMonth!,
                    selectedYear!,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("PDF erzeugen"),
            ),
          ],
        );
      },
    );
  }

  Row _shuruqAndJumuaRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? BColors.prayerRowDark
                : BColors.prayerRowLight,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: BColors.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  'Shuruq ${getShuruqTimes()}',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 5),
                _openShuruqNotificationSettings(context),
              ],
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: isDark ? BColors.prayerRowDark : BColors.prayerRowLight,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: BColors.primary),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              'Jumua\'a $fridayPrayer1 | $fridayPrayer2',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _openShuruqNotificationSettings(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(actions: [_shuruqNotificationSettings()]),
        );
      },
      child: schedulerHelper.getCurrentPrayerSettings('notify_Sunrise')
          ? Icon(Icons.notifications_none, color: Colors.white)
          : Icon(Icons.notifications_off, color: Colors.white),
    );
  }

  FutureBuilder<DateTime?> _shuruqNotificationSettings() {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
        "Sunrise",
        csvData,
      ),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Sunrise",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }

  SizedBox _divider(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Divider(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
  }
  /* prayertimes tab ends here */

  Text _currentDate(HijriCalendarConfig hijridate, DateTime now, bool isDark) {
    return Text(
      '${hijridate.hDay} ${hijridate.getLongMonthName()} ${hijridate.hYear} | ${now.day}. ${_getMonthName(now.month)}',
      style: TextStyle(
        color: isDark ? Colors.white : BColors.primary,
        fontSize: 13,
      ),
    );
  }

  Text _countdownToNextPrayer(String countdownText, bool isDark) {
    return Text(
      countdownText,
      style: TextStyle(
        color: isDark ? Colors.white : BColors.primary,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text _showNextPrayerText(
    BuildContext context,
    bool isDark,
    bool isIqamaRunning,
  ) {
    if (!isIqamaRunning) {
      return Text(
        '${_showNextPrayer()} in',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : BColors.primary,
        ),
      );
    }
    return Text(
      'Iqama in',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : BColors.primary,
      ),
    );
  }

  Text _mosqueName(BuildContext context, bool isDark) {
    return Text(
      'BBF Verein - Freiburg',
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: isDark ? Colors.white : BColors.primary,
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
}

// Here, user can modify its notifications for all the 5 prayers
class NotificationSettings extends StatelessWidget {
  late final String name;
  List<Map<String, String>> csvData;
  SchedulerHelper schedulerHelper = SchedulerHelper();
  PrayerTimesHelper prayerTimesHelper = PrayerTimesHelper();
  NotificationSettings({
    super.key,
    required this.context,
    required this.prayerKeys,
    required this.name,
    required this.csvData,
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
                          _fajrNotificationSettings(prayerTimesHelper),
                          _dhurNotificationSettings(prayerTimesHelper),
                          _asrNotificationSettings(prayerTimesHelper),
                          _maghribNotificationSettings(prayerTimesHelper),
                          _ishaNotificationSettings(prayerTimesHelper),
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
      // bell icon either on or off, depending on settings
      child: schedulerHelper.getCurrentPrayerSettings('notify_$name')
          ? Icon(Icons.notifications_none, color: Colors.white)
          : Icon(Icons.notifications_off, color: Colors.white),
    );
  }

  FutureBuilder<DateTime?> _ishaNotificationSettings(
    PrayerTimesHelper prayerTimesHelper,
  ) {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
        "Isha",
        csvData,
      ),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Isha",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }

  FutureBuilder<DateTime?> _maghribNotificationSettings(
    PrayerTimesHelper prayerTimesHelper,
  ) {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
        "Maghrib",
        csvData,
      ),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Maghrib",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }

  FutureBuilder<DateTime?> _asrNotificationSettings(
    PrayerTimesHelper prayerTimesHelper,
  ) {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes("Asr", csvData),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Asr",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }

  FutureBuilder<DateTime?> _dhurNotificationSettings(
    PrayerTimesHelper prayerTimesHelper,
  ) {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
        "Dhur",
        csvData,
      ),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Dhur",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }

  FutureBuilder<DateTime?> _fajrNotificationSettings(
    PrayerTimesHelper prayerTimesHelper,
  ) {
    return FutureBuilder(
      future: prayerTimesHelper.getCertainPrayerTimeAsDateTimes(
        "Fajr",
        csvData,
      ),
      builder: (context, asyncSnapshot) {
        return NotificationSettingsPage(
          name: "Fajr",
          prayerTime: asyncSnapshot.data,
        );
      },
    );
  }
}

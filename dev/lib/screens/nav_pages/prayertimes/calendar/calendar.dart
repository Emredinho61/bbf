import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    csvData = await prayerTimesHelper.loadCSV();
    print('${prayerTimesHelper.csvData[0]} ');
    setState(() {});
  }

  List _getEventsForDay(DateTime day) {
    return [];
  }

  DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  List<Map<String, String>> csvData = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String placeHolder = '';

  Map<String, String> _getPrayerTimesForDay(DateTime day) {
    final todayPrayerTimes = prayerTimesHelper.getPrayerTimesForDay(
      csvData,
      day,
    );
    return todayPrayerTimes;
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimes = _getPrayerTimesForDay(_selectedDay ?? DateTime.now());
    if (prayerTimes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        TableCalendar(
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.w500,
              color: Color(0XFF8F9BB3),
              fontSize: 13,
            ),
            weekendStyle: TextStyle(
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.w500,
              color: Color(0XFF8F9BB3),
              fontSize: 13,
            ),
          ),
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2026, 1, 1),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            return _getEventsForDay(day);
          },
        ),
        SizedBox(height: 5,),
        PrayerTimesTable(prayerTimes: prayerTimes),
      ],
    );
  }
}

class PrayerTimesTable extends StatelessWidget {
  const PrayerTimesTable({
    super.key,
    required this.prayerTimes,
  });

  final Map<String, String> prayerTimes;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        TableRow(
          children: prayerTimes.keys
              .map(
                (name) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        TableRow(
          children: prayerTimes.values
              .map(
                (time) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(time, style: TextStyle(fontSize: 10)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

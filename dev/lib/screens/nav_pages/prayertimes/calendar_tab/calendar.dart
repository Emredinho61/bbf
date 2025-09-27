import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
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
    print('${csvData[0]} ');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerTimes = _getPrayerTimesForDay(_selectedDay ?? DateTime.now());
    if (prayerTimes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? BColors.prayerRowDark : BColors.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          width: 380,
          child: TableCalendar(
            locale: 'de_DE',
            rowHeight: 36,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: BColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 163, 206, 164),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDark
                    ? const Color.fromARGB(255, 167, 246, 169)
                    : BColors.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDark
                    ? const Color.fromARGB(255, 167, 246, 169)
                    : BColors.primary,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Color(0XFF8F9BB3),
                fontSize: 13,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white
                    : Color.fromARGB(255, 114, 118, 125),
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
        ),
        SizedBox(height: 20),
        PrayerTimesTable(prayerTimes: prayerTimes),
      ],
    );
  }
}

class PrayerTimesTable extends StatelessWidget {
  const PrayerTimesTable({super.key, required this.prayerTimes});

  final Map<String, String> prayerTimes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 380,
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : BColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Table(
          children: [
            TableRow(
              children: prayerTimes.keys
                  .map(
                    (name) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(name, style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  )
                  .toList(),
            ),
            TableRow(
              children: prayerTimes.values
                  .map(
                    (time) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

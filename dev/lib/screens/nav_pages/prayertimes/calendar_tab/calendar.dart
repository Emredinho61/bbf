import 'dart:collection';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/add_event_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/delete_event_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/delete_single_event_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  UserService userService = UserService();
  AuthService authService = AuthService();

  bool _isUserAdmin = false;
  List<Event> _selectedEvents = [];
  List<Map<String, String>> csvData = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String placeHolder = '';
  Map<DateTime, List<Event>> eventSource = {};
  LinkedHashMap<DateTime, List<Event>> events = LinkedHashMap(
    equals: isSameDay,
    hashCode: (date) => date.day * 10000 + date.month * 100 + date.year,
  );

  Map<String, String> _getPrayerTimesForDay(DateTime day) {
    final todayPrayerTimes = prayerTimesHelper.getPrayerTimesForDay(
      csvData,
      day,
    );
    return todayPrayerTimes;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  void initState() {
    super.initState();
    checkUser();
    _loadCSV();
    _loadEvents();
    _selectedEvents = _getEventsForDay(DateTime.now());
  }

  // check if user is admin
  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      _isUserAdmin = value;
    });
  }

  Future<void> _loadCSV() async {
    csvData = await prayerTimesHelper.loadCSV();
    setState(() {});
  }

  Future<void> _loadEvents() async {
    final eventSource = await calendarService.getAllEvents();

    setState(() {
      events
        ..clear()
        ..addAll(eventSource);
      _selectedEvents = _getEventsForDay(DateTime.now());
    });
    print(
      'Events Loaded ---------------------------------------------------------------------------------->',
    );
  }

  DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  GestureDetector _addEventIcon(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEventPage()),
        );
        if (result == true) {
          setState(() {
            _loadEvents();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: BColors.secondary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: BColors.primary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.add, size: 35, color: BColors.primary),
        ),
      ),
    );
  }

  GestureDetector _deleteCertainEventIcon(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeleteSingleEvent()),
        );
        if (result == true) {
          setState(() {
            _loadEvents();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: BColors.secondary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: BColors.primary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.delete_forever, size: 35, color: BColors.primary),
        ),
      ),
    );
  }

  GestureDetector _deleteEventIcon(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeleteEventPage()),
        );
        if (result == true) {
          print(
            'Result is actually true ------------------------------------------------------------------------>',
          );
          setState(() {
            _loadEvents();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: BColors.secondary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: BColors.primary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.delete, size: 35, color: BColors.primary),
        ),
      ),
    );
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
        if (_isUserAdmin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _deleteEventIcon(context),
              _deleteCertainEventIcon(context),
              _addEventIcon(context),
            ],
          ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? BColors.prayerRowDark : BColors.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BColors.primary),
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
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
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
        SizedBox(height: 5),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: BColors.primary),
            borderRadius: BorderRadius.circular(16),
            color: isDark ? BColors.prayerRowDark : BColors.secondary,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Eventspage(
                    events: _selectedEvents,
                    focusedDay: _focusedDay,
                    isUserAdmin: _isUserAdmin,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.event,
                    color: isDark ? Colors.white : BColors.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Alle Projekte des Tages ansehen',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
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
        border: Border.all(color: BColors.primary),
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

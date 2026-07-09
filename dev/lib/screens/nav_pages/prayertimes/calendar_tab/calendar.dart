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
import 'package:bbf_app/utils/helper/calendar_page_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.week;
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

  BoxDecoration _adminIconDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1F2937) : BColors.secondary,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(color: BColors.primary),
    );
  }

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
        decoration: _adminIconDecoration(context),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(Icons.add, size: 35.sp, color: BColors.primary),
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
        decoration: _adminIconDecoration(context),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(Icons.delete_forever, size: 35.sp, color: BColors.primary),
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
        decoration: _adminIconDecoration(context),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(Icons.delete, size: 35.sp, color: BColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerTimes = _getPrayerTimesForDay(_selectedDay ?? DateTime.now());
    final CalendarPageHelper calendarPageHelper = CalendarPageHelper();
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
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? BColors.prayerRowDark
                : const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(16.r),

            border: Border.all(
              color: BColors.primary.withOpacity(0.3),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.12 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          width: 380.w,
          child: TableCalendar(
            locale: 'de_DE',
            rowHeight: 36,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Monat',
              CalendarFormat.twoWeeks: '2 Wochen',
              CalendarFormat.week: 'Woche',
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
              todayDecoration: BoxDecoration(
                color: BColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 163, 206, 164),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                final isDarkMarker = Theme.of(context).brightness == Brightness.dark;
                final isSelected = isSameDay(_selectedDay, day);
                final isToday = isSameDay(DateTime.now(), day);

                final Color dotColor;
                if (isToday) {
                  dotColor = isDarkMarker ? Colors.white : const Color(0xFF1B5E20);
                } else if (isSelected) {
                  dotColor = isDarkMarker ? Colors.white : const Color(0xFF1B5E20);
                } else {
                  dotColor = BColors.primary;
                }
                return Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((_) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              formatButtonTextStyle: TextStyle(
                color: BColors.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              formatButtonDecoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2937)
                    : BColors.primary.withOpacity(0.08),
                border: Border.all(color: BColors.primary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10.r),
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
                fontSize: 13.sp,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white
                    : Color.fromARGB(255, 114, 118, 125),
                fontSize: 13.sp,
              ),
            ),
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(calendarPageHelper.getCurrentYear(), 1, 1),
            lastDay: DateTime.utc(calendarPageHelper.getCurrentYear(), 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
                print("Ausgewählter Tag: $selectedDay");
                print("Events: $_selectedEvents");
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
        SizedBox(height: 20.h),
        PrayerTimesTable(
          prayerTimes: prayerTimes,
          selectedDate: _selectedDay ?? DateTime.now(),
        ),
        SizedBox(height: 20.h),
        _navButton(
          context,
          isDark: isDark,
          icon: Icons.calendar_month_rounded,
          label: 'Alle Projekte des Tages ansehen',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Eventspage(
                events: _selectedEvents,
                focusedDay: _focusedDay,
                isUserAdmin: _isUserAdmin,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navButton(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? BColors.prayerRowDark
            : BColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: BColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.sp, color: BColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: BColors.primary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTimesTable extends StatelessWidget {
  const PrayerTimesTable({
    super.key,
    required this.prayerTimes,
    required this.selectedDate,
  });

  final Map<String, String> prayerTimes;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: BColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_outlined,
                color: BColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Row(
            children: prayerTimes.entries.map((entry) {
              final isLast = entry.key == prayerTimes.keys.last;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _PrayerTimeItem(
                        name: entry.key,
                        time: entry.value,
                      ),
                    ),

                    if (!isLast)
                      Container(
                        width: 1.w,
                        height: 55.h,
                        color: Colors.grey.withOpacity(0.15),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  const _PrayerTimeItem({required this.name, required this.time});

  final String name;
  final String time;

  IconData _getIcon() {
    switch (name.toLowerCase()) {
      case "fajr":
        return Icons.wb_twilight;
      case "shuruq":
        return Icons.wb_sunny_outlined;
      case "dhur":
        return Icons.light_mode;
      case "asr":
        return Icons.sunny;
      case "maghrib":
        return Icons.wb_twilight_outlined;
      case "isha":
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(_getIcon(), color: BColors.primary, size: 24.sp),

        SizedBox(height: 8.h),

        Text(
          name,
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
        ),

        SizedBox(height: 6.h),

        Text(
          time,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

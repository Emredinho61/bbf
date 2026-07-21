import 'dart:collection';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/add_event_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/all_events_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/favorite_events_page.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/week_calendar_page.dart';
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
          child: Icon(
            Icons.delete_forever,
            size: 35.sp,
            color: BColors.primary,
          ),
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
    final CalendarPageHelper calendarPageHelper = CalendarPageHelper();
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
                final isDarkMarker =
                    Theme.of(context).brightness == Brightness.dark;

                return Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((e) {
                      final dotColor = e is Event
                          ? e.colorFor(isDarkMarker)
                          : BColors.primary;
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
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
              final dayEvents = _getEventsForDay(selectedDay);
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Eventspage(
                    events: dayEvents,
                    focusedDay: selectedDay,
                    isUserAdmin: _isUserAdmin,
                    prayerTimes: _getPrayerTimesForDay(selectedDay),
                  ),
                ),
              );
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _featureCard(
                      context,
                      icon: Icons.view_week_rounded,
                      label: 'Woche',
                      subtitle: 'Events im Überblick',
                      gradientColors: const [
                        Color(0xff1B5E20),
                        Color(0xff2E7D32),
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeekCalendarPage(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _featureCard(
                      context,
                      icon: Icons.list_alt_rounded,
                      label: 'Alle Events',
                      subtitle: 'Vollständige Liste',
                      gradientColors: const [
                        Color(0xff2E7D32),
                        Color(0xff43A047),
                      ],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllEventsPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _wideFeatureCard(
                context,
                icon: Icons.favorite_rounded,
                label: 'Gemerkte Events',
                subtitle: 'Deine gespeicherten Veranstaltungen',
                gradientColors: const [Color(0xff1E4D2B), Color(0xff2E7D32)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteEventsPage()),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: Colors.white, size: 26.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

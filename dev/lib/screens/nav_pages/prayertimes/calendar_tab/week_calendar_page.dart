// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/events/event_notification_sheet.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_detail_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekCalendarPage extends StatefulWidget {
  const WeekCalendarPage({super.key});

  @override
  State<WeekCalendarPage> createState() => _WeekCalendarPageState();
}

class _WeekCalendarPageState extends State<WeekCalendarPage> {
  final CalendarService _calendarService = CalendarService();
  Map<DateTime, List<Event>> _allEvents = {};
  bool _isLoading = true;
  late DateTime _weekStart; // always a Monday

  static const _dayNames = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
    'Freitag', 'Samstag', 'Sonntag',
  ];
  static const _monthNames = [
    '', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
    _loadEvents();
  }

  DateTime _mondayOf(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _calendarService.getAllEvents();
    if (mounted) {
      setState(() {
        _allEvents = events;
        _isLoading = false;
      });
    }
  }

  List<Event> _eventsFor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _allEvents[key] ?? [];
  }

  String _weekLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    final startStr = '${_weekStart.day}. ${_monthNames[_weekStart.month]}';
    final endStr = '${end.day}. ${_monthNames[end.month]} ${end.year}';
    return '$startStr – $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor:
          isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: BColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wochenübersicht',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Week navigation ─────────────────────────────────────────────
          _WeekNavHeader(
            label: _weekLabel(),
            isDark: isDark,
            onPrev: () => setState(
                () => _weekStart = _weekStart.subtract(const Duration(days: 7))),
            onNext: () => setState(
                () => _weekStart = _weekStart.add(const Duration(days: 7))),
          ),

          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 4.h, bottom: 80.h),
                itemCount: 7,
                itemBuilder: (context, i) {
                  final day = _weekStart.add(Duration(days: i));
                  final isToday =
                      DateTime(day.year, day.month, day.day) == todayKey;
                  final events = _eventsFor(day);

                  return _DaySection(
                    day: day,
                    dayName: _dayNames[i],
                    isToday: isToday,
                    events: events,
                    isDark: isDark,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Week navigation header ────────────────────────────────────────────────────

class _WeekNavHeader extends StatelessWidget {
  const _WeekNavHeader({
    required this.label,
    required this.isDark,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final bool isDark;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BColors.primary.withOpacity(0.12),
        ),
        child: Icon(icon, color: BColors.primary, size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? BColors.prayerRowDark : Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(Icons.chevron_left, onPrev),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          _navBtn(Icons.chevron_right, onNext),
        ],
      ),
    );
  }
}

// ── Day section (header + event cards) ───────────────────────────────────────

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.dayName,
    required this.isToday,
    required this.events,
    required this.isDark,
  });

  final DateTime day;
  final String dayName;
  final bool isToday;
  final List<Event> events;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day label row
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              Text(
                dayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: isToday ? BColors.primary : Colors.grey.shade500,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${day.day}.${day.month}.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isToday ? BColors.primary : Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isToday) ...[
                SizedBox(width: 6.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: BColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'HEUTE',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        if (events.isEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 4.h),
            child: Text(
              'Keine Veranstaltungen',
              style: TextStyle(
                  fontSize: 13.sp, color: Colors.grey.shade400),
            ),
          )
        else
          ...events.map(
            (e) => _EventCard(event: e, day: day, isDark: isDark),
          ),
      ],
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatefulWidget {
  const _EventCard({
    required this.event,
    required this.day,
    required this.isDark,
  });

  final Event event;
  final DateTime day;
  final bool isDark;

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  final EventNotificationHelper _notifHelper = EventNotificationHelper();

  Future<void> _openNotificationSheet() async {
    final parts = widget.event.time.split(' - ').first.split(':');
    await showEventNotificationSheet(
      context: context,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      eventDate: widget.day,
      beginHour: int.parse(parts[0]),
      beginMinute: int.parse(parts[1]),
    );
    if (mounted) setState(() {});
  }

  Widget _notifIcon(EventNotificationMode mode, Color color) {
    switch (mode) {
      case EventNotificationMode.off:
        return Icon(Icons.notifications_off_outlined,
            color: Colors.grey.shade400, size: 20.sp);
      case EventNotificationMode.thisEventOnly:
        return Icon(Icons.notifications_active, color: color, size: 20.sp);
      case EventNotificationMode.allFutureEvents:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_active, color: color, size: 20.sp),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: widget.isDark ? BColors.prayerRowDark : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.repeat, size: 10.sp, color: color),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isDark = widget.isDark;
    final color = event.colorFor(isDark);
    final mode = _notifHelper.getEventNotificationMode(event.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event, date: widget.day)),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? BColors.prayerRowDark : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border(left: BorderSide(color: color, width: 3.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(event.icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 12.w),

            // Title + time + location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13.sp, color: Colors.grey.shade500),
                      SizedBox(width: 4.w),
                      Text(
                        event.startPrayer != null
                            ? event.displayTime
                            : '${event.displayTime} Uhr',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13.sp, color: Colors.grey.shade500),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Notification + chevron
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _openNotificationSheet,
                  child: _notifIcon(mode, color),
                ),
                SizedBox(height: 8.h),
                Icon(Icons.chevron_right, color: color, size: 20.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

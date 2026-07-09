import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekCalendarPage extends StatefulWidget {
  const WeekCalendarPage({super.key});

  @override
  State<WeekCalendarPage> createState() => _WeekCalendarPageState();
}

class _WeekCalendarPageState extends State<WeekCalendarPage> {
  final CalendarService _calendarService = CalendarService();
  final EventController _eventController = EventController();
  final GlobalKey<WeekViewState> _weekViewKey = GlobalKey<WeekViewState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final Map<DateTime, List<Event>> allEvents =
        await _calendarService.getAllEvents();

    for (final entry in allEvents.entries) {
      for (final event in entry.value) {
        final calEvent = _toCalendarEvent(event, entry.key);
        if (calEvent != null) _eventController.add(calEvent);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // Converts an Event to a CalendarEventData for the calendar view,
  // since the calendar view uses its own event data structure. Returns null if the conversion fails.
  CalendarEventData? _toCalendarEvent(Event event, DateTime date) {
    try {
      final parts = event.time.split(' - ');
      if (parts.length != 2) return null;

      final startParts = parts[0].trim().split(':');
      final endParts = parts[1].trim().split(':');
      if (startParts.length != 2 || endParts.length != 2) return null;

      final startTime = DateTime(
        date.year, date.month, date.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      var endTime = DateTime(
        date.year, date.month, date.day,
        int.parse(endParts[0]), int.parse(endParts[1]),
      );

      // ensure end is after start
      if (!endTime.isAfter(startTime)) {
        endTime = startTime.add(const Duration(minutes: 30));
      }

      return CalendarEventData(
        title: event.title,
        description: event.location.isNotEmpty ? event.location : null,
        date: date,
        startTime: startTime,
        endTime: endTime,
        color: Event.lightPalette[event.colorIndex % Event.paletteSize],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        backgroundColor:
            isDark ? BColors.backgroundColorDark : const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor:
              isDark ? BColors.backgroundColorDark : Colors.white,
          elevation: 0,
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : WeekView(
                key: _weekViewKey,
                controller: _eventController,
                showLiveTimeLineInAllDays: true,
                liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
                  color: BColors.primary,
                  height: 1.5,
                ),
                weekNumberBuilder: (_) => null,
                weekPageHeaderBuilder: (startDate, endDate) => _WeekHeader(
                  startDate: startDate,
                  endDate: endDate,
                  onPrev: () => _weekViewKey.currentState?.previousPage(),
                  onNext: () => _weekViewKey.currentState?.nextPage(),
                ),
                startDay: WeekDays.monday,
                timeLineWidth: 52.w,
                timeLineBuilder: (date) => Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Text(
                    '${date.hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                eventTileBuilder: (date, events, boundary, startDuration,
                    endDuration) =>
                    _EventTile(events: events, isDark: isDark),
                headerStyle: HeaderStyle(
                  decoration: BoxDecoration(
                    color: isDark ? BColors.prayerRowDark : Colors.white,
                  ),
                  headerTextStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                  leftIcon: Icon(Icons.chevron_left,
                      color: BColors.primary, size: 22.sp),
                  rightIcon: Icon(Icons.chevron_right,
                      color: BColors.primary, size: 22.sp),
                ),
                backgroundColor:
                    isDark ? BColors.backgroundColorDark : Colors.white,
                minDay: DateTime(DateTime.now().year, 1, 1),
                maxDay: DateTime(DateTime.now().year, 12, 31),
                initialDay: DateTime.now(),
                scrollOffset: _scrollOffsetForNow(),
              ),
      ),
    );
  }

  double _scrollOffsetForNow() {
    final now = DateTime.now();
    // 60px per hour, offset to 1 hour before current time
    return ((now.hour - 1).clamp(0, 23)) * 60.0;
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.startDate,
    required this.endDate,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  String _fmt(DateTime d) => '${d.day}.${d.month}.${d.year}';

  Widget _navButton(IconData icon, VoidCallback onPressed, bool isDark) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BColors.primary.withOpacity(0.12),
          border: Border.all(color: BColors.primary.withOpacity(0.3)),
        ),
        child: Icon(icon, color: BColors.primary, size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: isDark ? BColors.prayerRowDark : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navButton(Icons.chevron_left, onPrev, isDark),
          Text(
            '${_fmt(startDate)} – ${_fmt(endDate)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          _navButton(Icons.chevron_right, onNext, isDark),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.events, required this.isDark});

  final List<CalendarEventData> events;
  final bool isDark;

  // Maps a light-palette color back to its dark-palette counterpart.
  Color _resolveColor(Color lightColor) {
    if (!isDark) return lightColor;
    final index = Event.lightPalette.indexOf(lightColor);
    if (index == -1) return lightColor;
    return Event.darkPalette[index];
  }

  @override
  Widget build(BuildContext context) {
    final event = events.first;
    final color = _resolveColor(event.color);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tooNarrow = constraints.maxWidth < 32;
        final tooShort = constraints.maxHeight < 24;

        return Container(
          margin: EdgeInsets.all(1.5.w),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6.r),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: (tooNarrow || tooShort)
              ? const SizedBox.expand()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (constraints.maxHeight > 40 &&
                          event.description != null &&
                          event.description!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          event.description!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}

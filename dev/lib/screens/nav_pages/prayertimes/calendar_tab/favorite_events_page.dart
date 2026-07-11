// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/events/event_notification_sheet.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_detail_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:bbf_app/utils/helper/favorite_events_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteEventsPage extends StatefulWidget {
  const FavoriteEventsPage({super.key});

  @override
  State<FavoriteEventsPage> createState() => _FavoriteEventsPageState();
}

class _FavoriteEventsPageState extends State<FavoriteEventsPage> {
  final CalendarService _calendarService = CalendarService();
  final FavoriteEventsHelper _favHelper = FavoriteEventsHelper();

  // Flat sorted list of (date, event) pairs that are favorited
  List<(DateTime, Event)> _entries = [];
  bool _isLoading = true;

  static const _monthNames = [
    '', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  static const _dayNames = [
    '', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final allEvents = await _calendarService.getAllEvents();
    final favorites = _favHelper.getFavorites();

    final entries = <(DateTime, Event)>[];
    for (final entry in allEvents.entries) {
      for (final event in entry.value) {
        if (favorites.contains(event.id)) {
          entries.add((entry.key, event));
        }
      }
    }

    entries.sort((a, b) => a.$1.compareTo(b.$1));

    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${_dayNames[d.weekday]}, ${d.day}. ${_monthNames[d.month]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Gemerkte Events',
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
          : _entries.isEmpty
              ? _emptyState(isDark)
              : ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: _entries.length,
                  itemBuilder: (context, i) {
                    final (date, event) = _entries[i];
                    final showDateLabel = i == 0 ||
                        !_isSameDay(_entries[i - 1].$1, date);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateLabel) ...[
                          if (i != 0) SizedBox(height: 12.h),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 4.w, bottom: 8.h, top: 4.h),
                            child: Text(
                              _formatDate(date),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                        _FavEventCard(
                          event: event,
                          date: date,
                          isDark: isDark,
                          onUnfavorited: _loadFavorites,
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border,
              size: 56.sp,
              color: isDark ? Colors.white24 : Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'Noch keine Events gemerkt',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tippe das Herz auf einem Event,\num es hier zu speichern.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white38 : Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _FavEventCard extends StatefulWidget {
  const _FavEventCard({
    required this.event,
    required this.date,
    required this.isDark,
    required this.onUnfavorited,
  });

  final Event event;
  final DateTime date;
  final bool isDark;
  final VoidCallback onUnfavorited;

  @override
  State<_FavEventCard> createState() => _FavEventCardState();
}

class _FavEventCardState extends State<_FavEventCard> {
  final FavoriteEventsHelper _favHelper = FavoriteEventsHelper();
  final EventNotificationHelper _notifHelper = EventNotificationHelper();

  Future<void> _toggleFavorite() async {
    await _favHelper.toggleFavorite(widget.event.id);
    widget.onUnfavorited();
  }

  Future<void> _openNotificationSheet() async {
    final parts = widget.event.time.split(' - ').first.split(':');
    await showEventNotificationSheet(
      context: context,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      eventDate: widget.date,
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
            builder: (_) =>
                EventDetailPage(event: event, date: widget.date)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: Icon(Icons.favorite, color: color, size: 20.sp),
                ),
                SizedBox(height: 8.h),
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

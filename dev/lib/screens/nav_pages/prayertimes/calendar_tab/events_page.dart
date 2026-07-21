// ignore_for_file: deprecated_member_use

import 'package:bbf_app/components/events/event_notification_sheet.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_detail_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:bbf_app/utils/helper/favorite_events_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Eventspage extends StatefulWidget {
  final List<Event> events;
  final DateTime focusedDay;
  final bool isUserAdmin;
  final Map<String, String> prayerTimes;

  const Eventspage({
    super.key,
    required this.events,
    required this.focusedDay,
    required this.isUserAdmin,
    this.prayerTimes = const {},
  });

  @override
  State<Eventspage> createState() => _EventspageState();
}

class _EventspageState extends State<Eventspage> {
  final EventNotificationHelper _eventNotificationHelper =
      EventNotificationHelper();
  final FavoriteEventsHelper _favHelper = FavoriteEventsHelper();

  String get formattedDate {
    return "${widget.focusedDay.day}."
        "${widget.focusedDay.month}."
        "${widget.focusedDay.year}";
  }

  Future<void> _openNotificationSheet(Event event) async {
    // event.time has the format "HH:mm - HH:mm"
    final beginTimeParts = event.time.split(' - ').first.split(':');

    await showEventNotificationSheet(
      context: context,
      eventId: event.id,
      eventTitle: event.title,
      eventDate: widget.focusedDay,
      beginHour: int.parse(beginTimeParts[0]),
      beginMinute: int.parse(beginTimeParts[1]),
    );

    // refresh so the bell icon reflects the (possibly changed) mode
    if (mounted) setState(() {});
  }

  static const _prayerIcons = {
    'Fajr': Icons.wb_twilight,
    'Shuruq': Icons.wb_sunny_outlined,
    'Dhur': Icons.light_mode,
    'Asr': Icons.sunny,
    'Maghrib': Icons.wb_twilight_outlined,
    'Isha': Icons.nightlight_round,
  };

  Widget _buildPrayerTimesCard(bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.prayerTimes.entries.map((entry) {
          final icon = _prayerIcons[entry.key] ?? Icons.access_time;
          final isLast = entry.key == widget.prayerTimes.keys.last;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: BColors.primary, size: 20.sp),
                      SizedBox(height: 6.h),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 40.h,
                    color: Colors.grey.withOpacity(0.15),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xffFAFAFA),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pop tab
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                      color: Colors.green,
                    ),
                  ),

                  // Title of Tab
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.events.isEmpty
                          ? Text(
                              "Keine Projekte am $formattedDate",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xff263238),
                              ),
                            )
                          : Text(
                              "Projekte am $formattedDate",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xff263238),
                              ),
                            ),
                      SizedBox(height: 5.h),
                      if (widget.events.isNotEmpty)
                        Text(
                          "Übersicht aller Projekte und Aktivitäten",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // All Events
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 14.w),

                itemCount:
                    widget.events.length +
                    (widget.prayerTimes.isNotEmpty ? 1 : 0),

                itemBuilder: (context, index) {
                  if (widget.prayerTimes.isNotEmpty && index == 0) {
                    return _buildPrayerTimesCard(isDark);
                  }
                  final eventIndex = widget.prayerTimes.isNotEmpty
                      ? index - 1
                      : index;
                  final event = widget.events[eventIndex];
                  final color = event.colorFor(isDark);

                  final isFav = _favHelper.isFavorite(event.id);
                  final notifMode = _eventNotificationHelper
                      .getEventNotificationMode(event.id);
                  final notifActive = notifMode != EventNotificationMode.off;

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: isDark ? BColors.prayerRowDark : Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border(
                        left: BorderSide(color: color, width: 3.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailPage(
                            event: event,
                            date: widget.focusedDay,
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Main content ──
                          Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52.r,
                                  height: 52.r,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    event.icon,
                                    color: color,
                                    size: 26.sp,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              'Veranstaltung',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 20.sp,
                                            color: Colors.grey.shade400,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        event.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 13.sp,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            event.startPrayer != null
                                                ? event.displayTime
                                                : '${event.displayTime} Uhr',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 13.sp,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(width: 5.w),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey.shade500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Action bar ──
                          Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.06),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                // Merken
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      await _favHelper.toggleFavorite(event.id);
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isFav
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            size: 18.sp,
                                            color: isFav
                                                ? color
                                                : Colors.grey.shade400,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            isFav ? 'Gemerkt' : 'Merken',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isFav
                                                  ? color
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Divider
                                VerticalDivider(
                                  width: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.06),
                                ),

                                // Erinnerung
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _openNotificationSheet(event),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Icon(
                                                notifActive
                                                    ? Icons
                                                          .notifications_rounded
                                                    : Icons
                                                          .notifications_none_rounded,
                                                size: 18.sp,
                                                color: notifActive
                                                    ? color
                                                    : Colors.grey.shade400,
                                              ),
                                              if (notifMode ==
                                                  EventNotificationMode
                                                      .allFutureEvents)
                                                Positioned(
                                                  right: -3,
                                                  bottom: -3,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          1.5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? BColors
                                                                .prayerRowDark
                                                          : Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.repeat,
                                                      size: 9.sp,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            notifActive
                                                ? 'Erinnert'
                                                : 'Erinnern',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: notifActive
                                                  ? color
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

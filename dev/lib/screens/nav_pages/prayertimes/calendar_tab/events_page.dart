// ignore_for_file: deprecated_member_use

import 'package:bbf_app/components/events/event_notification_sheet.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_detail_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Eventspage extends StatefulWidget {
  final List<Event> events;
  final DateTime focusedDay;
  final bool isUserAdmin;

  const Eventspage({
    super.key,
    required this.events,
    required this.focusedDay,
    required this.isUserAdmin,
  });

  @override
  State<Eventspage> createState() => _EventspageState();
}

class _EventspageState extends State<Eventspage> {
  final EventNotificationHelper _eventNotificationHelper =
      EventNotificationHelper();

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

  // Renders a distinct icon for each of the three notification modes, so the
  // difference between "this event only" and "all future events" is visible
  // on the card without opening the sheet.
  Widget _notificationIcon(EventNotificationMode mode) {
    switch (mode) {
      case EventNotificationMode.off:
        return const Icon(Icons.notifications_off_outlined, color: Colors.grey);
      case EventNotificationMode.thisEventOnly:
        return const Icon(Icons.notifications_active, color: Colors.green);
      case EventNotificationMode.allFutureEvents:
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_active, color: Colors.green),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.repeat, size: 10.sp, color: Colors.green),
              ),
            ),
          ],
        );
    }
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

                itemCount: widget.events.length,

                itemBuilder: (context, index) {
                  final event = widget.events[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),

                    padding: EdgeInsets.all(14.w),

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

                      border: Border.all(color: Colors.green.withOpacity(0.08)),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,

                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),

                          child: Icon(
                            event.icon,
                            color: Colors.green,
                            size: 30.sp,
                          ),
                        ),

                        SizedBox(width: 14.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            // event type badge
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),

                                child: const Text(
                                  "Veranstaltung",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                ),
                              ),

                              SizedBox(height: 6.h),

                              Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),

                              SizedBox(height: 6.h),

                              // Time of Event
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),

                                  SizedBox(width: 5.w),

                                  Text(
                                    event.startPrayer != null
                                        ? event.displayTime
                                        : "${event.displayTime} Uhr",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),

                              // event location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),

                                  SizedBox(width: 5.w),

                                  Text(
                                    event.location,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // notification settings for this event
                            Builder(
                              builder: (context) {
                                final mode = _eventNotificationHelper
                                    .getEventNotificationMode(event.id);

                                return GestureDetector(
                                  onTap: () => _openNotificationSheet(event),
                                  child: _notificationIcon(mode),
                                );
                              },
                            ),

                            SizedBox(height: 10.h),

                            // show description of event
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailPage(event: event),
                                  ),
                                );
                              },

                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
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

// ignore_for_file: deprecated_member_use

import 'package:bbf_app/components/events/event_notification_sheet.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events_detail_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';

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
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.repeat, size: 10, color: Colors.green),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
                                fontSize: 18,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xff263238),
                              ),
                            ),
                      const SizedBox(height: 5),
                      if (widget.events.isNotEmpty)
                        Text(
                          "Übersicht aller Projekte und Aktivitäten",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // All Events
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                itemCount: widget.events.length,

                itemBuilder: (context, index) {
                  final event = widget.events[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: isDark ? BColors.prayerRowDark : Colors.white,

                      borderRadius: BorderRadius.circular(18),

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
                          width: 60,
                          height: 60,

                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Icon(
                            event.icon,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            // event type badget
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: const Text(
                                  "Veranstaltung",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Time of Event
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    event.startPrayer != null
                                        ? event.displayTime
                                        : "${event.displayTime} Uhr",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // event location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    event.location,
                                    style: TextStyle(
                                      fontSize: 12,
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

                            const SizedBox(height: 10),

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

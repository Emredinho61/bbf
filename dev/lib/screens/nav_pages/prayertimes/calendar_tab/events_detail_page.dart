import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  String get formattedDate {
    final now = DateTime.now();
    return "${now.day}.${now.month}.${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xff121212)
          : const Color(0xffFAFAFA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pop tab
                  Align(
                    alignment: Alignment.topLeft,
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
                      Text(
                        "Projektdetails",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xff263238),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E1E1E) : Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 65,
                          height: 65,

                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            Icons.calendar_month,
                            color: Colors.green,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: const Text(
                                  "Veranstaltung",

                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                event.title,

                                style: TextStyle(
                                  fontSize: 20,

                                  fontWeight: FontWeight.w800,

                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _detailRow(
                      Icons.access_time,
                      "Uhrzeit",
                      "${event.time} Uhr",
                      isDark,
                    ),

                    _divider(),

                    _detailRow(
                      Icons.calendar_today,
                      "Datum",
                      formattedDate,
                      isDark,
                    ),

                    _divider(),

                    _detailRow(
                      Icons.location_on_outlined,
                      "Ort",
                      event.location,
                      isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E1E1E) : Colors.white,

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Beschreibung",

                      style: TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.w800,

                        color: isDark ? Colors.white : const Color(0xff172033),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(width: 75, height: 3, color: Colors.green),

                    const SizedBox(height: 20),

                    Text(
                      event.content.isEmpty
                          ? "Keine Beschreibung vorhanden."
                          : event.content,

                      style: TextStyle(
                        fontSize: 16,

                        height: 1.6,

                        color: isDark
                            ? Colors.grey.shade300
                            : const Color(0xff374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),

        const SizedBox(width: 14),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),

            const SizedBox(height: 3),

            Text(
              value,

              style: TextStyle(
                fontSize: 15,

                fontWeight: FontWeight.w600,

                color: isDark ? Colors.white : const Color(0xff263238),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),

      child: Divider(color: Colors.grey.withOpacity(0.2)),
    );
  }
}

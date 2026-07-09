import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),

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
                      icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
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
                          fontSize: 24.sp,
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

              SizedBox(height: 18.h),

              Container(
                width: double.infinity,

                padding: EdgeInsets.all(16.w),

                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E1E1E) : Colors.white,

                  borderRadius: BorderRadius.circular(22.r),

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
                          width: 65.w,
                          height: 65.h,

                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(18.r),
                          ),

                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.green,
                            size: 34.sp,
                          ),
                        ),

                        SizedBox(width: 14.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 3.h,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),

                                  borderRadius: BorderRadius.circular(20.r),
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

                              SizedBox(height: 8.h),

                              Text(
                                event.title,

                                style: TextStyle(
                                  fontSize: 20.sp,

                                  fontWeight: FontWeight.w800,

                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _detailRow(
                      Icons.access_time,
                      "Uhrzeit",
                      event.startPrayer != null
                          ? event.displayTime
                          : "${event.displayTime} Uhr",
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

              SizedBox(height: 20.h),

              Container(
                width: double.infinity,

                padding: EdgeInsets.all(24.w),

                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff1E1E1E) : Colors.white,

                  borderRadius: BorderRadius.circular(28.r),

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
                        fontSize: 22.sp,

                        fontWeight: FontWeight.w800,

                        color: isDark ? Colors.white : const Color(0xff172033),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    Container(width: 75.w, height: 3.h, color: Colors.green),

                    SizedBox(height: 20.h),

                    Text(
                      event.content.isEmpty
                          ? "Keine Beschreibung vorhanden."
                          : event.content,

                      style: TextStyle(
                        fontSize: 16.sp,

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
        Icon(icon, color: Colors.green, size: 22.sp),

        SizedBox(width: 14.w),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,

              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),

            SizedBox(height: 3.h),

            Text(
              value,

              style: TextStyle(
                fontSize: 15.sp,

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
      padding: EdgeInsets.symmetric(vertical: 10.h),

      child: Divider(color: Colors.grey.withOpacity(0.2)),
    );
  }
}

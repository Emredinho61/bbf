// ignore_for_file: deprecated_member_use

import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;
  final DateTime? date;

  const EventDetailPage({super.key, required this.event, this.date});

  String get formattedDate {
    final d = date ?? DateTime.now();
    return '${d.day}.${d.month}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = event.colorFor(isDark);

    return Scaffold(
      backgroundColor:
          isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Veranstaltung',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: isDark ? BColors.prayerRowDark : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border(left: BorderSide(color: color, width: 4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(event.icon, color: color, size: 28.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'Veranstaltung',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  _detailRow(Icons.access_time, 'Uhrzeit',
                      event.startPrayer != null
                          ? event.displayTime
                          : '${event.displayTime} Uhr',
                      color, isDark),
                  _divider(isDark),
                  _detailRow(Icons.calendar_today, 'Datum', formattedDate,
                      color, isDark),
                  _divider(isDark),
                  _detailRow(Icons.location_on_outlined, 'Ort',
                      event.location.isEmpty ? '–' : event.location,
                      color, isDark),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Description card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? BColors.prayerRowDark : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beschreibung',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(width: 60.w, height: 3.h, color: color),
                  SizedBox(height: 14.h),
                  Text(
                    event.content.isEmpty
                        ? 'Keine Beschreibung vorhanden.'
                        : event.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color,
      bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp, color: Colors.grey.shade500)),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.18)),
    );
  }
}

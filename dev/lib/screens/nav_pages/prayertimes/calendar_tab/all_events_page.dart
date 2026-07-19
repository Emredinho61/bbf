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

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  final CalendarService _calendarService = CalendarService();
  List<EventSummary> _summaries = [];
  bool _isLoading = true;

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
    'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final summaries = await _calendarService.getAllEventSummaries();
    if (mounted) {
      setState(() {
        _summaries = summaries;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day}. ${_monthNames[d.month]} ${d.year}';

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
          'Alle Events',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: BColors.primary, size: 22.sp),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: BColors.primary,
              child: _summaries.isEmpty
                  ? _emptyState(isDark)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      itemCount: _summaries.length,
                      itemBuilder: (context, i) => _SummaryCard(
                        summary: _summaries[i],
                        isDark: isDark,
                        formatDate: _formatDate,
                      ),
                    ),
            ),
    );
  }

  Widget _emptyState(bool isDark) {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64.sp,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Keine aktuellen Events',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Momentan sind keine Events geplant.',
              style:
                  TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatefulWidget {
  const _SummaryCard({
    required this.summary,
    required this.isDark,
    required this.formatDate,
  });

  final EventSummary summary;
  final bool isDark;
  final String Function(DateTime) formatDate;

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  final EventNotificationHelper _notifHelper = EventNotificationHelper();
  final FavoriteEventsHelper _favHelper = FavoriteEventsHelper();

  Future<void> _openNotificationSheet() async {
    await showEventNotificationSheet(
      context: context,
      eventId: widget.summary.id,
      eventTitle: widget.summary.title,
      eventDate: widget.summary.startDate,
      beginHour: widget.summary.beginHour,
      beginMinute: widget.summary.beginMinute,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final isDark = widget.isDark;
    final color = s.colorFor(isDark);
    final mode = _notifHelper.getEventNotificationMode(s.id);
    final isFav = _favHelper.isFavorite(s.id);
    final notifActive = mode != EventNotificationMode.off;
    final dividerColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailPage(event: s.toEvent(), date: s.startDate),
          ),
        ),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(s.icon, color: color, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text('Veranstaltung',
                                  style: TextStyle(fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, size: 20.sp, color: Colors.grey.shade400),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(s.title,
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                        SizedBox(height: 5.h),
                        _infoRow(Icons.access_time,
                            s.startPrayer != null ? s.displayTime : '${s.displayTime} Uhr',
                            Colors.grey.shade500),
                        if (s.location.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          _infoRow(Icons.location_on_outlined, s.location, Colors.grey.shade500),
                        ],
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            _chip(icon: Icons.calendar_today_outlined, label: widget.formatDate(s.startDate), color: color),
                            _chip(icon: Icons.repeat_rounded, label: s.frequencyLabel, color: color),
                            if (s.repeat != 'none')
                              _chip(icon: Icons.event_available_outlined, label: 'bis ${widget.formatDate(s.endDate)}', color: color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await _favHelper.toggleFavorite(s.id);
                        setState(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18.sp, color: isFav ? color : Colors.grey.shade400),
                          SizedBox(width: 6.w),
                          Text(isFav ? 'Gemerkt' : 'Merken',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
                                  color: isFav ? color : Colors.grey.shade500)),
                        ]),
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, color: dividerColor),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openNotificationSheet,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(notifActive ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                                  size: 18.sp, color: notifActive ? color : Colors.grey.shade400),
                              if (mode == EventNotificationMode.allFutureEvents)
                                Positioned(
                                  right: -3, bottom: -3,
                                  child: Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                        color: isDark ? BColors.prayerRowDark : Colors.white,
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.repeat, size: 9.sp, color: color),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 6.w),
                          Text(notifActive ? 'Erinnert' : 'Erinnern',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
                                  color: notifActive ? color : Colors.grey.shade500)),
                        ]),
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
  }

  Widget _infoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: textColor),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

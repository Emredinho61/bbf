// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showAllEventsNotificationSheet({
  required BuildContext context,
  required EventSummary summary,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AllEventsNotificationSheet(summary: summary),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class _AllEventsNotificationSheet extends StatefulWidget {
  const _AllEventsNotificationSheet({required this.summary});
  final EventSummary summary;

  @override
  State<_AllEventsNotificationSheet> createState() =>
      _AllEventsNotificationSheetState();
}

class _AllEventsNotificationSheetState
    extends State<_AllEventsNotificationSheet> {
  final _notifHelper = EventNotificationHelper();
  final _notifServices = NotificationServices();
  final _calService = CalendarService();

  bool _showDayPicker = false;
  bool _isApplying = false;
  List<DateTime> _dates = [];
  bool _loadingDates = false;

  static const _dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
    'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
  ];

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _applyOff() async {
    setState(() => _isApplying = true);
    await _notifServices.cancelEventNotifications(widget.summary.id);
    await _notifHelper.setEventNotificationMode(
      widget.summary.id,
      EventNotificationMode.off,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _applyAllFuture() async {
    setState(() => _isApplying = true);
    await _notifServices.cancelEventNotifications(widget.summary.id);
    await _notifServices.scheduleAllFutureEventNotifications(widget.summary.id);
    await _notifHelper.setEventNotificationMode(
      widget.summary.id,
      EventNotificationMode.allFutureEvents,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openSpecificDays() async {
    // Immediately switch event-level to specificDays → date keys control what's active
    await _notifHelper.setEventNotificationMode(
      widget.summary.id,
      EventNotificationMode.specificDays,
    );
    setState(() => _loadingDates = true);

    final allEvents = await _calService.getAllEvents();
    final now = DateTime.now();
    // Only show dates where the 24h-before notification would still fire
    final cutoff = now.add(const Duration(hours: 24));

    final dates = <DateTime>[];
    for (final entry in allEvents.entries) {
      final eventDateTime = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
        widget.summary.beginHour,
        widget.summary.beginMinute,
      );
      if (!eventDateTime.isAfter(cutoff)) continue;
      for (final event in entry.value) {
        if (event.id == widget.summary.id) {
          dates.add(entry.key);
          break;
        }
      }
    }
    dates.sort();

    if (mounted) {
      setState(() {
        _dates = dates;
        _loadingDates = false;
        _showDayPicker = true;
      });
    }
  }

  Future<void> _toggleDate(DateTime date) async {
    final mode = _notifHelper.getEventNotificationMode(
      widget.summary.id,
      date: date,
    );
    if (mode != EventNotificationMode.off) {
      // Deactivate: remove date-specific key
      await _notifHelper.setEventNotificationMode(
        widget.summary.id,
        EventNotificationMode.off,
        date: date,
      );
    } else {
      // Activate: schedule notification + set date key
      await _notifServices.scheduleEventNotification(
        widget.summary.id,
        widget.summary.title,
        date,
        widget.summary.beginHour,
        widget.summary.beginMinute,
      );
      await _notifHelper.setEventNotificationMode(
        widget.summary.id,
        EventNotificationMode.thisEventOnly,
        date: date,
      );
    }
    if (mounted) setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child:
            _showDayPicker ? _buildDayPicker(isDark) : _buildModeSelection(isDark),
      ),
    );
  }

  // ── Screen 1: mode selection ──────────────────────────────────────────────

  Widget _buildModeSelection(bool isDark) {
    final eventLevel = _notifHelper.getEventNotificationMode(widget.summary.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        _dragHandle(),
        SizedBox(height: 28.h),
        _bellIcon(),
        SizedBox(height: 16.h),
        _titleText('Erinnerungen', isDark),
        SizedBox(height: 8.h),
        _eventChip(),
        SizedBox(height: 28.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _OptionCard(
                icon: Icons.notifications_off_rounded,
                title: 'Alle deaktivieren',
                subtitle: 'Keine Erinnerungen für dieses Event',
                isSelected: eventLevel == EventNotificationMode.off,
                isLoading: _isApplying,
                isDark: isDark,
                onTap: _applyOff,
              ),
              SizedBox(height: 10.h),
              _OptionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Für bestimmte Termine',
                subtitle: 'Wähle gezielt aus, an welchen Tagen du erinnert werden möchtest',
                isSelected: eventLevel == EventNotificationMode.specificDays,
                isLoading: _isApplying || _loadingDates,
                isDark: isDark,
                onTap: _openSpecificDays,
                trailingWidget: _loadingDates
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BColors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 10.h),
              _OptionCard(
                icon: Icons.event_available_rounded,
                title: 'Alle aktivieren',
                subtitle: 'Erinnerungen jeweils 24h vor jeder Veranstaltung dieser Art',
                isSelected: eventLevel == EventNotificationMode.allFutureEvents,
                isLoading: _isApplying,
                isDark: isDark,
                onTap: _applyAllFuture,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _cancelButton(isDark),
        SizedBox(height: 8.h),
      ],
    );
  }

  // ── Screen 2: day picker ──────────────────────────────────────────────────

  Widget _buildDayPicker(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12.h),
        _dragHandle(),
        SizedBox(height: 16.h),

        // Header row with back button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    size: 16.sp, color: BColors.primary),
                onPressed: () => setState(() => _showDayPicker = false),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Termine wählen',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _eventChip(),
                  ],
                ),
              ),
              SizedBox(width: 48.w),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        _dates.isEmpty
            ? Padding(
                padding: EdgeInsets.all(32.w),
                child: Text(
                  'Keine künftigen Termine gefunden',
                  style:
                      TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 380.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _dates.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, i) {
                    final date = _dates[i];
                    final mode = _notifHelper.getEventNotificationMode(
                      widget.summary.id,
                      date: date,
                    );
                    final isActive = mode != EventNotificationMode.off;
                    final dayName = _dayNames[date.weekday - 1];
                    final dateStr =
                        '$dayName, ${date.day}. ${_monthNames[date.month]} ${date.year}';

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? BColors.prayerRowDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: isActive
                            ? Border.all(
                                color: BColors.primary.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: InkWell(
                        onTap: () => _toggleDate(date),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 13.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 15.sp,
                                color: isActive
                                    ? BColors.primary
                                    : Colors.grey.shade500,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? (isDark
                                            ? Colors.white
                                            : const Color(0xFF1C1C1E))
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? BColors.primary.withOpacity(0.12)
                                      : Colors.grey.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isActive
                                      ? Icons.notifications_rounded
                                      : Icons.notifications_none_rounded,
                                  size: 20.sp,
                                  color: isActive
                                      ? BColors.primary
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

        SizedBox(height: 12.h),
        _cancelButton(isDark),
        SizedBox(height: 8.h),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _dragHandle() => Center(
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      );

  Widget _bellIcon() => Container(
        width: 68.r,
        height: 68.r,
        decoration: BoxDecoration(
          color: BColors.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.notifications_rounded,
            color: BColors.primary, size: 34.sp),
      );

  Widget _titleText(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          fontSize: 21.sp,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          letterSpacing: -0.4,
        ),
      );

  Widget _eventChip() => Container(
        constraints: BoxConstraints(maxWidth: 260.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: BColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_rounded, size: 12.sp, color: BColors.primary),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                widget.summary.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: BColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _cancelButton(bool isDark) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isApplying ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? Colors.white38 : Colors.grey.shade400,
              padding: EdgeInsets.symmetric(vertical: 13.h),
            ),
            child: Text(
              'Abbrechen',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
}

// ── Option card ───────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isLoading,
    required this.isDark,
    required this.onTap,
    this.trailingWidget,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isLoading;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final selectedBg = BColors.primary.withOpacity(isDark ? 0.18 : 0.08);
    final unselectedBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? BColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? BColors.primary.withOpacity(0.18)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: isSelected ? BColors.primary : Colors.grey.shade500,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? BColors.primary
                            : (isDark
                                ? Colors.white
                                : const Color(0xFF1C1C1E)),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? BColors.primary.withOpacity(0.65)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              trailingWidget ??
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('check'),
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              color: BColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded,
                                size: 15.sp, color: Colors.white),
                          )
                        : Container(
                            key: const ValueKey('empty'),
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

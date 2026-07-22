// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showEventNotificationSheet({
  required BuildContext context,
  required String eventId,
  required String eventTitle,
  required DateTime eventDate,
  required int beginHour,
  required int beginMinute,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return EventNotificationSheet(
        eventId: eventId,
        eventTitle: eventTitle,
        eventDate: eventDate,
        beginHour: beginHour,
        beginMinute: beginMinute,
      );
    },
  );
}

class EventNotificationSheet extends StatefulWidget {
  const EventNotificationSheet({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.beginHour,
    required this.beginMinute,
  });

  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final int beginHour;
  final int beginMinute;

  @override
  State<EventNotificationSheet> createState() => _EventNotificationSheetState();
}

class _EventNotificationSheetState extends State<EventNotificationSheet> {
  final EventNotificationHelper _notificationHelper = EventNotificationHelper();
  final NotificationServices _notificationServices = NotificationServices();

  late EventNotificationMode _selectedMode;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = _notificationHelper.getEventNotificationMode(
      widget.eventId,
      date: widget.eventDate,
    );
  }

  Future<void> _applyMode(EventNotificationMode mode) async {
    setState(() => _isApplying = true);

    await _notificationServices.cancelEventNotifications(widget.eventId);

    switch (mode) {
      case EventNotificationMode.off:
        break;
      case EventNotificationMode.thisEventOnly:
        await _notificationServices.scheduleEventNotification(
          widget.eventId,
          widget.eventTitle,
          widget.eventDate,
          widget.beginHour,
          widget.beginMinute,
        );
      case EventNotificationMode.allFutureEvents:
        await _notificationServices.scheduleAllFutureEventNotifications(
          widget.eventId,
        );
    }

    await _notificationHelper.setEventNotificationMode(
      widget.eventId,
      mode,
      date: widget.eventDate,
    );

    if (mounted) Navigator.pop(context, mode);
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 28.h),

            // ── Icon ─────────────────────────────────────────────────────
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: BColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: BColors.primary,
                size: 34.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // ── Title ────────────────────────────────────────────────────
            Text(
              'Erinnerungen',
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 8.h),

            // ── Event title chip ─────────────────────────────────────────
            Container(
              constraints: BoxConstraints(maxWidth: 260.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: BColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 12.sp,
                    color: BColors.primary,
                  ),
                  SizedBox(width: 5.w),
                  Flexible(
                    child: Text(
                      widget.eventTitle,
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
            ),
            SizedBox(height: 28.h),

            // ── Options ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _OptionCard(
                    icon: Icons.notifications_off_rounded,
                    title: 'Benachrichtigung aus',
                    subtitle: 'Keine Erinnerungen für dieses Event',
                    isSelected: _selectedMode == EventNotificationMode.off,
                    isLoading: _isApplying,
                    isDark: isDark,
                    onTap: () => _applyMode(EventNotificationMode.off),
                  ),
                  SizedBox(height: 10.h),
                  _OptionCard(
                    icon: Icons.notifications_rounded,
                    title: 'Nur für diesen Termin',
                    subtitle:
                        'Du erhältst eine Erinnerung 24h vor der Veranstaltung am '
                        '${widget.eventDate.day.toString().padLeft(2, '0')}.'
                        '${widget.eventDate.month.toString().padLeft(2, '0')}.'
                        '${widget.eventDate.year}',
                    isSelected:
                        _selectedMode == EventNotificationMode.thisEventOnly,
                    isLoading: _isApplying,
                    isDark: isDark,
                    onTap: () =>
                        _applyMode(EventNotificationMode.thisEventOnly),
                  ),
                  SizedBox(height: 10.h),
                  _OptionCard(
                    icon: Icons.event_available_rounded,
                    title: 'Alle künftigen Termine',
                    subtitle:
                        'Du erhältst jeweils 24h vor jeder Veranstaltung dieser Art eine Erinnerung',
                    isSelected:
                        _selectedMode == EventNotificationMode.allFutureEvents,
                    isLoading: _isApplying,
                    isDark: isDark,
                    onTap: () =>
                        _applyMode(EventNotificationMode.allFutureEvents),
                  ),
                ],
              ),
            ),

            // ── Cancel ───────────────────────────────────────────────────
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isApplying ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white38
                        : Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                  child: Text(
                    'Abbrechen',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isLoading;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg = BColors.primary.withOpacity(isDark ? 0.18 : 0.08);
    final unselectedBg = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);

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
              // Icon container
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

              // Text
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
                            : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
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

              // Check indicator
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
                        child: Icon(
                          Icons.check_rounded,
                          size: 15.sp,
                          color: Colors.white,
                        ),
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

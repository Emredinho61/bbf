import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/event_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Opens the "Benachrichtigungen" bottom sheet for one calendar event
// occurrence and wires the chosen mode to the notification services.
// [eventDate] is the specific day this card belongs to (used when the user
// only wants a reminder for this single occurrence); [beginHour]/
// [beginMinute] are the event's start time, parsed from Event.time.
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
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
  State<EventNotificationSheet> createState() =>
      _EventNotificationSheetState();
}

class _EventNotificationSheetState extends State<EventNotificationSheet> {
  final EventNotificationHelper _notificationHelper =
      EventNotificationHelper();
  final NotificationServices _notificationServices = NotificationServices();

  late EventNotificationMode _selectedMode;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = _notificationHelper.getEventNotificationMode(
      widget.eventId,
    );
  }

  Future<void> _applyMode(EventNotificationMode mode) async {
    setState(() => _isApplying = true);

    // Start from a clean slate so switching modes never leaves stray
    // notifications scheduled under the previous mode.
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

    await _notificationHelper.setEventNotificationMode(widget.eventId, mode);

    if (mounted) Navigator.pop(context, mode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + close button
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Icon(
              Icons.notifications_off_outlined,
              color: BColors.primary,
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'Benachrichtigungen',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Wähle aus, für welche Events du Benachrichtigungen erhalten möchtest.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
            SizedBox(height: 20.h),
            _OptionTile(
              icon: Icons.notifications_off_outlined,
              title: 'Benachrichtigungen aus',
              subtitle: 'Ich möchte keine Benachrichtigungen erhalten.',
              isSelected: _selectedMode == EventNotificationMode.off,
              onTap: _isApplying
                  ? null
                  : () => _applyMode(EventNotificationMode.off),
            ),
            SizedBox(height: 10.h),
            _OptionTile(
              icon: Icons.notifications_outlined,
              title: 'Für diesen Event an',
              subtitle:
                  'Ich möchte nur für diesen Event Benachrichtigungen erhalten.',
              isSelected: _selectedMode == EventNotificationMode.thisEventOnly,
              onTap: _isApplying
                  ? null
                  : () => _applyMode(EventNotificationMode.thisEventOnly),
            ),
            SizedBox(height: 10.h),
            _OptionTile(
              icon: Icons.event_available_outlined,
              title: 'Für alle künftigen Events an',
              subtitle:
                  'Ich möchte für alle zukünftigen Events dieser Art Benachrichtigungen erhalten.',
              isSelected:
                  _selectedMode == EventNotificationMode.allFutureEvents,
              onTap: _isApplying
                  ? null
                  : () => _applyMode(EventNotificationMode.allFutureEvents),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isApplying ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: BColors.primary.withOpacity(0.12),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Abbrechen',
                  style: TextStyle(
                    color: BColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? BColors.primary
                : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: BColors.primary),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? BColors.primary
                  : Colors.grey.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

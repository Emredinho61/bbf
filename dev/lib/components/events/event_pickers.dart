import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventPickers {
  // Opens a time picker and reports the selected time via [onConfirm].
  // [initialTime] preselects the picker; [minTime] restricts the picker so
  // times before it cannot be scrolled to (used for the end-time picker).
  static void pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
    TimeOfDay? minTime,
    required ValueChanged<TimeOfDay> onConfirm,
  }) {
    final now = DateTime.now();

    // Open at minTime when no initialTime is set, so the wheel starts there.
    final effective = initialTime ?? minTime;

    final currentTime = effective == null
        ? null
        : DateTime(now.year, now.month, now.day, effective.hour, effective.minute);

    DatePicker.showTimePicker(
      context,
      showSecondsColumn: false,
      locale: LocaleType.de,
      currentTime: currentTime,
      onConfirm: (time) {
        var picked = TimeOfDay(hour: time.hour, minute: time.minute);
        if (minTime != null) {
          final pickedMin = picked.hour * 60 + picked.minute;
          final floorMin = minTime.hour * 60 + minTime.minute;
          if (pickedMin < floorMin) picked = minTime;
        }
        onConfirm(picked);
      },
    );
  }

  // Opens a date picker and reports the selected date via [onConfirm].
  static void pickDate(
    BuildContext context, {
    required ValueChanged<DateTime> onConfirm,
  }) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2020, 1, 1),
      maxTime: DateTime(2030, 12, 31),
      onConfirm: onConfirm,
      currentTime: DateTime.now(),
      locale: LocaleType.de,
    );
  }

  // Shows a modal bottom sheet for selecting the repeat option.
  static Future<Map<String, String>?> showRepeatPicker(
    BuildContext context, {
    String? currentValue,
  }) async {
    const options = [
      {
        'value': 'none',
        'label': 'Nicht wiederholen',
        'subtitle': 'Das Event findet nur einmal statt',
        'icon': Icons.event_available_rounded,
      },
      {
        'value': 'daily',
        'label': 'Täglich',
        'subtitle': 'Das Event wiederholt sich jeden Tag',
        'icon': Icons.today_rounded,
      },
      {
        'value': 'weekly',
        'label': 'Wöchentlich',
        'subtitle': 'Das Event wiederholt sich jede Woche',
        'icon': Icons.calendar_view_week_rounded,
      },
    ];

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        return StatefulBuilder(
          builder: (context, setModalState) {
            String? selected = currentValue;

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
                    // ── Drag handle ────────────────────────────────────────
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

                    // ── Icon ───────────────────────────────────────────────
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.repeat_rounded,
                        color: BColors.primary,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'Wiederholung',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Wie oft soll dieses Event stattfinden?',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Option cards ───────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: StatefulBuilder(
                        builder: (context, setCardState) {
                          return Column(
                            children: options.map((opt) {
                              final isSelected = selected == opt['value'];
                              final selectedBg = BColors.primary
                                  .withOpacity(isDark ? 0.18 : 0.08);
                              final unselectedBg = isDark
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF2F2F7);

                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setCardState(() => selected = opt['value'] as String);
                                      Navigator.pop(context, {
                                        'value': opt['value'] as String,
                                        'label': opt['label'] as String,
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: EdgeInsets.all(14.w),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? selectedBg
                                            : unselectedBg,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? BColors.primary
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 46.r,
                                            height: 46.r,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? BColors.primary
                                                      .withOpacity(0.18)
                                                  : Colors.grey
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(13.r),
                                            ),
                                            child: Icon(
                                              opt['icon'] as IconData,
                                              size: 22.sp,
                                              color: isSelected
                                                  ? BColors.primary
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  opt['label'] as String,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? BColors.primary
                                                        : (isDark
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF1C1C1E)),
                                                  ),
                                                ),
                                                SizedBox(height: 3.h),
                                                Text(
                                                  opt['subtitle'] as String,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: isSelected
                                                        ? BColors.primary
                                                            .withOpacity(0.65)
                                                        : Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: isSelected
                                                ? Container(
                                                    key: const ValueKey(
                                                        'check'),
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
                                                    key:
                                                        const ValueKey('empty'),
                                                    width: 26.r,
                                                    height: 26.r,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    // ── Cancel ─────────────────────────────────────────────
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white38
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Canonical prayer order used for min/max validation.
  static const _prayerOrder = [
    'Fajr',
    'Sunrise',
    'Dhur',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const _allPrayers = [
    {'value': 'Fajr', 'label': 'Fajr'},
    {'value': 'Sunrise', 'label': 'Shuruq'},
    {'value': 'Dhur', 'label': 'Dhur'},
    {'value': 'Asr', 'label': 'Asr'},
    {'value': 'Maghrib', 'label': 'Maghrib'},
    {'value': 'Isha', 'label': 'Isha'},
  ];

  static IconData _prayerIcon(String value) {
    switch (value) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhur':
        return Icons.light_mode_outlined;
      case 'Asr':
        return Icons.sunny;
      case 'Maghrib':
        return Icons.wb_twilight_outlined;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time_outlined;
    }
  }

  // Returns true if [candidate] is strictly after [min] in the prayer order.
  static bool prayerIsAfter(String candidate, String min) {
    final ci = _prayerOrder.indexOf(candidate);
    final mi = _prayerOrder.indexOf(min);
    return ci > mi;
  }

  // Returns true if [candidate] is at or after [min] in the prayer order.
  static bool prayerIsAtOrAfter(String candidate, String min) {
    final ci = _prayerOrder.indexOf(candidate);
    final mi = _prayerOrder.indexOf(min);
    return ci >= mi;
  }

  // Maps CSV prayer keys to human-readable display names.
  static String prayerDisplayName(String csvKey) {
    const names = {
      'Fajr': 'Fajr',
      'Sunrise': 'Shuruq',
      'Dhur': 'Dhur',
      'Asr': 'Asr',
      'Maghrib': 'Maghrib',
      'Isha': 'Isha',
    };
    return names[csvKey] ?? csvKey;
  }


  // Shows a modal bottom sheet for selecting a prayer as a time reference.
  // [minPrayerValue] hides all prayers that come before the given prayer key,
  // enforcing that end prayer ≥ start prayer.
  static Future<Map<String, String>?> showPrayerPicker(
    BuildContext context, {
    String? currentValue,
    String? minPrayerValue,
  }) async {
    final prayers = minPrayerValue == null
        ? _allPrayers
        : _allPrayers
            .where((p) => prayerIsAfter(p['value']!, minPrayerValue))
            .toList();

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        return StatefulBuilder(
          builder: (context, setCardState) {
            String? selected = currentValue;

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
                    // ── Drag handle ────────────────────────────────────────
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
                    SizedBox(height: 24.h),

                    // ── Icon ───────────────────────────────────────────────
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wb_twilight_rounded,
                        color: BColors.primary,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'Gebet auswählen',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (minPrayerValue != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Frühestes Gebet: ${prayerDisplayName(minPrayerValue)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),

                    // ── Prayer cards ───────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: StatefulBuilder(
                        builder: (context, setInner) {
                          return Column(
                            children: prayers.map((p) {
                              final isSelected = selected == p['value'];
                              final selectedBg = BColors.primary
                                  .withOpacity(isDark ? 0.18 : 0.08);
                              final unselectedBg = isDark
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF2F2F7);

                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        Map<String, String>.from(p),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 13.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? selectedBg
                                            : unselectedBg,
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? BColors.primary
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _prayerIcon(p['value']!),
                                            size: 20.sp,
                                            color: isSelected
                                                ? BColors.primary
                                                : Colors.grey.shade400,
                                          ),
                                          SizedBox(width: 14.w),
                                          Text(
                                            p['label']!,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? BColors.primary
                                                  : (isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1C1C1E)),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 20.sp,
                                              color: BColors.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    // ── Cancel ─────────────────────────────────────────────
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white38
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Shows a modal bottom sheet for selecting the frequency of the event.
  static Future<int?> showFrequencyPicker(
    BuildContext context,
    int currentValue,
  ) async {
    int selectedValue = currentValue.clamp(1, 52);

    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

        const quickValues = [4, 8, 12, 26, 52];

        return StatefulBuilder(
          builder: (context, setModalState) {
            void adjust(int delta) {
              final next = (selectedValue + delta).clamp(1, 52);
              if (next != selectedValue) {
                setModalState(() => selectedValue = next);
              }
            }

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
                    // ── Drag handle ────────────────────────────────────────
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

                    // ── Icon ───────────────────────────────────────────────
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.repeat_rounded,
                        color: BColors.primary,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'Frequenz',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Wie oft soll das Event stattfinden?',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Stepper ────────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StepButton(
                            icon: Icons.remove_rounded,
                            onTap: () => adjust(-1),
                            onLongPress: () => adjust(-5),
                            isDark: isDark,
                          ),
                          Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Text(
                                  '$selectedValue',
                                  key: ValueKey(selectedValue),
                                  style: TextStyle(
                                    fontSize: 56.sp,
                                    fontWeight: FontWeight.w800,
                                    color: BColors.primary,
                                    height: 1,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Wiederholungen',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          _StepButton(
                            icon: Icons.add_rounded,
                            onTap: () => adjust(1),
                            onLongPress: () => adjust(5),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Quick-select chips ─────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: quickValues.map((v) {
                          final active = selectedValue == v;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedValue = v),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? BColors.primary
                                    : (isDark
                                          ? const Color(0xFF2C2C2E)
                                          : const Color(0xFFF2F2F7)),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '$v',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.grey.shade600),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Confirm button ─────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, selectedValue),
                          style: FilledButton.styleFrom(
                            backgroundColor: BColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Bestätigen',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // ── Cancel ─────────────────────────────────────────────
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white38
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'Abbrechen',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Step button ───────────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          icon,
          size: 24.sp,
          color: BColors.primary,
        ),
      ),
    );
  }
}

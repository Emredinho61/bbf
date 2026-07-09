// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/icon_circle.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  CalendarService calendarService = CalendarService();

  final TextEditingController titleTextController = TextEditingController();
  final TextEditingController contentTextController = TextEditingController();
  final TextEditingController locationTextController = TextEditingController();
  final TextEditingController signUpTextController = TextEditingController();

  TimeOfDay? selectedBeginTime;
  TimeOfDay? selectedEndTime;
  DateTime? selectedDate;
  int? frequency;
  String? repeat;
  String? repeatLabel;

  String _iconKey = 'event';

  bool _usePrayerTimes = false;
  String? _startPrayer;
  String? _startPrayerLabel;
  String? _endPrayer;
  String? _endPrayerLabel;

  bool _isSubmitting = false;
  bool _showError = false;

  bool get _isFormValid {
    final timesValid = _usePrayerTimes
        ? (_startPrayer != null && _endPrayer != null)
        : (selectedBeginTime != null && selectedEndTime != null);
    return timesValid &&
        selectedDate != null &&
        repeat != null &&
        (repeat == 'none' || frequency != null) &&
        titleTextController.text.trim().isNotEmpty &&
        contentTextController.text.trim().isNotEmpty &&
        locationTextController.text.trim().isNotEmpty;
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submit() async {
    if (!_isFormValid) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isSubmitting = true);
    final navigator = Navigator.of(context);

    final beginMin = _usePrayerTimes
        ? 0
        : (selectedBeginTime!.hour * 60 + selectedBeginTime!.minute);
    final endMin = _usePrayerTimes
        ? 0
        : (selectedEndTime!.hour * 60 + selectedEndTime!.minute);
    final eventFrequency =
        (repeat == null || repeat == 'none') ? 0 : (frequency ?? 1);

    await calendarService.addEventToBackEnd(
      titleTextController.text,
      contentTextController.text,
      locationTextController.text,
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      beginMin,
      endMin,
      repeat!,
      eventFrequency,
      signUpTextController.text,
      startPrayer: _usePrayerTimes ? _startPrayer : null,
      endPrayer: _usePrayerTimes ? _endPrayer : null,
      iconKey: _iconKey,
    );
    navigator.pop(true);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Event hinzufügen'),
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // ── Icon picker ───────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.emoji_emotions_outlined, 'Icon', isDark),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Event.availableIcons.entries.map((entry) {
                      final selected = _iconKey == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() => _iconKey = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: selected
                                ? BColors.primary.withOpacity(0.12)
                                : (isDark
                                    ? BColors.backgroundColorDark
                                    : const Color(0xFFF7F7F7)),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: selected
                                  ? BColors.primary
                                  : Colors.grey.withOpacity(0.25),
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: Icon(
                            entry.value,
                            size: 24.sp,
                            color:
                                selected ? BColors.primary : Colors.grey.shade500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Zeit ─────────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.schedule_outlined, 'Zeit', isDark),
                  SizedBox(height: 4.h),
                  // Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gebetszeiten verwenden',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                      Switch(
                        value: _usePrayerTimes,
                        activeColor: BColors.primary,
                        onChanged: (v) => setState(() {
                          _usePrayerTimes = v;
                          if (v) {
                            selectedBeginTime = null;
                            selectedEndTime = null;
                          } else {
                            _startPrayer = _startPrayerLabel = null;
                            _endPrayer = _endPrayerLabel = null;
                          }
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  if (_usePrayerTimes) ...[
                    PickerTile(
                      label: 'Startgebet',
                      hint: 'obligatorisch',
                      icon: Icons.wb_twilight_outlined,
                      selected: _startPrayerLabel,
                      onTap: () async {
                        final r = await EventPickers.showPrayerPicker(context);
                        if (r != null) {
                          setState(() {
                            _startPrayer = r['value'];
                            _startPrayerLabel = r['label'];
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                    SizedBox(height: 10.h),
                    PickerTile(
                      label: 'Endgebet',
                      hint: 'obligatorisch',
                      icon: Icons.nightlight_outlined,
                      selected: _endPrayerLabel,
                      onTap: () async {
                        final r = await EventPickers.showPrayerPicker(context);
                        if (r != null) {
                          setState(() {
                            _endPrayer = r['value'];
                            _endPrayerLabel = r['label'];
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                  ] else ...[
                    PickerTile(
                      label: 'Beginn',
                      hint: 'obligatorisch',
                      icon: Icons.access_time_outlined,
                      selectedIcon: Icons.access_time_filled,
                      selected: selectedBeginTime != null
                          ? _formatTime(selectedBeginTime!)
                          : null,
                      onTap: () => EventPickers.pickTime(
                        context,
                        onConfirm: (t) => setState(() => selectedBeginTime = t),
                      ),
                      isDark: isDark,
                    ),
                    SizedBox(height: 10.h),
                    PickerTile(
                      label: 'Ende',
                      hint: 'obligatorisch',
                      icon: Icons.access_time_outlined,
                      selectedIcon: Icons.access_time_filled,
                      selected: selectedEndTime != null
                          ? _formatTime(selectedEndTime!)
                          : null,
                      onTap: () => EventPickers.pickTime(
                        context,
                        onConfirm: (t) => setState(() => selectedEndTime = t),
                      ),
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Datum & Wiederholung ──────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.calendar_month_outlined, 'Datum & Wiederholung', isDark),
                  SizedBox(height: 14.h),
                  PickerTile(
                    label: 'Datum',
                    hint: 'obligatorisch',
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.event_available_outlined,
                    selected: selectedDate != null ? _formatDate(selectedDate!) : null,
                    onTap: () => EventPickers.pickDate(
                      context,
                      onConfirm: (d) => setState(() => selectedDate = d),
                    ),
                    isDark: isDark,
                  ),
                  SizedBox(height: 10.h),
                  PickerTile(
                    label: 'Wiederholen',
                    hint: 'obligatorisch',
                    icon: Icons.repeat_outlined,
                    selectedIcon: Icons.repeat_on_outlined,
                    selected: repeatLabel,
                    onTap: () async {
                      final r = await EventPickers.showRepeatPicker(context);
                      if (r != null) {
                        setState(() {
                          repeat = r['value'];
                          repeatLabel = r['label'];
                          if (repeat == 'none') frequency = null;
                        });
                      }
                    },
                    isDark: isDark,
                  ),
                  if (repeat != null && repeat != 'none') ...[
                    SizedBox(height: 10.h),
                    PickerTile(
                      label: 'Frequenz',
                      hint: 'obligatorisch',
                      icon: Icons.numbers_outlined,
                      selectedIcon: Icons.tag,
                      selected: frequency?.toString(),
                      onTap: () async {
                        final r = await EventPickers.showFrequencyPicker(
                          context,
                          frequency ?? 1,
                        );
                        if (r != null) setState(() => frequency = r);
                      },
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Textfelder ────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.edit_outlined, 'Details', isDark),
                  SizedBox(height: 14.h),
                  _inputField(titleTextController, 'Titel *', isDark),
                  SizedBox(height: 10.h),
                  _inputField(contentTextController, 'Beschreibung *', isDark, maxLines: 3),
                  SizedBox(height: 10.h),
                  _inputField(locationTextController, 'Ort *', isDark),
                  SizedBox(height: 10.h),
                  _inputField(signUpTextController, 'Anmeldelink (optional)', isDark),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Fehler + Button ───────────────────────────────────────────
            AppErrorBanner(
              message: 'Bitte alle Pflichtfelder ausfüllen.',
              visible: _showError,
            ),
            SizedBox(height: 14.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Event hinzufügen',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label, bool isDark) {
    return Row(
      children: [
        IconCircle(icon: icon, iconSize: 18, padding: 6),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) {
        if (_showError) setState(() => _showError = false);
      },
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
        filled: true,
        fillColor:
            isDark ? BColors.backgroundColorDark : const Color(0xFFF7F7F7),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: BColors.primary.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/calendar_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/icon_circle.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Icon picker ───────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.emoji_emotions_outlined, 'Icon', isDark),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Event.availableIcons.entries.map((entry) {
                      final selected = _iconKey == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() => _iconKey = entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? BColors.primary.withOpacity(0.12)
                                : (isDark
                                    ? BColors.backgroundColorDark
                                    : const Color(0xFFF7F7F7)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? BColors.primary
                                  : Colors.grey.withOpacity(0.25),
                              width: selected ? 2 : 1.5,
                            ),
                          ),
                          child: Icon(
                            entry.value,
                            size: 24,
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
            const SizedBox(height: 14),

            // ── Zeit ─────────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.schedule_outlined, 'Zeit', isDark),
                  const SizedBox(height: 4),
                  // Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gebetszeiten verwenden',
                        style: TextStyle(
                          fontSize: 14,
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
                  const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
            const SizedBox(height: 14),

            // ── Datum & Wiederholung ──────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.calendar_month_outlined, 'Datum & Wiederholung', isDark),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
            const SizedBox(height: 14),

            // ── Textfelder ────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.edit_outlined, 'Details', isDark),
                  const SizedBox(height: 14),
                  _inputField(titleTextController, 'Titel *', isDark),
                  const SizedBox(height: 10),
                  _inputField(contentTextController, 'Beschreibung *', isDark, maxLines: 3),
                  const SizedBox(height: 10),
                  _inputField(locationTextController, 'Ort *', isDark),
                  const SizedBox(height: 10),
                  _inputField(signUpTextController, 'Anmeldelink (optional)', isDark),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Fehler + Button ───────────────────────────────────────────
            AppErrorBanner(
              message: 'Bitte alle Pflichtfelder ausfüllen.',
              visible: _showError,
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Event hinzufügen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label, bool isDark) {
    return Row(
      children: [
        IconCircle(icon: icon, iconSize: 18, padding: 6),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
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
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor:
            isDark ? BColors.backgroundColorDark : const Color(0xFFF7F7F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: BColors.primary.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }
}

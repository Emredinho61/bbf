import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:numberpicker/numberpicker.dart';

class EventPickers {
  // Opens a time picker and reports the selected time via [onConfirm].
  // [initialTime] preselects the picker (e.g. with a previously saved time)
  // instead of defaulting to the current clock time.
  static void pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
    required ValueChanged<TimeOfDay> onConfirm,
  }) {
    final now = DateTime.now();
    DatePicker.showTimePicker(
      context,
      showSecondsColumn: false,
      locale: LocaleType.de,
      currentTime: initialTime == null
          ? null
          : DateTime(
              now.year,
              now.month,
              now.day,
              initialTime.hour,
              initialTime.minute,
            ),
      onConfirm: (time) {
        onConfirm(TimeOfDay(hour: time.hour, minute: time.minute));
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
    BuildContext context,
  ) async {
    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text("Nicht wiederholen"),
              onTap: () {
                Navigator.pop(context, {
                  "value": "none",
                  "label": "Nicht wiederholen",
                });
              },
            ),

            ListTile(
              leading: const Icon(Icons.today),
              title: Text("Täglich"),
              onTap: () {
                Navigator.pop(context, {"value": "daily", "label": "Täglich"});
              },
            ),

            ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: Text("Wöchentlich"),
              onTap: () {
                Navigator.pop(context, {
                  "value": "weekly",
                  "label": "Wöchentlich",
                });
              },
            ),
          ],
        );
      },
    );
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
  // Returns a map with "value" (CSV key, e.g. "Sunrise") and "label" (display name, e.g. "Shuruq").
  static Future<Map<String, String>?> showPrayerPicker(
    BuildContext context,
  ) async {
    const prayers = [
      {'value': 'Fajr', 'label': 'Fajr'},
      {'value': 'Sunrise', 'label': 'Shuruq'},
      {'value': 'Dhur', 'label': 'Dhuhr'},
      {'value': 'Asr', 'label': 'Asr'},
      {'value': 'Maghrib', 'label': 'Maghrib'},
      {'value': 'Isha', 'label': 'Isha'},
    ];

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: prayers
              .map(
                (p) => ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(p['label']!),
                  onTap: () => Navigator.pop(
                    context,
                    Map<String, String>.from(p),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // Shows a modal bottom sheet for selecting the frequency of the event.
  static Future<int?> showFrequencyPicker(
    BuildContext context,
    int currentValue,
  ) async {
    int selectedValue = currentValue;

    return await showModalBottomSheet<int>(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Frequenz auswählen",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  SizedBox(height: 20.h),

                  NumberPicker(
                    value: selectedValue,
                    minValue: 1,
                    maxValue: 52,
                    onChanged: (value) {
                      setModalState(() {
                        selectedValue = value;
                      });
                    },
                  ),

                  SizedBox(height: 20.h),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedValue);
                    },
                    child: const Text("Bestätigen"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

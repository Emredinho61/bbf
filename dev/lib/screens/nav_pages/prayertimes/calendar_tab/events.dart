import 'package:flutter/material.dart';

// Raw event data including repeat/schedule info for the overview page.
class EventSummary {
  final String id;
  final String title;
  final String content;
  final String location;
  final String displayTime;
  final int beginHour;
  final int beginMinute;
  final int endHour;
  final int endMinute;
  final DateTime startDate;
  final DateTime endDate;
  final String repeat; // 'none' | 'weekly' | 'daily'
  final int frequency;
  final int colorIndex;
  final String iconKey;
  final String? startPrayer;
  final String? endPrayer;

  const EventSummary({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.displayTime,
    required this.beginHour,
    required this.beginMinute,
    required this.endHour,
    required this.endMinute,
    required this.startDate,
    required this.endDate,
    required this.repeat,
    required this.frequency,
    required this.colorIndex,
    required this.iconKey,
    this.startPrayer,
    this.endPrayer,
  });

  Color colorFor(bool isDark) {
    final index = colorIndex % Event.paletteSize;
    return isDark ? Event.darkPalette[index] : Event.lightPalette[index];
  }

  IconData get icon => Event.availableIcons[iconKey] ?? Icons.event;

  Event toEvent() => Event(
    id,
    title,
    content,
    '${beginHour.toString().padLeft(2, '0')}:${beginMinute.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}',
    location,
    '',
    startPrayer: startPrayer,
    endPrayer: endPrayer,
    iconKey: iconKey,
    colorIndex: colorIndex,
  );

  String get frequencyLabel {
    switch (repeat) {
      case 'weekly':
        return frequency <= 1
            ? 'Wöchentlich'
            : 'Wöchentlich · $frequency Wochen';
      case 'daily':
        return frequency <= 1 ? 'Täglich' : 'Täglich · $frequency Tage';
      default:
        return 'Einmalig';
    }
  }
}

class Event {
  final String id;
  final String title;
  final String content;
  final String time; // always "HH:mm - HH:mm" for programmatic use
  final String location;
  final String link;
  final String? startPrayer; // CSV key, e.g. "Maghrib"
  final String? endPrayer;
  final String iconKey; // one of the keys in availableIcons
  final int colorIndex;

  Event(
    this.id,
    this.title,
    this.content,
    this.time,
    this.location,
    this.link, {
    this.startPrayer,
    this.endPrayer,
    this.iconKey = 'event',
    this.colorIndex = 0,
  });

  static const List<Color> lightPalette = [
    Color(0xFF2E7D32), // Grün
    Color(0xFF1565C0), // Blau
    Color(0xFF6A1B9A), // Lila
    Color(0xFFE65100), // Orange
    Color(0xFFC62828), // Rot
    Color(0xFF00695C), // Türkis
    Color(0xFF283593), // Indigo
    Color(0xFF4E342E), // Braun
  ];

  static const List<Color> darkPalette = [
    Color(0xFF81C784), // Helles Grün
    Color(0xFF64B5F6), // Helles Blau
    Color(0xFFCE93D8), // Helles Lila
    Color(0xFFFFB74D), // Helles Orange
    Color(0xFFEF9A9A), // Helles Rot
    Color(0xFF80CBC4), // Helles Türkis
    Color(0xFF9FA8DA), // Helles Indigo
    Color(0xFFBCAAA4), // Helles Braun
  ];

  static int get paletteSize => lightPalette.length;

  Color colorFor(bool isDark) {
    final index = colorIndex % paletteSize;
    return isDark ? darkPalette[index] : lightPalette[index];
  }

  static const Map<String, IconData> availableIcons = {
    'event': Icons.event,
    'book': Icons.menu_book,
    'community': Icons.groups,
    'children': Icons.child_care,
    'charity': Icons.volunteer_activism,
    'celebration': Icons.celebration,
  };

  IconData get icon => availableIcons[iconKey] ?? Icons.event;

  static const _prayerNames = {
    'Fajr': 'Fajr',
    'Sunrise': 'Shuruq',
    'Dhur': 'Dhur',
    'Asr': 'Asr',
    'Maghrib': 'Maghrib',
    'Isha': 'Isha',
  };

  // Human-readable time string for display in the UI.
  // Prayer-based events show e.g. "Maghrib (18:30) - Isha (20:00)".
  String get displayTime {
    if (startPrayer != null && endPrayer != null) {
      final parts = time.split(' - ');
      final startTime = parts.isNotEmpty ? parts[0] : '??:??';
      final endTime = parts.length > 1 ? parts[1] : '??:??';
      final startLabel = _prayerNames[startPrayer] ?? startPrayer!;
      final endLabel = _prayerNames[endPrayer] ?? endPrayer!;
      return '$startLabel ($startTime) - $endLabel ($endTime)';
    }
    return time;
  }
}

import 'package:flutter/material.dart';

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
  });

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

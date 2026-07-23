import 'package:bbf_app/backend/services/shared_preferences_service.dart';

// specificDays = event-level mode where date-specific keys control each occurrence
enum EventNotificationMode { off, thisEventOnly, allFutureEvents, specificDays }

class EventNotificationHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  // Stores the overall mode: off | allFutureEvents | specificDays
  String _keyFor(String eventId) => 'eventNotificationMode_$eventId';

  // Stores per-date active state when event-level = specificDays
  String _dateKeyFor(String eventId, DateTime date) =>
      'eventNotificationMode_${eventId}_'
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> setEventNotificationMode(
    String eventId,
    EventNotificationMode mode, {
    DateTime? date,
  }) async {
    switch (mode) {
      case EventNotificationMode.off:
        if (date != null) {
          // Only remove the date-specific key; event-level is untouched
          await prefsWithCache.remove(_dateKeyFor(eventId, date));
        } else {
          // Remove the event-level key → fully off
          await prefsWithCache.remove(_keyFor(eventId));
        }
      case EventNotificationMode.specificDays:
        await prefsWithCache.setString(_keyFor(eventId), mode.name);
      case EventNotificationMode.allFutureEvents:
        await prefsWithCache.setString(_keyFor(eventId), mode.name);
      case EventNotificationMode.thisEventOnly:
        // Only set date-specific key; caller is responsible for event-level
        if (date != null) {
          await prefsWithCache.setString(_dateKeyFor(eventId, date), mode.name);
        }
    }
  }

  EventNotificationMode getEventNotificationMode(
    String eventId, {
    DateTime? date,
  }) {
    final stored = prefsWithCache.getString(_keyFor(eventId));
    final eventLevel = EventNotificationMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => EventNotificationMode.off,
    );

    if (date == null) return eventLevel;

    switch (eventLevel) {
      case EventNotificationMode.allFutureEvents:
        return EventNotificationMode.allFutureEvents;
      case EventNotificationMode.specificDays:
        final dateStored = prefsWithCache.getString(_dateKeyFor(eventId, date));
        if (dateStored == EventNotificationMode.thisEventOnly.name) {
          return EventNotificationMode.thisEventOnly;
        }
        return EventNotificationMode.off;
      default:
        return EventNotificationMode.off;
    }
  }
}

import 'package:bbf_app/backend/services/shared_preferences_service.dart';

enum EventNotificationMode { off, thisEventOnly, allFutureEvents }

class EventNotificationHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  // Event-level key — used for allFutureEvents
  String _keyFor(String eventId) => 'eventNotificationMode_$eventId';

  // Occurrence-level key — used for thisEventOnly
  String _dateKeyFor(String eventId, DateTime date) =>
      'eventNotificationMode_${eventId}_'
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> setEventNotificationMode(
    String eventId,
    EventNotificationMode mode, {
    DateTime? date,
  }) async {
    switch (mode) {
      case EventNotificationMode.thisEventOnly:
        // Store under date-specific key; make sure no event-level override exists
        if (date != null) {
          await prefsWithCache.setString(_dateKeyFor(eventId, date), mode.name);
        }
        await prefsWithCache.remove(_keyFor(eventId));
      case EventNotificationMode.allFutureEvents:
        // Store under event-level key; clear any date-specific override for this date
        await prefsWithCache.setString(_keyFor(eventId), mode.name);
        if (date != null) {
          await prefsWithCache.remove(_dateKeyFor(eventId, date));
        }
      case EventNotificationMode.off:
        // Clear both the event-level and the occurrence-level key
        await prefsWithCache.remove(_keyFor(eventId));
        if (date != null) {
          await prefsWithCache.remove(_dateKeyFor(eventId, date));
        }
    }
  }

  EventNotificationMode getEventNotificationMode(
    String eventId, {
    DateTime? date,
  }) {
    // Occurrence-level key takes priority (thisEventOnly for a specific date)
    if (date != null) {
      final dateStored = prefsWithCache.getString(_dateKeyFor(eventId, date));
      if (dateStored != null) {
        return EventNotificationMode.values.firstWhere(
          (m) => m.name == dateStored,
          orElse: () => EventNotificationMode.off,
        );
      }
    }
    // Fall back to event-level key (allFutureEvents)
    final stored = prefsWithCache.getString(_keyFor(eventId));
    return EventNotificationMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => EventNotificationMode.off,
    );
  }
}

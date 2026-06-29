import 'package:bbf_app/backend/services/shared_preferences_service.dart';

// The three notification choices a user can make for a calendar event.
// Stored per event id (the event's title), so picking allFutureEvents for
// one occurrence is reflected consistently on every other occurrence of the
// same event.
enum EventNotificationMode { off, thisEventOnly, allFutureEvents }

class EventNotificationHelper {
  final prefsWithCache = SharedPreferencesService.instance.prefsWithCache;

  String _keyFor(String eventId) => 'eventNotificationMode_$eventId';

  Future<void> setEventNotificationMode(
    String eventId,
    EventNotificationMode mode,
  ) async {
    await prefsWithCache.setString(_keyFor(eventId), mode.name);
  }

  EventNotificationMode getEventNotificationMode(String eventId) {
    final stored = prefsWithCache.getString(_keyFor(eventId));
    return EventNotificationMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => EventNotificationMode.off,
    );
  }
}

import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';

class CalendarPageHelper {
  // dict to save all events
  final Map<DateTime, List<Event>> eventSource = 
      {}; // ex. DateTime(2025, 10, 1, 8, 0): [Event('Test2', '', '',  '')]

  // function to add an event to the dict
  void addEvent(DateTime dateTime, Event event) {
    // keys shouldnt be different from each other, if their differ only in hour and/or minute
    DateTime key = DateTime(dateTime.year, dateTime.month, dateTime.day);
    // if date already exists, then just add event to the List
    if (eventSource.containsKey(key)) {
      eventSource[key]!.add(event);
    }
    // if not, then add a new key value pair
    else {
      eventSource[key] = [event];
    }
  }

  // function to delete an event from the dict
  void deleteEvent(DateTime dateTime, String id) {
    // if dict contains dateTime, then remove the Event with the given id
    if (eventSource.containsKey(dateTime)) {
      eventSource[dateTime]!.removeWhere((Event event) => event.id == id);

      // if there are no more events for that day, then remove key
      if (eventSource[dateTime]!.isEmpty) {
        eventSource.remove(dateTime);
      }
    }
  }
}

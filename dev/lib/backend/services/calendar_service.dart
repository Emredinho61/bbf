import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final projects = FirebaseFirestore.instance.collection('calendarEntries');

  // get all Events from backend
  Future<Map<DateTime, List<Event>>> getAllEvents() async {
    // contains all docs in following format: Map<String, dynamic>; ex. {'title' : 'Quran Schule'}
    final querySnapshots = await projects
        .orderBy('hour', descending: false)
        .orderBy('minute', descending: false)
        .get();

    // iterating through all docs, restructuring the type first and then adding them in all Events
    for (var doc in querySnapshots.docs) {
      // data from backend
      final data = doc.data();

      // creating a DateTime object out of year, month, day, hour, minute fields of data
      final DateTime dateTime = DateTime(
        (data['year'] as num).toInt(),
        (data['month'] as num).toInt(),
        (data['day'] as num).toInt(),
        (data['hour'] as num).toInt(),
        (data['minute'] as num).toInt(),
      );
      // creating an Event object out of data
      final Event event = Event(
        data['id'],
        data['title'],
        data['content'],
        data['time'],
        data['location'],
      );
      calendarPageHelper.addEvent(dateTime, event);
    }

    return calendarPageHelper.eventSource;
  }

  Future<void> addEventToBackEnd(
    String id,
    String title,
    String content,
    String location,
    String time,
    String year,
    String month,
    String day,
    String hour,
    String minute,
  ) async {
    // since these are saved as ints in backend, parse it
    int yearInInt = int.parse(year);
    int monthInInt = int.parse(month);
    int dayInInt = int.parse(day);
    int hourInInt = int.parse(hour);
    int minuteInInt = int.parse(minute);

    // add to backend
    projects.doc(id).set({
      'id': id,
      'title': title,
      'content': content,
      'time': time,
      'location': location,
      'year' : yearInInt,
      'month' : monthInInt,
      'day' : dayInInt,
      'hour' : hourInInt,
      'minute' : minuteInInt
    });
  }
}

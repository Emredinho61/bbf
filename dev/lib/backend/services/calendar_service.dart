import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final projects = FirebaseFirestore.instance.collection('calendarEntries');

  bool isException(DateTime newDatetime, List<DateTime> exceptions) {
    return exceptions.any(
      (exceptionDate) =>
          exceptionDate.year == newDatetime.year &&
          exceptionDate.month == newDatetime.month &&
          exceptionDate.day == newDatetime.day,
    );
  }

  // get all Events from backend
  Future<Map<DateTime, List<Event>>> getAllEvents() async {
    calendarPageHelper.eventSource.clear();
    // contains all docs in following format: Map<String, dynamic>; ex. {'title' : 'Quran Schule'}
    final querySnapshots = await projects
        .orderBy('hour', descending: false)
        .orderBy('minute', descending: false)
        .get();

    // iterating through all docs, restructuring the type first and then adding them in all Events
    for (var doc in querySnapshots.docs) {
      // data from backend
      final data = doc.data();
      final repeat = data['repeat'] ?? 'none';
      final frequency = data['frequency'] ?? 1;
      final Map<String, dynamic> allExceptions = Map<String, dynamic>.from(
        data['exceptions'] ?? {},
      ); // Format: {1:['2025', '10', '17']}

      // creating a List of DateTimes containing all exceptions
      List<DateTime> exceptionList = [];

      // iterating through map
      if (allExceptions.isNotEmpty) {
        print('Found exceptions: ${allExceptions.values}');
        for (var exception in allExceptions.entries) {
          final List<dynamic> datePartsDynamic = exception.value;
          final List<String> dateParts = datePartsDynamic
              .map((e) => e.toString())
              .toList();

          if (dateParts.length != 3) {
            continue;
          }
          DateTime exceptionDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            (data['hour'] as num).toInt(),
            (data['minute'] as num).toInt(),
          );
          print(
            '$exceptionDate---------------------------------------------------------------------------------------------',
          );

          exceptionList.add(exceptionDate);
        }
      }

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
        data['link'] ?? '',
      );

      // if repetitive weekly
      if (repeat == 'weekly') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = dateTime.add(Duration(days: i * 7));

          if (!isException(newDatetime, exceptionList)) {
            calendarPageHelper.addEvent(newDatetime, event);
          }
        }
      }
      // else if repetitive daily
      if (repeat == 'daily') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = dateTime.add(Duration(days: i));

          if (!isException(newDatetime, exceptionList)) {
            calendarPageHelper.addEvent(newDatetime, event);
          }
        }
      }
      // else (not repetitive)
      else {
        calendarPageHelper.addEvent(dateTime, event);
      }
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
    String repeat,
    String frequency,
    String signUpTextController,
  ) async {
    // since these are saved as ints in backend, parse it
    int yearInInt = int.parse(year);
    int monthInInt = int.parse(month);
    int dayInInt = int.parse(day);
    int hourInInt = int.parse(hour);
    int minuteInInt = int.parse(minute);
    int frequencyInInt = int.parse(frequency);

    // add to backend
    projects.doc(id).set({
      'id': id,
      'title': title,
      'content': content,
      'time': time,
      'location': location,
      'year': yearInInt,
      'month': monthInInt,
      'day': dayInInt,
      'hour': hourInInt,
      'minute': minuteInInt,
      'repeat': repeat,
      'frequency': frequencyInInt,
      'link': signUpTextController,
    });
  }

  Future<void> deleteEventsWithId(String id) async {
    await projects.doc(id).delete();
  }

  Future<void> addExceptionOrDeleteSingleEvent(
    String id,
    String year,
    String month,
    String day,
  ) async {
    final dateParts = [year, month, day];
    final docRef = projects.doc(id);
    final snapshot = await docRef.get();

    // if event is not a repetitive one, then just delete it
    if (snapshot.data()!['repeat'] == 'none') {
      await deleteEventsWithId(id);
      return;
    }

    // get existing Exceptions and if there is none, create a new empty one
    Map<String, dynamic> existingExceptions = Map<String, dynamic>.from(
      snapshot.data()?['exceptions'] ?? {},
    );

    final newKey = (existingExceptions.length + 1).toString();

    existingExceptions[newKey] = dateParts;

    await docRef.update({'exceptions': existingExceptions});
  }
}

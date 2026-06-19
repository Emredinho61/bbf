import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/helper/calendar_page_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final projects = FirebaseFirestore.instance.collection('calendarEntries');
  final CalendarPageHelper calendarPageHelper = CalendarPageHelper();

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
        .orderBy('beginninghour', descending: false)
        .orderBy('beginningminute', descending: false)
        .get(); // sorting by time, so that they are added in the right order in calendarPageHelper.eventSource

    print("Dokumente gefunden: ${querySnapshots.docs.length}");

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
            // (data['hour'] as num).toInt(),
            // (data['minute'] as num).toInt(),
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
        // (data['hour'] as num).toInt(),
        // (data['minute'] as num).toInt(),
      );
      // creating an Event object out of data
      final Event event = Event(
        data['id'],
        data['title'],
        data['content'],
        '${data['beginninghour'].toString().padLeft(2, '0')}:${data['beginningminute'].toString().padLeft(2, '0')} - ${data['endhour'].toString().padLeft(2, '0')}:${data['endminute'].toString().padLeft(2, '0')}',
        data['location'],
        data['link'] ?? '',
      );

      // if repetitive weekly
      if (repeat == 'weekly') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = dateTime.add(Duration(days: i * 7));

          if (!isException(newDatetime, exceptionList)) {
            print("Event hinzugefügt: ${event.title} am $newDatetime");
            calendarPageHelper.addEvent(newDatetime, event);
          }
        }
      }
      // else if repetitive daily
      if (repeat == 'daily') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = dateTime.add(Duration(days: i));

          if (!isException(newDatetime, exceptionList)) {
            print("Event hinzugefügt: ${event.title} am $newDatetime");
            calendarPageHelper.addEvent(newDatetime, event);
          }
        }
      }
      // else (not repetitive)
      else {
        print("Event hinzugefügt: ${event.title} am $dateTime");
        calendarPageHelper.addEvent(dateTime, event);
      }
    }
    print("VOR RETURN: ${calendarPageHelper.eventSource.length}");
    return calendarPageHelper.eventSource;
  }

  Future<void> addEventToBackEnd(
    String title,
    String content,
    String location,
    int year,
    int month,
    int day,
    int beginTimeInMinutes,
    int endTimeInMinutes,
    String repeat,
    int frequency,
    String signUpTextController,
  ) async {
    // add to backend
    projects.doc(title).set({
      'id': title,
      'title': title,
      'content': content,
      'location': location,
      'year': year,
      'month': month,
      'day': day,
      'beginninghour': beginTimeInMinutes ~/ 60,
      'beginningminute': beginTimeInMinutes % 60,
      'endhour': endTimeInMinutes ~/ 60,
      'endminute': endTimeInMinutes % 60,
      'repeat': repeat,
      'frequency': frequency,
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

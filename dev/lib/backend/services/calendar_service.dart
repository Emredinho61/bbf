import 'dart:math';

import 'package:bbf_app/screens/nav_pages/prayertimes/calendar_tab/events.dart';
import 'package:bbf_app/utils/helper/calendar_page_helper.dart';
import 'package:bbf_app/utils/helper/prayer_times_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final projects = FirebaseFirestore.instance.collection('calendarEntries');
  final CalendarPageHelper calendarPageHelper = CalendarPageHelper();
  final PrayerTimesHelper _prayerTimesHelper = PrayerTimesHelper();

  bool isException(DateTime newDatetime, List<DateTime> exceptions) {
    return exceptions.any(
      (exceptionDate) =>
          exceptionDate.year == newDatetime.year &&
          exceptionDate.month == newDatetime.month &&
          exceptionDate.day == newDatetime.day,
    );
  }

  // get all Events from backend
  Future<Map<DateTime, List<Event>>> getAllEvents([
    List<Map<String, String>> csvData = const [],
  ]) async {
    calendarPageHelper.eventSource.clear();
    final querySnapshots = await projects.get();

    // CSV is loaded lazily the first time a prayer-based event is encountered.
    List<Map<String, String>>? resolvedCsvData =
        csvData.isEmpty ? null : csvData;

    for (var doc in querySnapshots.docs) {
      final data = doc.data();
      final repeat = data['repeat'] ?? 'none';
      final frequency = data['frequency'] ?? 1;
      final Map<String, dynamic> allExceptions = Map<String, dynamic>.from(
        data['exceptions'] ?? {},
      );

      List<DateTime> exceptionList = [];
      if (allExceptions.isNotEmpty) {
        for (var exception in allExceptions.entries) {
          final List<String> dateParts = (exception.value as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          if (dateParts.length != 3) continue;
          exceptionList.add(DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          ));
        }
      }

      final DateTime baseDate = DateTime(
        (data['year'] as num).toInt(),
        (data['month'] as num).toInt(),
        (data['day'] as num).toInt(),
      );

      final String? startPrayer = data['startPrayer'] as String?;
      final String? endPrayer = data['endPrayer'] as String?;
      final bool isPrayerBased = startPrayer != null && endPrayer != null;

      if (isPrayerBased) {
        resolvedCsvData ??= await _prayerTimesHelper.loadCSV();
      }

      // Builds an Event for a specific occurrence date.
      // For prayer-based events the time string is resolved per date so that
      // recurring events show the correct prayer time on each individual day.
      Event buildEvent(DateTime occurrenceDate) {
        final String timeString;
        if (isPrayerBased) {
          final dayRow = _prayerTimesHelper.getAnyDayPrayerTimesAsStringMap(
            resolvedCsvData!,
            occurrenceDate,
          );
          final startStr = dayRow[startPrayer] ?? '??:??';
          final endStr = dayRow[endPrayer] ?? '??:??';
          timeString = '$startStr - $endStr';
        } else {
          timeString =
              '${data['beginninghour'].toString().padLeft(2, '0')}:${data['beginningminute'].toString().padLeft(2, '0')} - ${data['endhour'].toString().padLeft(2, '0')}:${data['endminute'].toString().padLeft(2, '0')}';
        }
        return Event(
          data['id'],
          data['title'],
          data['content'],
          timeString,
          data['location'],
          data['link'] ?? '',
          startPrayer: isPrayerBased ? startPrayer : null,
          endPrayer: isPrayerBased ? endPrayer : null,
          iconKey: data['iconKey'] as String? ?? 'event',
          colorIndex: data['colorIndex'] as int? ?? 0,
        );
      }

      if (repeat == 'weekly') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = baseDate.add(Duration(days: i * 7));
          if (!isException(newDatetime, exceptionList)) {
            calendarPageHelper.addEvent(newDatetime, buildEvent(newDatetime));
          }
        }
      }
      if (repeat == 'daily') {
        for (int i = 0; i <= frequency; i++) {
          final newDatetime = baseDate.add(Duration(days: i));
          if (!isException(newDatetime, exceptionList)) {
            calendarPageHelper.addEvent(newDatetime, buildEvent(newDatetime));
          }
        }
      } else {
        calendarPageHelper.addEvent(baseDate, buildEvent(baseDate));
      }
    }

    // Sort each day's events by their resolved start time so that
    // prayer-based and fixed-time events appear in the correct order.
    // event.time has the format "HH:mm - HH:mm", so we parse the first part.
    for (final events in calendarPageHelper.eventSource.values) {
      events.sort((a, b) {
        int parseMinutes(String timeString) {
          final start = timeString.split(' - ').first;
          final parts = start.split(':');
          if (parts.length != 2) return 0;
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          return h * 60 + m;
        }
        return parseMinutes(a.time).compareTo(parseMinutes(b.time));
      });
    }

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
    String signUpTextController, {
    String? startPrayer,
    String? endPrayer,
    String iconKey = 'event',
  }) async {
    final Map<String, dynamic> eventData = {
      'id': title,
      'title': title,
      'content': content,
      'location': location,
      'year': year,
      'month': month,
      'day': day,
      'colorIndex': Random().nextInt(Event.paletteSize),
      // always stored so the Firestore orderBy('beginninghour') query includes
      // this document; prayer-based events use 0 as a placeholder.
      'beginninghour': beginTimeInMinutes ~/ 60,
      'beginningminute': beginTimeInMinutes % 60,
      'endhour': endTimeInMinutes ~/ 60,
      'endminute': endTimeInMinutes % 60,
      'repeat': repeat,
      'frequency': frequency,
      'link': signUpTextController,
      'iconKey': iconKey,
    };
    if (startPrayer != null) {
      eventData['startPrayer'] = startPrayer;
      eventData['endPrayer'] = endPrayer;
    }
    await projects.doc(title).set(eventData);
  }

  Future<List<String>> getAllEventTitles() async {
    final snapshot = await projects.get();
    final titles = snapshot.docs
        .map((doc) => doc.data()['title'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toList()
      ..sort();
    return titles;
  }

  Future<List<EventSummary>> getAllEventSummaries() async {
    final querySnapshots = await projects.get();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final summaries = <EventSummary>[];

    const prayerDisplay = {
      'Fajr': 'Fajr',
      'Sunrise': 'Shuruq',
      'Dhur': 'Dhuhr',
      'Asr': 'Asr',
      'Maghrib': 'Maghrib',
      'Isha': 'Isha',
    };

    for (var doc in querySnapshots.docs) {
      final data = doc.data();
      final repeat = data['repeat'] as String? ?? 'none';
      final frequency = (data['frequency'] as num?)?.toInt() ?? 0;

      final startDate = DateTime(
        (data['year'] as num).toInt(),
        (data['month'] as num).toInt(),
        (data['day'] as num).toInt(),
      );

      final DateTime endDate;
      if (repeat == 'weekly') {
        endDate = startDate.add(Duration(days: frequency * 7));
      } else if (repeat == 'daily') {
        endDate = startDate.add(Duration(days: frequency));
      } else {
        endDate = startDate;
      }

      if (endDate.isBefore(todayKey)) continue;

      final String? startPrayer = data['startPrayer'] as String?;
      final String? endPrayer = data['endPrayer'] as String?;
      final bool isPrayer = startPrayer != null && endPrayer != null;

      final int beginHour = (data['beginninghour'] as num?)?.toInt() ?? 0;
      final int beginMinute = (data['beginningminute'] as num?)?.toInt() ?? 0;
      final int endHour = (data['endhour'] as num?)?.toInt() ?? 0;
      final int endMinute = (data['endminute'] as num?)?.toInt() ?? 0;

      final String displayTime;
      if (isPrayer) {
        final sl = prayerDisplay[startPrayer] ?? startPrayer;
        final el = prayerDisplay[endPrayer] ?? endPrayer;
        displayTime = '$sl - $el';
      } else {
        displayTime =
            '${beginHour.toString().padLeft(2, '0')}:${beginMinute.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
      }

      summaries.add(EventSummary(
        id: data['id'] as String? ?? data['title'] as String? ?? '',
        title: data['title'] as String? ?? '',
        content: data['content'] as String? ?? '',
        location: data['location'] as String? ?? '',
        displayTime: displayTime,
        beginHour: beginHour,
        beginMinute: beginMinute,
        startDate: startDate,
        endDate: endDate,
        repeat: repeat,
        frequency: frequency,
        colorIndex: (data['colorIndex'] as num?)?.toInt() ?? 0,
        iconKey: data['iconKey'] as String? ?? 'event',
        startPrayer: isPrayer ? startPrayer : null,
        endPrayer: isPrayer ? endPrayer : null,
      ));
    }

    summaries.sort((a, b) => a.startDate.compareTo(b.startDate));
    return summaries;
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

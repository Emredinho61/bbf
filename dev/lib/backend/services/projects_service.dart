import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectsService {
  final projects = FirebaseFirestore.instance.collection('projects');

  Future<List<Map<String, dynamic>>> getPastProjects() async {
    // todays date
    final now = DateTime.now();
    final todaysDate = DateTime(now.year, now.month, now.day);

    // snapshot data
    final allProjectsSnapshot = await projects
        .orderBy('date', descending: true)
        .get();

    final oldProjects = allProjectsSnapshot.docs
        .where((doc) {
          final data = doc.data();

          final yearStr = data['year'] as String?;
          final monthStr = data['month'] as String?;
          final dayStr = data['day'] as String?;

          if (yearStr == null || monthStr == null || dayStr == null) {
            return false;
          }

          final year = int.tryParse(yearStr);
          final month = int.tryParse(monthStr);
          final day = int.tryParse(dayStr);

          if (year == null || month == null || day == null) return false;

          final projectDate = DateTime(year, month, day);

          return projectDate.isBefore(todaysDate);
        })
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();

    return oldProjects;
  }

  Future<List<Map<String, dynamic>>> getFutureProjects() async {
    // todays date
    final now = DateTime.now();
    final todaysDate = DateTime(now.year, now.month, now.day);

    // snapshot data
    final allProjectsSnapshot = await projects
        .orderBy('date', descending: true)
        .get();

    final futureProjects = allProjectsSnapshot.docs
        .where((doc) {
          final data = doc.data();

          final yearStr = data['year'] as String?;
          final monthStr = data['month'] as String?;
          final dayStr = data['day'] as String?;

          if (yearStr == null || monthStr == null || dayStr == null) {
            return false;
          }

          final year = int.tryParse(yearStr);
          final month = int.tryParse(monthStr);
          final day = int.tryParse(dayStr);

          if (year == null || month == null || day == null) return false;

          final projectDate = DateTime(year, month, day);

          return projectDate.isAfter(todaysDate) ||
              projectDate.isAtSameMomentAs(todaysDate);
        })
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();

    return futureProjects;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCertainProject(
    String id,
  ) async {
    final doc = await projects.doc(id).get();
    return doc;
  }
}

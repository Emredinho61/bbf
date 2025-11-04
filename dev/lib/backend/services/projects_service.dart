import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectsService {
  final projects = FirebaseFirestore.instance.collection('projects');

  Future<List<Map<String, dynamic>>> getPastProjects() async {
    // todays date
    final now = DateTime.now();
    final todaysDate = DateTime(now.year, now.month, now.day);

    // snapshot data
    final allProjectsSnapshot = await projects
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .orderBy('day', descending: true)
        .get();

    final oldProjects = allProjectsSnapshot.docs
        .where((doc) {
          final data = doc.data();

          final yearInt = data['year'] as int?;
          final monthInt = data['month'] as int?;
          final dayInt = data['day'] as int?;

          if (yearInt == null || monthInt == null || dayInt == null) {
            return false;
          }

          final projectDate = DateTime(yearInt, monthInt, dayInt);

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
        .orderBy('year', descending: false)
        .orderBy('month', descending: false)
        .orderBy('day', descending: false)
        .get();

    final futureProjects = allProjectsSnapshot.docs
        .where((doc) {
          final data = doc.data();

          final yearInt = data['year'] as int?;
          final monthInt = data['month'] as int?;
          final dayInt = data['day'] as int?;

          if (yearInt == null || monthInt == null || dayInt == null) {
            return false;
          }

          final projectDate = DateTime(yearInt, monthInt, dayInt);

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

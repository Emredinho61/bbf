import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectsService {
  final projects = FirebaseFirestore.instance.collection('projects');

  Future<List<Map<String, dynamic>>> getAllProjects() async {
    final allProjectsSnapshot = await projects.orderBy('date', descending: true).get();

    final allProjects = allProjectsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();

    return allProjects;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCertainProject(
    String id,
  ) async {
    final doc = await projects.doc(id).get();
    return doc;
  }
}

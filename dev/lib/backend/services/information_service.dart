import 'package:cloud_firestore/cloud_firestore.dart';

class InformationService {
  final information = FirebaseFirestore.instance.collection('information');

  // get all Information
  Future<List<Map<String, dynamic>>> getAllInformation() async {
    final querySnapshots = await information
        .orderBy('createdAt', descending: true)
        .get();
    final allInformation = querySnapshots.docs
        .map((doc) => doc.data())
        .toList();
    return allInformation;
  }

  // add a new Information to backend
  Future<void> addInformation(
    String id,
    String title,
    String text,
    String expanded,
  ) async {
    information.doc(id).set({
      'id': id,
      'Titel': title,
      'Text': text,
      'Expanded': expanded,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // delete a certain Information
  Future<void> deleteInformation(String id) async {
    await information.doc(id).delete();
  }

  // update a certain Information
  Future<void> updateInformation(
    String id,
    String title,
    String text,
    String expanded,
  ) async {
    information.doc(id).update({
      'id': id,
      'Titel': title,
      'Text': text,
      'Expanded': expanded,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

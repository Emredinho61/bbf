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
    String title,
    String text,
    String expanded,
  ) async {
    information.doc(title).set({
      'Titel': title,
      'Text': text,
      'Expanded': expanded,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // delete a certain Information
  Future<void> deleteInformation(String informationName) async {
    await information.doc(informationName).delete();
  }

  // update a certain Information
  Future<void> updateInformation(
    String title,
    String text,
    String expanded,
  ) async {
    information.doc(title).update({
      'Titel': title,
      'Text': text,
      'Expanded': expanded,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

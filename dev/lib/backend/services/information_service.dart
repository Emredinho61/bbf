import 'package:cloud_firestore/cloud_firestore.dart';

class InformationService {
  final information = FirebaseFirestore.instance.collection('information');

  // get all Information
  Future<List<Map<String, dynamic>>> getAllInformation() async {
    final querySnapshots = await information
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshots.docs.map((doc) => doc.data()).toList();
  }

  // add a new Information.
  // type 'text': title is used as document ID.
  // type 'image': a timestamp-based ID is generated automatically.
  Future<void> addInformation({
    required String type,
    String title = '',
    String text = '',
    String imageUrl = '',
    String orientation = '',
  }) async {
    final id = type == 'text'
        ? title
        : 'image_${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> data = {
      'id': id,
      'Titel': title,
      'Text': text,
      'Image': imageUrl,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (orientation.isNotEmpty) {
      data['orientation'] = orientation;
    }
    await information.doc(id).set(data);
  }

  // delete a certain Information by its ID (= title)
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
    await information.doc(id).update({
      'id': id,
      'Titel': title,
      'Text': text,
      'Expanded': expanded,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

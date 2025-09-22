import 'package:cloud_firestore/cloud_firestore.dart';

class InformationService {
  final information = FirebaseFirestore.instance.collection('information');

  // get all Information
  Future<List<Map<String, dynamic>>> getAllInformation() async {
    final querySnapshots = await information.get();
    final allInformation = querySnapshots.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    return allInformation;
  }

  // add a new Information to backend

  // delete a certain Information

  // update a certain Information
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final _col = FirebaseFirestore.instance.collection('user_feedback');

  Future<void> submitFeedback({
    required String type,
    required String text,
    String? email,
  }) async {
    await _col.add({
      'type': type,
      'text': text,
      if (email != null && email.isNotEmpty) 'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, List<Map<String, dynamic>>>> getAllFeedback() async {
    final snap = await _col.orderBy('timestamp', descending: true).get();

    final result = <String, List<Map<String, dynamic>>>{
      'help': [],
      'wish': [],
      'app': [],
    };

    for (final doc in snap.docs) {
      final data = doc.data();
      final type = data['type'] as String?;
      if (type != null && result.containsKey(type)) {
        result[type]!.add(data);
      }
    }

    return result;
  }
}

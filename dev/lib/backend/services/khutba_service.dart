import 'package:cloud_firestore/cloud_firestore.dart';

class KhutbaService {
  // add Khutba to backend
  final khutba = FirebaseFirestore.instance.collection('khutbas');

  Future<void> addKhutbaToBackend(
    String fileName,
    String pdfUrl,
    timeStamp,
  ) async {
    await khutba.add({'title': fileName, 'pdfUrl': pdfUrl, 'date': timeStamp});
  }
}

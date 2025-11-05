import 'dart:io';
import 'package:bbf_app/backend/services/khutba_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadKhutbaDialog extends StatefulWidget {
  const UploadKhutbaDialog({super.key});

  @override
  State<UploadKhutbaDialog> createState() => _UploadKhutbaDialogState();
}

class _UploadKhutbaDialogState extends State<UploadKhutbaDialog> {
  String? _selectedFileName;
  KhutbaService khutbaService = KhutbaService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      setState(() {
        _selectedFileName = fileName;
      });

      final file = File(filePath);

      // firebase Storage upload
      final storageRef = FirebaseStorage.instance.ref().child(
        'khutbas/$fileName',
      );
      await storageRef.putFile(file);

      final pdfUrl = await storageRef.getDownloadURL();

      // reference to firestore -> save
      await khutbaService.addKhutbaToBackend(
        fileName,
        pdfUrl,
        FieldValue.serverTimestamp(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Khutba PDF hochladen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text("PDF auswählen"),
          ),
          const SizedBox(height: 16),
          if (_selectedFileName != null) Text("Ausgewählt: $_selectedFileName"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: _selectedFileName != null
              ? () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Khutba hochgeladen!")),
                  );
                }
              : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),

          child: const Text("Speichern"),
        ),
      ],
    );
  }
}

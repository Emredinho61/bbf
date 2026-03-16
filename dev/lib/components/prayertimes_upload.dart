import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadPrayerTimesDialog extends StatefulWidget {
  const UploadPrayerTimesDialog({super.key});

  @override
  State<UploadPrayerTimesDialog> createState() => _UploadPrayerTimesDialogState();
}

class _UploadPrayerTimesDialogState extends State<UploadPrayerTimesDialog> {
  String? _selectedCSVName;
  File? _csvFile;

  bool _isUploading = false;
  bool _displayErrorText = false;

  Future<void> _pickCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _csvFile = File(result.files.single.path!);
        _selectedCSVName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadPrayertimes() async {
    if (_csvFile == null) return;

    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;

      final csvRef = storage.ref().child(
        'prayer_times/${_selectedCSVName ?? 'prayer_times.csv'}',
      );

      await csvRef.putFile(_csvFile!);

      final csvUrl = await csvRef.getDownloadURL();

      print("Upload erfolgreich: $csvUrl");

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gebetszeiten erfolgreich hochgeladen!'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Upload failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Hochladen: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Gebetszeiten hochladen"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickCSV,
              icon: const Icon(Icons.description),
              label: const Text("CSV-Datei auswählen"),
            ),
            if (_selectedCSVName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("CSV: $_selectedCSVName"),
              ),
            const SizedBox(height: 8),
            if (_displayErrorText)
              Text(
                'Bitte alle Felder ausfüllen!',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
          ],
        ),
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
          onPressed: () {
            _uploadPrayertimes();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Hochladen"),
        ),
      ],
    );
  }
}

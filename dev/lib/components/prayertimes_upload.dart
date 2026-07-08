// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadPrayerTimesDialog extends StatefulWidget {
  const UploadPrayerTimesDialog({super.key});

  @override
  State<UploadPrayerTimesDialog> createState() =>
      _UploadPrayerTimesDialogState();
}

class _UploadPrayerTimesDialogState extends State<UploadPrayerTimesDialog> {
  String? _selectedCSVName;
  File? _csvFile;
  bool _isUploading = false;
  bool _showError = false;

  Future<void> _pickCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _csvFile = File(result.files.single.path!);
        _selectedCSVName = result.files.single.name;
        _showError = false;
      });
    }
  }

  Future<void> _uploadPrayertimes() async {
    if (_csvFile == null) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;
      final csvRef = storage.ref().child(
        'prayer_times/${_selectedCSVName ?? 'prayer_times.csv'}',
      );
      await csvRef.putFile(_csvFile!);
      final csvUrl = await csvRef.getDownloadURL();
      debugPrint('Upload erfolgreich: $csvUrl');

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hochladen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDialogHeader(
              icon: Icons.access_time_outlined,
              title: 'Gebetszeiten hochladen',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            PickerTile(
              label: 'CSV-Datei',
              hint: 'obligatorisch – .csv',
              icon: Icons.description_outlined,
              selected: _selectedCSVName,
              onTap: _pickCSV,
              isDark: isDark,
            ),

            AppErrorBanner(
              message: 'Bitte eine CSV-Datei auswählen.',
              visible: _showError,
            ),

            const SizedBox(height: 24),
            AppDialogButtonRow(
              isDark: isDark,
              isLoading: _isUploading,
              onConfirm: _uploadPrayertimes,
              confirmLabel: 'Hochladen',
            ),
          ],
        ),
      ),
    );
  }
}

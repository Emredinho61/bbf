import 'dart:io';
import 'package:bbf_app/components/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UploadProjectDialog extends StatefulWidget {
  const UploadProjectDialog({super.key});

  @override
  State<UploadProjectDialog> createState() => _UploadProjectDialogState();
}

class _UploadProjectDialogState extends State<UploadProjectDialog> {
  String? _selectedMarkdownName;
  String? _selectedImageName;
  File? _markdownFile;
  File? _imageFile;
  final TextEditingController _titleController = TextEditingController();

  bool _isUploading = false;
  bool _displayErrorText = false;

  Future<void> _pickMarkdown() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _markdownFile = File(result.files.single.path!);
        _selectedMarkdownName = result.files.single.name;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadProject(int year,int month,int day) async {
    if (_markdownFile == null) return;
    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;

      // Upload markdown
      final markdownRef = storage.ref().child(
        'projects/${_selectedMarkdownName ?? 'project.md'}',
      );
      await markdownRef.putFile(_markdownFile!);
      final markdownUrl = await markdownRef.getDownloadURL();

      // Upload image (optional)
      String imageUrl = '';
      if (_imageFile != null) {
        final originalImage = _imageFile!;
        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          originalImage.path,
          '${originalImage.path}_compressed.jpg',
          quality: 70,
        );

        final compressedImage = compressedXFile != null
            ? File(compressedXFile.path)
            : null;

        final fileToUpload = compressedImage ?? originalImage;

        final imageRef = storage.ref().child(
          'project_images/$_selectedImageName',
        );
        await imageRef.putFile(fileToUpload);
        imageUrl = await imageRef.getDownloadURL();
      }

      // Save Firestore entry
      await FirebaseFirestore.instance.collection('projects').add({
        'title': _titleController.text.isNotEmpty
            ? _titleController.text
            : (_selectedMarkdownName ?? 'Unbenannt'),
        'markdownUrl': markdownUrl,
        'imageUrl': imageUrl,
        'date': FieldValue.serverTimestamp(),
        'year': year,
        'month': month,
        'day': day,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projekt erfolgreich hochgeladen!')),
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
    TextEditingController yearTextEditingController = TextEditingController();
    TextEditingController monthTextEditingController = TextEditingController();
    TextEditingController dayTextEditingController = TextEditingController();
    return AlertDialog(
      title: const Text("Projekt hochladen"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Titel (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickMarkdown,
              icon: const Icon(Icons.description),
              label: const Text("Markdown-Datei auswählen"),
            ),
            if (_selectedMarkdownName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Markdown: $_selectedMarkdownName"),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Bild auswählen (optional)"),
            ),
            if (_selectedImageName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Bild: $_selectedImageName"),
              ),
            const SizedBox(height: 12),
            BTextField(
              label: 'Jahr',
              icon: Icons.time_to_leave_rounded,
              controller: yearTextEditingController,
              obscureText: false,
              obligatory: true,
            ),
            const SizedBox(height: 8),
            BTextField(
              label: 'Monat',
              icon: Icons.time_to_leave_rounded,
              controller: monthTextEditingController,
              obscureText: false,
              obligatory: true,
            ),
            const SizedBox(height: 8),
            BTextField(
              label: 'Tag',
              icon: Icons.time_to_leave_rounded,
              controller: dayTextEditingController,
              obscureText: false,
              obligatory: true,
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
            setState(() {
              if (yearTextEditingController.text.isEmpty ||
                  monthTextEditingController.text.isEmpty ||
                  dayTextEditingController.text.isEmpty) {
                _displayErrorText = true;
                return;
              } else {
                _displayErrorText = false;
              }
            });

            if (_isUploading || _markdownFile == null) return;

            _uploadProject(
              int.parse(yearTextEditingController.text),
              int.parse(monthTextEditingController.text),
              int.parse(dayTextEditingController.text)
            );
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

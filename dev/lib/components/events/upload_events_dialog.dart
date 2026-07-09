// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui' as ui;
import 'package:bbf_app/backend/services/projects_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadProjectDialog extends StatefulWidget {
  const UploadProjectDialog({super.key});

  @override
  State<UploadProjectDialog> createState() => _UploadProjectDialogState();
}

class _UploadProjectDialogState extends State<UploadProjectDialog> {
  late String _pictureOrientation;
  String? _selectedMarkdownName;
  String? _selectedImageName;
  File? _markdownFile;
  File? _imageFile;
  DateTime? _selectedDate;
  bool _isUploading = false;
  bool _showError = false;

  final TextEditingController _titleController = TextEditingController();
  final ProjectsService _projectsService = ProjectsService();

  String? get _formattedDate => _selectedDate == null
      ? null
      : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}';

  // ── File pickers ──────────────────────────────────────────────────────────

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
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _imageFile = file;
        _selectedImageName = result.files.single.name;
        _pictureOrientation =
            frame.image.width > frame.image.height ? 'horizontal' : 'vertical';
      });
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  Future<void> _upload() async {
    if (_markdownFile == null || _selectedDate == null) return;
    setState(() => _isUploading = true);

    try {
      final storage = FirebaseStorage.instance;

      final markdownRef = storage.ref().child(
        'projects/${_selectedMarkdownName ?? 'project.md'}',
      );
      await markdownRef.putFile(_markdownFile!);
      final markdownUrl = await markdownRef.getDownloadURL();

      String imageUrl = '';
      if (_imageFile != null) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          _imageFile!.path,
          '${_imageFile!.path}_compressed.jpg',
          quality: 70,
        );
        final fileToUpload =
            compressed != null ? File(compressed.path) : _imageFile!;
        final imageRef =
            storage.ref().child('project_images/$_selectedImageName');
        await imageRef.putFile(fileToUpload);
        imageUrl = await imageRef.getDownloadURL();
      }

      final title = _titleController.text.trim();

      await _projectsService.addProjectToBackend(
        _pictureOrientation,
        title,
        title,
        markdownUrl,
        imageUrl,
        FieldValue.serverTimestamp(),
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projekt erfolgreich hochgeladen!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hochladen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onUpload() {
    final invalid = _markdownFile == null ||
        _selectedDate == null ||
        _titleController.text.trim().isEmpty;
    setState(() => _showError = invalid);
    if (invalid || _isUploading) return;
    _upload();
  }

  String get _errorMessage {
    final noFile = _markdownFile == null;
    final noDate = _selectedDate == null;
    final noTitle = _titleController.text.trim().isEmpty;

    if (noFile && noDate && noTitle) return 'Bitte alle Pflichtfelder ausfüllen.';
    if (noFile && noDate) return 'Bitte Markdown-Datei und Datum auswählen.';
    if (noFile && noTitle) return 'Bitte Markdown-Datei und Titel ausfüllen.';
    if (noDate && noTitle) return 'Bitte Datum und Titel ausfüllen.';
    if (noFile) return 'Bitte eine Markdown-Datei auswählen.';
    if (noDate) return 'Bitte ein Datum auswählen.';
    return 'Bitte einen Titel eingeben.';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDialogHeader(
                icon: Icons.upload_file_outlined,
                title: 'Projekt hochladen',
                isDark: isDark,
              ),
              SizedBox(height: 24.h),

              // Mandatory
              PickerTile(
                label: 'Markdown-Datei',
                hint: 'obligatorisch – .md / .txt',
                icon: Icons.description_outlined,
                selected: _selectedMarkdownName,
                onTap: _pickMarkdown,
                isDark: isDark,
              ),
              SizedBox(height: 10.h),
              PickerTile(
                label: 'Datum',
                hint: 'obligatorisch – Datum auswählen',
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.event_available_outlined,
                selected: _formattedDate,
                onTap: () => EventPickers.pickDate(
                  context,
                  onConfirm: (date) => setState(() => _selectedDate = date),
                ),
                isDark: isDark,
              ),
              SizedBox(height: 14.h),

              // Optional
              BTextField(
                label: 'Titel',
                controller: _titleController,
                obscureText: false,
                obligatory: true,
              ),
              SizedBox(height: 10.h),
              PickerTile(
                label: 'Bild',
                hint: 'optional',
                icon: Icons.image_outlined,
                selected: _selectedImageName,
                onTap: _pickImage,
                isDark: isDark,
              ),

              AppErrorBanner(message: _errorMessage, visible: _showError),

              SizedBox(height: 24.h),
              AppDialogButtonRow(
                isDark: isDark,
                isLoading: _isUploading,
                onConfirm: _onUpload,
                confirmLabel: 'Hochladen',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _kIcons = [
  (Icons.volunteer_activism, 'Spenden'),
  (Icons.mosque, 'Moschee'),
  (Icons.school, 'Bildung'),
  (Icons.group, 'Gemeinschaft'),
  (Icons.favorite, 'Fürsorge'),
  (Icons.local_hospital, 'Gesundheit'),
  (Icons.restaurant, 'Lebensmittel'),
  (Icons.home, 'Unterkunft'),
  (Icons.child_care, 'Kinder'),
  (Icons.elderly, 'Senioren'),
  (Icons.book, 'Wissen'),
  (Icons.water, 'Wasser'),
  (Icons.eco, 'Umwelt'),
  (Icons.sports_soccer, 'Sport'),
  (Icons.construction, 'Bau'),
  (Icons.attach_money, 'Finanzen'),
  (Icons.healing, 'Heilung'),
  (Icons.star, 'Besonderes'),
  (Icons.people, 'Menschen'),
  (Icons.flash_on, 'Energie'),
];

class ManageMinorProjectDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? projectDoc;

  const ManageMinorProjectDialog({super.key, this.projectDoc});

  @override
  State<ManageMinorProjectDialog> createState() =>
      _ManageMinorProjectDialogState();
}

class _ManageMinorProjectDialogState extends State<ManageMinorProjectDialog> {
  bool _isUploading = false;
  bool _showError = false;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _targetController = TextEditingController();

  int _selectedCodePoint = Icons.volunteer_activism.codePoint;
  File? _imageFile;
  String? _existingImageUrl;

  bool get _isEditMode => widget.projectDoc != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final data = widget.projectDoc!.data();
      if (data != null) {
        _titleController.text = data['title'] ?? '';
        _descController.text = data['description'] ?? '';
        _amountController.text = (data['amount'] ?? 0.0).toStringAsFixed(0);
        _targetController.text = (data['target'] ?? 0.0).toStringAsFixed(0);

        _selectedCodePoint =
            (data['iconCodePoint'] as int?) ??
            Icons.volunteer_activism.codePoint;
        _existingImageUrl = data['imageUrl'] as String?;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _imageFile = File(result.files.single.path!));
    }
  }

  void _removeImage() => setState(() {
    _imageFile = null;
    _existingImageUrl = null;
  });

  Future<void> _saveProject() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());

    if (title.isEmpty ||
        description.isEmpty ||
        amount == null ||
        target == null)
      return;

    setState(() => _isUploading = true);

    try {
      final progress = target > 0 ? (amount / target).clamp(0.0, 1.0) : 0.0;
      final collection = FirebaseFirestore.instance.collection(
        'minor_projects',
      );
      final docRef = _isEditMode
          ? collection.doc(widget.projectDoc!.id)
          : collection.doc();

      // Upload new image if picked
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          _imageFile!.path,
          '${_imageFile!.path}_compressed.jpg',
          quality: 75,
        );
        final fileToUpload = compressed != null
            ? File(compressed.path)
            : _imageFile!;
        final ref = FirebaseStorage.instance.ref().child(
          'minor_project_images/${docRef.id}.jpg',
        );
        await ref.putFile(fileToUpload);
        imageUrl = await ref.getDownloadURL();
      }

      final data = <String, dynamic>{
        'title': title,
        'description': description,
        'amount': amount,
        'target': target,
        'progress': progress,
        'timestamp': FieldValue.serverTimestamp(),
        'iconCodePoint': _selectedCodePoint,
        'imageUrl': imageUrl,
      };

      if (_isEditMode) {
        await docRef.update(data);
      } else {
        await docRef.set(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Projekt aktualisiert!' : 'Projekt hinzugefügt!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onSave() {
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());
    final invalid =
        _titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        amount == null ||
        target == null ||
        target <= 0;
    setState(() => _showError = invalid);
    if (invalid || _isUploading) return;
    _saveProject();
  }

  String get _errorMessage {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty ||
        _targetController.text.trim().isEmpty) {
      return 'Bitte alle Felder ausfüllen.';
    }
    final target = double.tryParse(_targetController.text.trim());
    if (target != null && target <= 0)
      return 'Das Ziel muss größer als 0 sein.';
    return 'Bitte gültige Zahlen eingeben.';
  }

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
                icon: _isEditMode
                    ? Icons.edit_note_outlined
                    : Icons.add_circle_outline,
                title: _isEditMode ? 'Projekt bearbeiten' : 'Neues Projekt',
                isDark: isDark,
              ),
              SizedBox(height: 20.h),

              BTextField(
                label: 'Titel',
                controller: _titleController,
                obscureText: false,
                obligatory: true,
              ),
              SizedBox(height: 12.h),
              BTextField(
                label: 'Beschreibung',
                controller: _descController,
                obscureText: false,
                obligatory: true,
              ),
              SizedBox(height: 12.h),
              BTextField(
                label: 'Aktueller Stand (€)',
                controller: _amountController,
                obscureText: false,
                obligatory: true,
              ),
              SizedBox(height: 12.h),
              BTextField(
                label: 'Ziel (€)',
                controller: _targetController,
                obscureText: false,
                obligatory: true,
              ),

              SizedBox(height: 20.h),

              // Icon selection
              _sectionLabel('Icon auswählen', isDark),
              SizedBox(height: 10.h),
              _buildIconGrid(isDark),

              SizedBox(height: 20.h),

              // Optional image for detail page
              _sectionLabel('Bild für Detailseite (optional)', isDark),
              SizedBox(height: 10.h),
              _buildImagePicker(isDark),

              AppErrorBanner(message: _errorMessage, visible: _showError),

              SizedBox(height: 24.h),
              AppDialogButtonRow(
                isDark: isDark,
                isLoading: _isUploading,
                onConfirm: _onSave,
                confirmLabel: _isEditMode ? 'Aktualisieren' : 'Hinzufügen',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
      ),
    );
  }

  Widget _buildIconGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _kIcons.length,
      itemBuilder: (context, i) {
        final (iconData, label) = _kIcons[i];
        final selected = _selectedCodePoint == iconData.codePoint;
        return GestureDetector(
          onTap: () => setState(() => _selectedCodePoint = iconData.codePoint),
          child: Tooltip(
            message: label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xff2E7D32).withOpacity(0.15)
                    : (isDark
                          ? BColors.backgroundColorDark
                          : const Color(0xFFF5F7FA)),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: selected
                      ? const Color(0xff2E7D32)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                iconData,
                color: selected
                    ? const Color(0xff2E7D32)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(bool isDark) {
    final hasImage = _imageFile != null || _existingImageUrl != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 110.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? BColors.backgroundColorDark : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: _existingImageUrl!,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Ändern',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Bild hinzufügen',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

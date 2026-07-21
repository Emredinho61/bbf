import 'dart:io';
import 'dart:ui' as ui;

import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddInformationPage extends StatefulWidget {
  const AddInformationPage({super.key});

  @override
  State<AddInformationPage> createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {
  final InformationService _informationService = InformationService();
  final TextEditingController _titelController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  String? _type;
  String? _selectedImageName;
  File? _imageFile;
  String _imageOrientation = '';
  bool _isUploading = false;
  bool _showError = false;

  bool get _canUpload {
    if (_type == 'text') return _titelController.text.trim().isNotEmpty;
    if (_type == 'image') {
      return _titelController.text.trim().isNotEmpty && _imageFile != null;
    }
    return false;
  }

  String get _errorMessage {
    if (_type == null) return 'Bitte einen Typ auswählen.';
    if (_titelController.text.trim().isEmpty)
      return 'Bitte einen Titel eingeben.';
    if (_type == 'image' && _imageFile == null)
      return 'Bitte ein Bild auswählen.';
    return '';
  }

  @override
  void dispose() {
    _titelController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<String> _detectOrientation(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final isHorizontal = image.width >= image.height;
    image.dispose();
    return isHorizontal ? 'horizontal' : 'vertical';
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final orientation = await _detectOrientation(file);
      setState(() {
        _imageFile = file;
        _selectedImageName = result.files.single.name;
        _imageOrientation = orientation;
        _showError = false;
      });
    }
  }

  Future<void> _upload() async {
    if (!_canUpload) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isUploading = true);
    try {
      String imageUrl = '';
      if (_imageFile != null) {
        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          _imageFile!.path,
          '${_imageFile!.path}_compressed.jpg',
          quality: 70,
        );
        final fileToUpload = compressedXFile != null
            ? File(compressedXFile.path)
            : _imageFile!;
        final imageRef = FirebaseStorage.instance.ref().child(
          'information_images/$_selectedImageName',
        );
        await imageRef.putFile(fileToUpload);
        imageUrl = await imageRef.getDownloadURL();
      }

      await _informationService.addInformation(
        type: _type!,
        title: _titelController.text.trim(),
        text: _textController.text.trim(),
        imageUrl: imageUrl,
        orientation: _imageOrientation,
      );

      await FirebaseFirestore.instance.collection('broadcasts').add({
        'title': 'Eine neue Nachricht ist verfügbar!',
        'summary': 'Test',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information erfolgreich hochgeladen!')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? BColors.backgroundColorDark
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: BColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Information hinzufügen',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Typ ───────────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.category_outlined, 'Typ', isDark),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _typeCard(
                          'text',
                          Icons.text_fields,
                          'Text',
                          isDark,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _typeCard(
                          'image',
                          Icons.image_outlined,
                          'Bild / Flyer',
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // ── Inhalt ────────────────────────────────────────────────────
            _card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.edit_outlined, 'Inhalt', isDark),
                  SizedBox(height: 14.h),
                  _inputField(
                    controller: _titelController,
                    label: _type == 'image'
                        ? 'Titel (nur für Verwaltung)'
                        : 'Titel',
                    isDark: isDark,
                    onChanged: (_) => setState(() => _showError = false),
                  ),
                  if (_type == 'text') ...[
                    SizedBox(height: 12.h),
                    _inputField(
                      controller: _textController,
                      label: 'Text',
                      isDark: isDark,
                      maxLines: 5,
                    ),
                  ],
                  if (_type == 'image') ...[
                    SizedBox(height: 12.h),
                    PickerTile(
                      label: 'Bild',
                      hint: 'obligatorisch – Bild auswählen',
                      icon: Icons.image_outlined,
                      selectedIcon: Icons.check_circle_outline,
                      selected: _selectedImageName != null
                          ? '$_selectedImageName · $_imageOrientation'
                          : null,
                      onTap: _pickImage,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            AppErrorBanner(message: _errorMessage, visible: _showError),

            SizedBox(height: 24.h),

            // ── Submit button ─────────────────────────────────────────────
            AppDialogButtonRow(
              isDark: isDark,
              isLoading: _isUploading,
              onConfirm: _upload,
              confirmLabel: 'Hochladen',
              cancelLabel: 'Abbrechen',
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: BColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }

  Widget _typeCard(String value, IconData icon, String label, bool isDark) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() {
        _type = value;
        _showError = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: selected
              ? BColors.primary.withOpacity(0.12)
              : (isDark
                    ? BColors.backgroundColorDark
                    : const Color(0xFFF7F7F7)),
          border: Border.all(
            color: selected ? BColors.primary : Colors.grey.withOpacity(0.25),
            width: selected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28.sp,
              color: selected ? BColors.primary : Colors.grey.shade400,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? BColors.primary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      cursorColor: BColors.primary,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
        filled: true,
        fillColor: isDark
            ? BColors.backgroundColorDark
            : const Color(0xFFF7F7F7),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: BColors.primary.withOpacity(0.6),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

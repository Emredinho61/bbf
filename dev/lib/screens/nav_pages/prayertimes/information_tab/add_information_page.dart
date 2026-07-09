import 'dart:io';
import 'dart:ui' as ui;

import 'package:bbf_app/backend/services/information_service.dart';
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

  // null = not yet chosen; 'text' or 'image'
  String? _type;

  String? _selectedImageName;
  File? _imageFile;
  String _imageOrientation = '';
  bool _isUploading = false;

  bool get _canUpload {
    if (_type == 'text') return _titelController.text.trim().isNotEmpty;
    if (_type == 'image') {
      return _titelController.text.trim().isNotEmpty && _imageFile != null;
    }
    return false;
  }

  @override
  void dispose() {
    _titelController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Reads pixel dimensions of the picked image to determine orientation.
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
      });
    }
  }

  Future<void> _uploadInformation() async {
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
    return SafeArea(
      child: AlertDialog(
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        'Information hinzufügen',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ── Type selector ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _typeCard('text', Icons.text_fields, 'Text')),
                        SizedBox(width: 10.w),
                        Expanded(child: _typeCard('image', Icons.image, 'Bild / Flyer')),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // ── Text form ──────────────────────────────────────────
                    if (_type == 'text') ...[
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: TextField(
                          controller: _titelController,
                          cursorColor: BColors.primary,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Titel *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: BColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: TextField(
                          controller: _textController,
                          cursorColor: BColors.primary,
                          minLines: 2,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Text',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: BColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ── Image form ─────────────────────────────────────────
                    if (_type == 'image') ...[
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: TextField(
                          controller: _titelController,
                          cursorColor: BColors.primary,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Titel *',
                            helperText:
                                'Nur für die Verwaltung – wird Nutzern nicht angezeigt',
                            helperMaxLines: 2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  BorderSide(color: BColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Bild auswählen'),
                        ),
                      ),
                      if (_selectedImageName != null)
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 8.h, left: 8.w, right: 8.w),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 16.sp),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  '$_selectedImageName · $_imageOrientation',
                                  style: TextStyle(fontSize: 12.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: (_isUploading || !_canUpload) ? null : _uploadInformation,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: _isUploading
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Hochladen'),
          ),
        ],
      ),
    );
  }

  Widget _typeCard(String value, IconData icon, String label) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: selected
              ? BColors.primary.withOpacity(0.12)
              : Colors.transparent,
          border: Border.all(
            color: selected ? BColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: selected ? BColors.primary : Colors.grey.shade500,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? BColors.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

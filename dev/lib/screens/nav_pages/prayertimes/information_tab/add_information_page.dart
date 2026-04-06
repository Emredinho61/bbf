import 'dart:io';

import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/*
If admin chooses to add a new Information, then he will be redirected to this page.
This page allows the admin to a new Information card containing title, the actual information 
and if needed, an extended Text for more details 
*/

class AddInformationPage extends StatefulWidget {
  const AddInformationPage({super.key});

  @override
  State<AddInformationPage> createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {
  InformationService informationService = InformationService();
  final TextEditingController idController = TextEditingController();
  final TextEditingController titelController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final TextEditingController expandedController = TextEditingController();
  String? _selectedImageName;
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadInformation() async {
    final storage = FirebaseStorage.instance;
    setState(() => _isUploading = true);
    try {
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
          'information_images/$_selectedImageName',
        );
        await imageRef.putFile(fileToUpload);
        imageUrl = await imageRef.getDownloadURL();
      }
      await informationService.addInformation(
        idController.text,
        titelController.text,
        textController.text,
        imageUrl,
      );
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
    return SafeArea(
      child: AlertDialog(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Title(),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: idController,
                      cursorColor: BColors.primary,
                      decoration: InputDecoration(
                        labelText: 'Id',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: BColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TitleTextField(titelController: titelController),
                  MainTextField(textController: textController),
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
                ],
              ),
            ),
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
            onPressed: () async {
              setState(() {
                _isUploading = true;
              });
              await FirebaseFirestore.instance.collection("broadcasts").add({
              "title": 'Eine neue Nachricht ist verfügbar!',
              "summary": 'Test',
              "timestamp": FieldValue.serverTimestamp(),
            });
              _uploadInformation();
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
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Information hinzufügen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class ActionsRow extends StatelessWidget {
  const ActionsRow({
    super.key,
    required this.informationService,
    required this.idController,
    required this.titelController,
    required this.textController,
    this.imageFile,
    this.selectedImageName,
  });

  final InformationService informationService;
  final TextEditingController idController;
  final TextEditingController titelController;
  final TextEditingController textController;
  final File? imageFile;
  final String? selectedImageName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GoBackIcon(),
        AddInformationButton(
          informationService: informationService,
          idController: idController,
          titelController: titelController,
          textController: textController,
          imageFile: imageFile,
          selectedImageName: selectedImageName,
        ),
      ],
    );
  }
}

class AddInformationButton extends StatefulWidget {
  const AddInformationButton({
    super.key,
    required this.informationService,
    required this.idController,
    required this.titelController,
    required this.textController,
    this.imageFile,
    this.selectedImageName,
  });

  final InformationService informationService;
  final TextEditingController idController;
  final TextEditingController titelController;
  final TextEditingController textController;
  final File? imageFile;
  final String? selectedImageName;

  @override
  State<AddInformationButton> createState() => _AddInformationButtonState();
}

class _AddInformationButtonState extends State<AddInformationButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Hinzufügen'),
      ),
    );
  }
}

class GoBackIcon extends StatelessWidget {
  const GoBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back_ios),
    );
  }
}

class ExpandedTextField extends StatelessWidget {
  const ExpandedTextField({super.key, required this.expandedController});

  final TextEditingController expandedController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: expandedController,
        cursorColor: BColors.primary,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: 'Erweiterten Text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class MainTextField extends StatelessWidget {
  const MainTextField({super.key, required this.textController});

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        cursorColor: BColors.primary,
        minLines: 2,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: 'Text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({super.key, required this.titelController});

  final TextEditingController titelController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: titelController,
        cursorColor: BColors.primary,
        decoration: InputDecoration(
          labelText: 'Titel',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: BColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

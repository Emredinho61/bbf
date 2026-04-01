import 'dart:io';

import 'package:bbf_app/backend/services/information_service.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/*
If admin chooses to add a new Information, then he will be redirected to this page.
This page allows the admin to a new Information card containing title, the actual information 
and if needed, an extended Text for more details 
*/

class DeleteInformationPage extends StatefulWidget {
  const DeleteInformationPage({super.key});

  @override
  State<DeleteInformationPage> createState() => _DeleteInformationPageState();
}

class _DeleteInformationPageState extends State<DeleteInformationPage> {
  InformationService informationService = InformationService();
  final TextEditingController idController = TextEditingController();
  bool _isUploading = false;

  Future<void> _deleteInformation() async {
    try {
      await informationService.deleteInformation(idController.text);
      final idExists = await informationService.checkIfIdIsCorrect(
        idController.text,
      );
      if (mounted && idExists) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information erfolgreich gelöscht!')),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Id nicht gefunden!')),
        );
      }
    } catch (e) {
      debugPrint('Löschvorgang fehlgeschlagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Löschen: $e')));
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
            onPressed: () {
              setState(() {
                _isUploading = true;
              });
              _deleteInformation();
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
                : const Text("Löschen"),
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
        'Information löschen',
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

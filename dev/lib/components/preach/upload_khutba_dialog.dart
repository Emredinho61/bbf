import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadKhutbaDialog extends StatefulWidget {
  const UploadKhutbaDialog({super.key});

  @override
  State<UploadKhutbaDialog> createState() => _UploadKhutbaDialogState();
}

class _UploadKhutbaDialogState extends State<UploadKhutbaDialog> {
  String? _selectedFileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });

      // final file = File(result.files.single.path!);
      // await FirebaseStorage.instance.ref('khutbas/${result.files.single.name}')
      //   .putFile(file);
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
          child: const Text("Speichern"),
        ),
      ],
    );
  }
}

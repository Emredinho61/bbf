import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageMinorProjectDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? projectDoc; // Null means "Add Mode", otherwise "Edit Mode"

  const ManageMinorProjectDialog({super.key, this.projectDoc});

  @override
  State<ManageMinorProjectDialog> createState() => _ManageMinorProjectDialogState();
}

class _ManageMinorProjectDialogState extends State<ManageMinorProjectDialog> {
  bool _isUploading = false;
  bool _showError = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

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

  Future<void> _saveProject() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());

    if (title.isEmpty || description.isEmpty || amount == null || target == null) return;

    setState(() => _isUploading = true);

    try {
      final progress = target > 0 ? (amount / target).clamp(0.0, 1.0) : 0.0;

      final projectData = {
        'title': title,
        'description': description,
        'amount': amount,
        'target': target,
        'progress': progress,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final collection = FirebaseFirestore.instance.collection('minor_projects');

      if (_isEditMode) {
        await collection.doc(widget.projectDoc!.id).update(projectData);
      } else {
        await collection.add(projectData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditMode ? 'Projekt aktualisiert!' : 'Projekt hinzugefügt!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onSave() {
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());
    
    final invalid = _titleController.text.trim().isEmpty || 
                    _descController.text.trim().isEmpty || 
                    amount == null || target == null || target <= 0;
    
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
    if (target != null && target <= 0) {
      return 'Das Ziel muss größer als 0 sein.';
    }
    return 'Bitte trage gültige Zahlen ein.';
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
                icon: _isEditMode ? Icons.edit_note_outlined : Icons.add_circle_outline,
                title: _isEditMode ? 'Projekt bearbeiten' : 'Neues Projekt erstellen',
                isDark: isDark,
              ),
              SizedBox(height: 20.h),
              BTextField(label: 'Titel', controller: _titleController, obscureText: false, obligatory: true),
              SizedBox(height: 12.h),
              BTextField(label: 'Beschreibung', controller: _descController, obscureText: false, obligatory: true),
              SizedBox(height: 12.h),
              BTextField(label: 'Aktueller Stand (€)', controller: _amountController, obscureText: false, obligatory: true),
              SizedBox(height: 12.h),
              BTextField(label: 'Ziel (€)', controller: _targetController, obscureText: false, obligatory: true),
              
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
}
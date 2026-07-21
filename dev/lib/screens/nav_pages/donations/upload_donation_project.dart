import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditHauptprojektDialog extends StatefulWidget {
  const EditHauptprojektDialog({super.key});

  @override
  State<EditHauptprojektDialog> createState() => _EditHauptprojektDialogState();
}

class _EditHauptprojektDialogState extends State<EditHauptprojektDialog> {
  bool _isUploading = false;
  bool _showError = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  Future<void> _loadCurrentValues() async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc('hauptprojekt')
        .get();
    if (!mounted) return;
    final data = doc.data();
    if (data == null) return;
    final amount = data['amount'];
    final target = data['target'];
    if (amount != null) _amountController.text = amount.toStringAsFixed(0);
    if (target != null) _targetController.text = target.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _updateProject() async {
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());

    if (amount == null || target == null) return;

    setState(() => _isUploading = true);

    try {
      // Calculate progress percentage ratio between 0.0 and 1.0
      final progress = target > 0 ? (amount / target).clamp(0.0, 1.0) : 0.0;

      // Update the main project document in Firestore
      await FirebaseFirestore.instance
          .collection('projects')
          .doc('hauptprojekt')
          .set({
            'amount': amount,
            'target': target,
            'progress': progress,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hauptprojekt erfolgreich aktualisiert!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _onSave() {
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());

    final invalid = amount == null || target == null || target <= 0;

    setState(() => _showError = invalid);
    if (invalid || _isUploading) return;

    _updateProject();
  }

  String get _errorMessage {
    final amount = double.tryParse(_amountController.text.trim());
    final target = double.tryParse(_targetController.text.trim());

    if (_amountController.text.trim().isEmpty ||
        _targetController.text.trim().isEmpty) {
      return 'Bitte alle Pflichtfelder ausfüllen.';
    }
    if (amount == null || target == null) {
      return 'Bitte gültige Zahlen eingeben.';
    }
    if (target <= 0) {
      // Prevent division by zero errors
      return 'Das Ziel muss größer als 0 sein.';
    }
    return '';
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
                icon: Icons.edit_note_outlined,
                title: 'Hauptprojekt anpassen',
                isDark: isDark,
              ),
              SizedBox(height: 24.h),

              BTextField(
                label: 'Aktueller Spendenstand (€)',
                controller: _amountController,
                obscureText: false,
                obligatory: true,
              ),
              SizedBox(height: 16.h),

              BTextField(
                label: 'Zielbetrag (€)',
                controller: _targetController,
                obscureText: false,
                obligatory: true,
              ),

              AppErrorBanner(message: _errorMessage, visible: _showError),

              SizedBox(height: 24.h),
              AppDialogButtonRow(
                isDark: isDark,
                isLoading: _isUploading,
                onConfirm: _onSave,
                confirmLabel: 'Speichern',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

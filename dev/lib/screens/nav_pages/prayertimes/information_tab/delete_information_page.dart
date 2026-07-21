import 'package:bbf_app/backend/services/information_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteInformationPage extends StatefulWidget {
  const DeleteInformationPage({super.key});

  @override
  State<DeleteInformationPage> createState() => _DeleteInformationPageState();
}

class _DeleteInformationPageState extends State<DeleteInformationPage> {
  final InformationService _informationService = InformationService();

  List<Map<String, dynamic>> _allInformation = [];
  String? _selectedId;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    final data = await _informationService.getAllInformation();
    if (mounted) {
      setState(() {
        _allInformation = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInformation() async {
    if (_selectedId == null) return;
    setState(() => _isDeleting = true);
    try {
      await _informationService.deleteInformation(_selectedId!);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information erfolgreich gelöscht!')),
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
      if (mounted) setState(() => _isDeleting = false);
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
                        'Information löschen',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const CircularProgressIndicator(),
                      )
                    else if (_allInformation.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: const Text('Keine Informationen vorhanden.'),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Information auswählen',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          value: _selectedId,
                          isExpanded: true,
                          items: _allInformation.map((info) {
                            final id = info['id'] as String? ?? '';
                            final title = info['Titel'] as String? ?? id;
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedId = value),
                        ),
                      ),
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
            onPressed: (_selectedId == null || _isDeleting)
                ? null
                : _deleteInformation,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: _isDeleting
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

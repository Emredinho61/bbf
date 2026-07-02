import 'package:bbf_app/backend/services/information_service.dart';
import 'package:flutter/material.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Information löschen',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (_allInformation.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Keine Informationen vorhanden.'),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Information auswählen',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: (_selectedId == null || _isDeleting)
                ? null
                : _deleteInformation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
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

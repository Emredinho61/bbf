// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/icon_circle.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DeleteEventPage extends StatefulWidget {
  const DeleteEventPage({super.key});

  @override
  State<DeleteEventPage> createState() => _DeleteEventPageState();
}

class _DeleteEventPageState extends State<DeleteEventPage> {
  List<String> _eventTitles = [];
  String? _selectedTitle;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    final titles = await calendarService.getAllEventTitles();
    setState(() {
      _eventTitles = titles;
      _isLoading = false;
    });
  }

  void _showTitlePicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? BColors.backgroundColorDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                IconCircle(icon: Icons.event_outlined, iconSize: 20),
                const SizedBox(width: 12),
                Text(
                  'Event auswählen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _eventTitles.isEmpty
                ? Center(
                    child: Text(
                      'Keine Events gefunden.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    itemCount: _eventTitles.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 16,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                    itemBuilder: (_, i) {
                      final title = _eventTitles[i];
                      final isSelected = title == _selectedTitle;
                      return ListTile(
                        title: Text(
                          title,
                          style: TextStyle(
                            color: isSelected
                                ? BColors.primary
                                : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: BColors.primary, size: 20)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedTitle = title;
                            _showError = false;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    if (_selectedTitle == null) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isDeleting = true);
    await calendarService.deleteEventsWithId(_selectedTitle!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Event löschen'),
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? BColors.prayerRowDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconCircle(icon: Icons.delete_forever_outlined, iconSize: 22),
                            const SizedBox(width: 12),
                            Text(
                              'Alle Termine löschen',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Alle Termine dieses Events werden unwiderruflich gelöscht.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 20),

                        PickerTile(
                          label: 'Event',
                          hint: 'Event auswählen',
                          icon: Icons.event_outlined,
                          selected: _selectedTitle,
                          onTap: () => _showTitlePicker(isDark),
                          isDark: isDark,
                        ),

                        AppErrorBanner(
                          message: 'Bitte ein Event auswählen.',
                          visible: _showError,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isDeleting ? null : _delete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                : const Text(
                                    'Alle Termine löschen',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

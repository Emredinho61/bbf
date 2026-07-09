// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/icon_circle.dart';
import 'package:bbf_app/components/picker_tile.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteSingleEvent extends StatefulWidget {
  const DeleteSingleEvent({super.key});

  @override
  State<DeleteSingleEvent> createState() => _DeleteSingleEventState();
}

class _DeleteSingleEventState extends State<DeleteSingleEvent> {
  List<String> _eventTitles = [];
  String? _selectedTitle;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _showError = false;

  String? get _formattedDate => _selectedDate == null
      ? null
      : '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                IconCircle(icon: Icons.event_outlined, iconSize: 20),
                SizedBox(width: 12.w),
                Text(
                  'Event auswählen',
                  style: TextStyle(
                    fontSize: 16.sp,
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
                            ? Icon(Icons.check_circle, color: BColors.primary, size: 20.sp)
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
    if (_selectedTitle == null || _selectedDate == null) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isDeleting = true);
    await calendarService.addExceptionOrDeleteSingleEvent(
      _selectedTitle!,
      _selectedDate!.year.toString(),
      _selectedDate!.month.toString(),
      _selectedDate!.day.toString(),
    );
    if (mounted) Navigator.pop(context, true);
  }

  String get _errorMessage {
    if (_selectedTitle == null && _selectedDate == null) {
      return 'Bitte Event und Datum auswählen.';
    }
    if (_selectedTitle == null) return 'Bitte ein Event auswählen.';
    return 'Bitte ein Datum auswählen.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Einzelnen Termin löschen'),
        backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isDark ? BColors.prayerRowDark : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconCircle(icon: Icons.delete_outline, iconSize: 22),
                            SizedBox(width: 12.w),
                            Text(
                              'Einzelnen Termin löschen',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Nur der gewählte Tag wird gelöscht. Bei Wiederholungen wird eine Ausnahme gesetzt.',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                        ),
                        SizedBox(height: 20.h),

                        PickerTile(
                          label: 'Event',
                          hint: 'Event auswählen',
                          icon: Icons.event_outlined,
                          selected: _selectedTitle,
                          onTap: () => _showTitlePicker(isDark),
                          isDark: isDark,
                        ),
                        SizedBox(height: 10.h),

                        PickerTile(
                          label: 'Datum',
                          hint: 'Datum auswählen',
                          icon: Icons.calendar_today_outlined,
                          selectedIcon: Icons.event_available_outlined,
                          selected: _formattedDate,
                          onTap: () => EventPickers.pickDate(
                            context,
                            onConfirm: (date) => setState(() {
                              _selectedDate = date;
                              _showError = false;
                            }),
                          ),
                          isDark: isDark,
                        ),

                        AppErrorBanner(
                          message: _errorMessage,
                          visible: _showError,
                        ),

                        SizedBox(height: 24.h),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isDeleting ? null : _delete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
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
                                : const Text(
                                    'Termin löschen',
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

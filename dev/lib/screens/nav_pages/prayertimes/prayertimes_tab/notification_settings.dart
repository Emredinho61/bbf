// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/trigger_background_functions_service.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/notification_provider.dart';
import 'package:bbf_app/utils/helper/scheduler_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    required this.name,
    required this.prayerTime,
  });

  final String name;
  final DateTime? prayerTime;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final SchedulerHelper schedulerHelper = SchedulerHelper();
  List<Map<String, String>> csvData = [];

  late bool _isActive;
  int _selectedIndex = 0;

  static const List<String> _timeOptions = [
    'Keine',
    '5 Min',
    '10 Min',
    '15 Min',
    '20 Min',
    '30 Min',
    '45 Min',
  ];

  static const List<String> _storedValues = [
    'Keine',
    '5 Minuten',
    '10 Minuten',
    '15 Minuten',
    '20 Minuten',
    '30 Minuten',
    '45 Minuten',
  ];

  @override
  void initState() {
    super.initState();
    _isActive = schedulerHelper.getCurrentPrayerSettings('notify_${widget.name}');
    _selectedIndex = prayerTimesHelper.getCurrentPreTimeAsIndex('notifyPre_${widget.name}');
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    csvData = await prayerTimesHelper.loadCSV();
  }

  String get _displayName {
    switch (widget.name) {
      case 'Sunrise':
        return 'Shuruq';
      default:
        return widget.name;
    }
  }

  IconData get _prayerIcon {
    switch (widget.name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhur':
        return Icons.light_mode_outlined;
      case 'Asr':
        return Icons.sunny;
      case 'Maghrib':
        return Icons.wb_twilight_outlined;
      case 'Isha':
        return Icons.nightlight_round;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.access_time_outlined;
    }
  }

  String? get _formattedTime {
    if (widget.prayerTime == null) return null;
    final t = widget.prayerTime!;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';
  }

  void _setActive(bool value) {
    setState(() => _isActive = value);
    _persistActive(value);
  }

  Future<void> _persistActive(bool value) async {
    if (value) {
      await schedulerHelper.activatePrayerNotification('notify_${widget.name}');
    } else {
      await schedulerHelper.deactivatePrayerNotification('notify_${widget.name}');
    }
    if (mounted) await notificationServices.rescheduleSinglePrayer(widget.name, csvData);
  }

  void _selectPreTime(int index) {
    setState(() => _selectedIndex = index);
    _persistPreTime(index);
  }

  Future<void> _persistPreTime(int index) async {
    await schedulerHelper.setUsersPrePrayerSettings(
      'notifyPre_${widget.name}',
      _storedValues[index],
    );
    if (mounted) await notificationServices.rescheduleSinglePrayer(widget.name, csvData);
  }

  Future<void> _applyToAll(LoadingProvider provider) async {
    provider.startLoading();
    try {
      await schedulerHelper.setAllUsersPrayerSettings(_isActive);
      await schedulerHelper.setAllUsersPrePrayerSettings(_storedValues[_selectedIndex]);
      await notificationServices.rescheduleEverything(csvData);
      provider.stopLoadingWithCheckmark();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingProvider = context.read<LoadingProvider>();
    final isLoading = context.watch<LoadingProvider>().isLoading;
    final showCheckmark = context.watch<LoadingProvider>().showCheckmark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(isDark),
          const SizedBox(height: 20),

          _card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(Icons.notifications_outlined, 'Benachrichtigung', isDark),
                const SizedBox(height: 16),
                _toggleRow(isDark),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(Icons.timer_outlined, 'Vorankündigung', isDark),
                const SizedBox(height: 6),
                Text(
                  'Erinnere mich vor dem Gebet',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                _timeChips(isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isLoading || showCheckmark)
                  ? null
                  : () => _applyToAll(loadingProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: BColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    showCheckmark ? BColors.primary : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : showCheckmark
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Gespeichert',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.all_inclusive, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Für alle Gebete übernehmen',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(bool isDark) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: BColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_prayerIcon, color: BColors.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
            if (_formattedTime != null) ...[
              const SizedBox(height: 2),
              Text(
                'Heute: $_formattedTime',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _toggleRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _toggleOption(
            icon: Icons.notifications_off_outlined,
            label: 'Stumm',
            active: !_isActive,
            isDark: isDark,
            onTap: () => _setActive(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _toggleOption(
            icon: Icons.notifications_active_outlined,
            label: 'Aktiv',
            active: _isActive,
            isDark: isDark,
            onTap: () => _setActive(true),
          ),
        ),
      ],
    );
  }

  Widget _toggleOption({
    required IconData icon,
    required String label,
    required bool active,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? BColors.primary
              : (isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? BColors.primary : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: active ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_timeOptions.length, (i) {
        final selected = _selectedIndex == i;
        return GestureDetector(
          onTap: () => _selectPreTime(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? BColors.primary
                  : (isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? BColors.primary : Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Text(
              _timeOptions[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _label(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: BColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BColors.primary, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }
}

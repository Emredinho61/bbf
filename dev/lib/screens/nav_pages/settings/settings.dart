// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/events/upload_events_dialog.dart';
import 'package:bbf_app/components/prayertimes_upload.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/screens/monitor_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/bbf_info.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/settings_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /*--Initialize Services-------------------------------------------------------*/

  final SettingsService firestoreService = SettingsService();
  final AuthService authService = AuthService();
  final UserService userService = UserService();
  final PrayertimesService prayertimesService = PrayertimesService();
  final CheckUserHelper checkUserHelper = CheckUserHelper();
  final SettingsHelper settingsHelper = SettingsHelper();

  /*--Initialize Variables-------------------------------------------------------*/
  late bool isUserAdmin;

  /*--Initialize State-------------------------------------------------------*/
  @override
  void initState() {
    super.initState();
    isUserAdmin = checkUserHelper.getUsersPrefs();
    checkUser();
  }

  void checkUser() async {
    if (authService.currentUser == null) return;
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      if (value != isUserAdmin) {
        checkUserHelper.setCheckUsersPrefs(value);
        isUserAdmin = value;
      }
    });
  }

  /*--Dialog helpers-------------------------------------------------------*/

  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDialogForFridaysPrayer() async {
    final String currentFridayPrayer1 = await prayertimesService.getFridayPrayer1();
    final String currentFridayPrayer2 = await prayertimesService.getFridayPrayer2();

    TimeOfDay? fridayPrayer1Time = _parseTimeOfDay(currentFridayPrayer1);
    TimeOfDay? fridayPrayer2Time = _parseTimeOfDay(currentFridayPrayer2);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Freitagsgebetszeiten ändern'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BTextButton(
                    onPressed: () => EventPickers.pickTime(
                      dialogContext,
                      initialTime: fridayPrayer1Time,
                      onConfirm: (time) => setDialogState(() => fridayPrayer1Time = time),
                    ),
                    text: fridayPrayer1Time == null
                        ? '1. Freitagsgebet auswählen'
                        : '1. Freitagsgebet: ${_formatTimeOfDay(fridayPrayer1Time)} Uhr',
                  ),
                  const SizedBox(height: 5),
                  BTextButton(
                    onPressed: () => EventPickers.pickTime(
                      dialogContext,
                      initialTime: fridayPrayer2Time,
                      onConfirm: (time) => setDialogState(() => fridayPrayer2Time = time),
                    ),
                    text: fridayPrayer2Time == null
                        ? '2. Freitagsgebet auswählen'
                        : '2. Freitagsgebet: ${_formatTimeOfDay(fridayPrayer2Time)} Uhr',
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Zurück'),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await prayertimesService.updateFridayPrayerTimes(
                          _formatTimeOfDay(fridayPrayer1Time),
                          _formatTimeOfDay(fridayPrayer2Time),
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: const Text('Ändern'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDialogForIqamaTimes() async {
    final String fajr = await prayertimesService.getFajrIqama();
    final String dhur = await prayertimesService.getDhurIqama();
    final String asr = await prayertimesService.getAsrIqama();
    final String maghrib = await prayertimesService.getMaghribIqama();
    final String isha = await prayertimesService.getIshaIqama();

    int fajrIqama = int.tryParse(fajr) ?? 10;
    int dhurIqama = int.tryParse(dhur) ?? 10;
    int asrIqama = int.tryParse(asr) ?? 10;
    int maghribIqama = int.tryParse(maghrib) ?? 10;
    int ishaIqama = int.tryParse(isha) ?? 10;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Iqama Zeiten ändern'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iqamaPickerRow('Fajr', fajrIqama, (v) => setDialogState(() => fajrIqama = v)),
                    _iqamaPickerRow('Dhur', dhurIqama, (v) => setDialogState(() => dhurIqama = v)),
                    _iqamaPickerRow('Asr', asrIqama, (v) => setDialogState(() => asrIqama = v)),
                    _iqamaPickerRow('Maghrib', maghribIqama, (v) => setDialogState(() => maghribIqama = v)),
                    _iqamaPickerRow('Isha', ishaIqama, (v) => setDialogState(() => ishaIqama = v)),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Zurück'),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await prayertimesService.updateIqamaTimes(
                          fajrIqama.toString(), dhurIqama.toString(),
                          asrIqama.toString(), maghribIqama.toString(), ishaIqama.toString(),
                        );
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: const Text('Ändern'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _iqamaPickerRow(String prayerName, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$prayerName Iqama (Minuten)'),
          NumberPicker(value: value, minValue: 0, maxValue: 60, itemWidth: 60, itemHeight: 32, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showBroadcastDialog() {
    showDialog(
      context: context,
      builder: (ctx) => const _BroadcastDialog(),
    );
  }

  /*--Build-------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF2F2F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Monitor-Modus link (nur Admin)
            if (isUserAdmin && authService.currentUser != null)
              _monitorLink(context),

            // Admin-Sektion
            if (isUserAdmin && authService.currentUser != null) ...[
              _sectionHeader('Admin', isDark),
              _buildCard(isDark: isDark, children: [
                _settingsTile(icon: Icons.access_time_outlined, title: 'Freitagsgebetszeiten', isDark: isDark, isLast: false, onTap: _showDialogForFridaysPrayer),
                _settingsTile(icon: Icons.timer_outlined, title: 'Iqama Zeiten', isDark: isDark, isLast: false, onTap: _showDialogForIqamaTimes),
                _settingsTile(icon: Icons.upload_file_outlined, title: 'Projekt hochladen', isDark: isDark, isLast: false, onTap: () => showDialog(context: context, builder: (_) => const UploadProjectDialog())),
                _settingsTile(icon: Icons.cloud_upload_outlined, title: 'Gebetszeiten hochladen', isDark: isDark, isLast: false, onTap: () => showDialog(context: context, builder: (_) => const UploadPrayerTimesDialog())),
                _settingsTile(icon: Icons.campaign_outlined, title: 'Nachricht broadcasten', isDark: isDark, isLast: true, onTap: _showBroadcastDialog),
              ]),
            ],

            // Spenden
            _sectionHeader('Spenden', isDark),
            _buildCard(isDark: isDark, children: [
              _paypalRow(context, isDark),
              _bankCard(context, isDark),
            ]),

            // App
            _sectionHeader('App', isDark),
            _buildCard(isDark: isDark, children: [
              _toggleTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                title: 'Dunkelmodus',
                subtitle: 'App im dunklen Design anzeigen',
                isDark: isDark,
                isLast: false,
                value: isDark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  firestoreService.updateTheme(value ? 'dark' : 'light');
                },
              ),
              IshaSettingsTile(settingsHelper: settingsHelper, isDark: isDark),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'App-Version',
                isDark: isDark,
                isLast: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
                  ],
                ),
              ),
            ]),

            // Rechtliches
            _sectionHeader('Rechtliches', isDark),
            _buildCard(isDark: isDark, children: [
              _settingsTile(icon: Icons.description_outlined, title: 'Rechtliches', isDark: isDark, isLast: false, onTap: () => _showInfoDialog(context, 'Rechtliches', 'Alle rechtlichen Hinweise...')),
              _settingsTile(icon: Icons.description_outlined, title: 'AGB', isDark: isDark, isLast: false, onTap: () => _showInfoDialog(context, 'AGB', 'Unsere allgemeinen Geschäftsbedingungen...')),
              _settingsTile(icon: Icons.description_outlined, title: 'Datenschutz', isDark: isDark, isLast: false, onTap: () => _showInfoDialog(context, 'Datenschutz', 'Informationen zum Datenschutz...')),
              _settingsTile(icon: Icons.description_outlined, title: 'Über Uns', isDark: isDark, isLast: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
            ]),

            // Benutzer
            _sectionHeader('Benutzer', isDark),
            _buildCard(isDark: isDark, children: [
              if (!authService.currentUser!.isAnonymous)
                _settingsTile(
                  icon: Icons.logout,
                  title: 'Ausloggen',
                  isDark: isDark,
                  isLast: true,
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) Navigator.pushNamed(context, '/authpage');
                  },
                ),
              if (authService.currentUser!.isAnonymous)
                _settingsTile(
                  icon: Icons.person_outline,
                  title: 'Account erstellen / einloggen',
                  isDark: isDark,
                  isLast: true,
                  onTap: () => Navigator.pushNamed(context, '/authpage', arguments: {'showGuestLogin': true}),
                ),
            ]),

            const SizedBox(height: 16),

            if (!authService.currentUser!.isAnonymous)
              DeleteAccountButton(authService: authService),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /*--UI Helpers-------------------------------------------------------*/

  Widget _monitorLink(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MonitorPage())),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Zum Monitor-Modus wechseln',
            style: TextStyle(
              color: BColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: BColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDark,
    required bool isLast,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: BColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ],
                  ),
                ),
                trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    required bool isLast,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: BColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged, activeColor: BColors.primary),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }

  Widget _paypalRow(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse('https://www.paypal.com/donate/?hosted_button_id=ESTNXJLMMQQQS#');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Konnte PayPal URL nicht öffnen');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset('assets/images/PayPalLogo.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Über eine Spende würden wir uns freuen!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jetzt mit PayPal spenden',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _bankCard(BuildContext context, bool isDark) {
    return Column(
      children: [
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? BColors.backgroundColorDark : const Color(0xFFF8FFF8),
              border: Border.all(color: BColors.primary.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance, color: BColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bildungs- und Begegnungsverein\nFreiburg e.V.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _copyRow(context, Icons.receipt_outlined, 'IBAN', 'DE11 6805 0101 0014 3501 24', isDark),
                const SizedBox(height: 8),
                _copyRow(context, Icons.swap_horiz, 'BIC', 'FRSPDE66XXX', isDark),
                const SizedBox(height: 8),
                _copyRow(context, Icons.credit_card_outlined, 'Verwendungszweck', 'Spende', isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _copyRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label kopiert!'), duration: const Duration(seconds: 2)),
            );
          },
          child: Icon(Icons.copy_outlined, size: 18, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}

// ── Delete Account Button ─────────────────────────────────────────────────────

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showDeleteDialog(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: BColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Konto löschen',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final UserService userService = UserService();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konto löschen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Passwort', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              Navigator.pop(ctx);
              try {
                await userService.deleteUserFromBackend();
                await authService.deleteAccount(email: email, password: password);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/authpage', (_) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Löschen: $e')),
                  );
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Löschen'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Isha Settings Tile ────────────────────────────────────────────────────────

class IshaSettingsTile extends StatefulWidget {
  const IshaSettingsTile({super.key, required this.settingsHelper, required this.isDark});

  final SettingsHelper settingsHelper;
  final bool isDark;

  @override
  State<IshaSettingsTile> createState() => _IshaSettingsTileState();
}

// ── Broadcast Dialog ──────────────────────────────────────────────────────────

class _BroadcastDialog extends StatefulWidget {
  const _BroadcastDialog();

  @override
  State<_BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<_BroadcastDialog> {
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isSending = false;
  bool _showError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty || _summaryController.text.trim().isEmpty) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isSending = true);
    try {
      await FirebaseFirestore.instance.collection('broadcasts').add({
        'title': _titleController.text.trim(),
        'summary': _summaryController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Senden: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _inputField(TextEditingController controller, String label, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) { if (_showError) setState(() => _showError = false); },
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: BColors.primary.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDialogHeader(
              icon: Icons.campaign_outlined,
              title: 'Nachricht broadcasten',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            _inputField(_titleController, 'Titel', isDark),
            const SizedBox(height: 10),
            _inputField(_summaryController, 'Nachricht', isDark, maxLines: 4),

            AppErrorBanner(
              message: 'Bitte Titel und Nachricht ausfüllen.',
              visible: _showError,
            ),

            const SizedBox(height: 24),
            AppDialogButtonRow(
              isDark: isDark,
              isLoading: _isSending,
              onConfirm: _send,
              confirmLabel: 'Senden',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Isha Settings Tile ────────────────────────────────────────────────────────

class _IshaSettingsTileState extends State<IshaSettingsTile> {
  @override
  Widget build(BuildContext context) {
    final value = widget.settingsHelper.getIshaSettings();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.access_time_filled, color: BColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+ 90 Minuten zu Isha',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gebetszeit um 90 Minuten verzögern',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: (v) async {
                  await widget.settingsHelper.setIshaSetting(v);
                  setState(() {});
                },
                activeColor: BColors.primary,
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 66,
          color: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.15),
        ),
      ],
    );
  }
}

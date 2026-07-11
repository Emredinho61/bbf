// ignore_for_file: deprecated_member_use

import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/components/app_dialog.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/events/upload_events_dialog.dart';
import 'package:bbf_app/components/prayertimes_upload.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/screens/monitor_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/admin_feedback_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/bbf_info.dart';
import 'package:bbf_app/screens/nav_pages/settings/contact_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/bildung_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/feedback_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/social_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/settings_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  int _versionTapCount = 0;
  bool _adminUnlocked = false;

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
                  SizedBox(height: 5.h),
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
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
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
          padding: EdgeInsets.symmetric(vertical: 8.h),
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
                _settingsTile(icon: Icons.campaign_outlined, title: 'Nachricht broadcasten', isDark: isDark, isLast: false, onTap: _showBroadcastDialog),
                _settingsTile(
                  icon: Icons.inbox_outlined,
                  title: 'Nutzer-Feedback',
                  subtitle: 'Eingaben der Nutzer einsehen',
                  isDark: isDark,
                  isLast: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFeedbackPage())),
                ),
              ]),
            ],

            // Spenden
            _sectionHeader('Spenden', isDark),
            _buildCard(isDark: isDark, children: [
              _paypalRow(context, isDark),
              _bankCard(context, isDark),
            ]),

            // Kontakt & Soziales
            _sectionHeader('Verein', isDark),
            _buildCard(isDark: isDark, children: [
              _settingsTile(
                icon: Icons.school_outlined,
                title: 'Bildungsbereich',
                subtitle: 'Arabische Schule & Unterrichtsangebote',
                isDark: isDark,
                isLast: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BildungPage()),
                ),
              ),
              _settingsTile(
                icon: Icons.volunteer_activism_outlined,
                title: 'Soziale Arbeit',
                subtitle: 'Beratungsangebote des BBF-Vereins',
                isDark: isDark,
                isLast: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SocialPage()),
                ),
              ),
              _settingsTile(
                icon: Icons.contact_support_outlined,
                title: 'Kontakt & Häufige Fragen',
                subtitle: 'Erreichbarkeit und FAQ',
                isDark: isDark,
                isLast: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactPage()),
                ),
              ),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'Über Uns',
                isDark: isDark,
                isLast: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ]),

            // Mitmachen
            _sectionHeader('Mitmachen', isDark),
            _buildCard(isDark: isDark, children: [
              _settingsTile(
                icon: Icons.handshake_outlined,
                title: 'Mitmachen & Feedback',
                subtitle: 'Hilf uns, den Verein und die App zu verbessern',
                isDark: isDark,
                isLast: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage())),
              ),
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
                trailing: Text('1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp)),
                onTap: () {
                  final newCount = _versionTapCount + 1;
                  setState(() => _versionTapCount = newCount);
                  if (newCount == 5) {
                    setState(() => _adminUnlocked = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Admin-Modus entsperrt'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ]),

            // Socials
            _sectionHeader('Folge Uns', isDark),
            _buildCard(isDark: isDark, children: [
              _socialTile(
                platform: 'Facebook',
                handle: 'bbfverein',
                url: 'https://www.facebook.com/bbfverein',
                icon: _facebookIcon(),
                isDark: isDark,
                isLast: false,
              ),
              _socialTile(
                platform: 'Instagram · Brüder',
                handle: '@bbf_brueder',
                url: 'https://www.instagram.com/bbf_brueder',
                icon: _instagramIcon(),
                isDark: isDark,
                isLast: false,
              ),
              _socialTile(
                platform: 'Instagram · Mädchen',
                handle: '@bbf_maedchen',
                url: 'https://www.instagram.com/bbf_maedchen',
                icon: _instagramIcon(),
                isDark: isDark,
                isLast: true,
              ),
            ]),

            // Rechtliches
            _sectionHeader('Rechtliches', isDark),
            _buildCard(isDark: isDark, children: [
              _settingsTile(icon: Icons.description_outlined, title: 'Rechtliches', isDark: isDark, isLast: false, onTap: () => _showInfoDialog(context, 'Rechtliches', 'Alle rechtlichen Hinweise...')),
              _settingsTile(icon: Icons.description_outlined, title: 'AGB', isDark: isDark, isLast: false, onTap: () => _showInfoDialog(context, 'AGB', 'Unsere allgemeinen Geschäftsbedingungen...')),
              _settingsTile(icon: Icons.description_outlined, title: 'Datenschutz', isDark: isDark, isLast: true, onTap: () => _showInfoDialog(context, 'Datenschutz', 'Informationen zum Datenschutz...')),
            ]),

            // Benutzer (nur sichtbar wenn Admin-Modus entsperrt oder eingeloggt)
            if (_adminUnlocked || authService.currentUser != null) ...[
              _sectionHeader('Benutzer', isDark),
              _buildCard(isDark: isDark, children: [
                if (authService.currentUser == null && _adminUnlocked)
                  _settingsTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Als Admin registrieren',
                    isDark: isDark,
                    isLast: true,
                    onTap: () => Navigator.pushNamed(context, '/authpage'),
                  ),
                if (authService.currentUser != null)
                  _settingsTile(
                    icon: Icons.logout,
                    title: 'Ausloggen',
                    isDark: isDark,
                    isLast: true,
                    onTap: () async {
                      await authService.signOut();
                      if (mounted) {
                        setState(() {
                          isUserAdmin = false;
                          _adminUnlocked = false;
                          _versionTapCount = 0;
                        });
                      }
                    },
                  ),
              ]),
            ],

            SizedBox(height: 32.h),
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
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Text(
            'Zum Monitor-Modus wechseln',
            style: TextStyle(
              color: BColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
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
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 6.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard({required bool isDark, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? BColors.prayerRowDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: BColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: BColors.primary, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(subtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
                      ],
                    ],
                  ),
                ),
                trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22.sp),
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: BColors.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(subtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500)),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF5FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Image.asset('assets/images/PayPalLogo.png', fit: BoxFit.contain),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Über eine Spende würden wir uns freuen!',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Jetzt mit PayPal spenden',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22.sp),
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
          padding: EdgeInsets.all(12.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark ? BColors.backgroundColorDark : const Color(0xFFF8FFF8),
              border: Border.all(color: BColors.primary.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: BColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance, color: BColors.primary, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Bildungs- und Begegnungsverein\nFreiburg e.V.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _copyRow(context, Icons.receipt_outlined, 'IBAN', 'DE11 6805 0101 0014 3501 24', isDark),
                SizedBox(height: 8.h),
                _copyRow(context, Icons.swap_horiz, 'BIC', 'FRSPDE66XXX', isDark),
                SizedBox(height: 8.h),
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
        Icon(icon, size: 16.sp, color: Colors.grey.shade500),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
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
          child: Icon(Icons.copy_outlined, size: 18.sp, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _socialTile({
    required String platform,
    required String handle,
    required String url,
    required Widget icon,
    required bool isDark,
    required bool isLast,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              debugPrint('Konnte $url nicht öffnen');
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                icon,
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        handle,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 18.sp),
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

  Widget _instagramIcon() {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
    );
  }

  Widget _facebookIcon() {
    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.facebook, color: Colors.white, size: 22.sp),
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
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
        filled: true,
        fillColor: isDark ? BColors.backgroundColorDark : const Color(0xFFF7F7F7),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.25), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: BColors.primary.withOpacity(0.6), width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: isDark ? BColors.prayerRowDark : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDialogHeader(
              icon: Icons.campaign_outlined,
              title: 'Nachricht broadcasten',
              isDark: isDark,
            ),
            SizedBox(height: 24.h),

            _inputField(_titleController, 'Titel', isDark),
            SizedBox(height: 10.h),
            _inputField(_summaryController, 'Nachricht', isDark, maxLines: 4),

            AppErrorBanner(
              message: 'Bitte Titel und Nachricht ausfüllen.',
              visible: _showError,
            ),

            SizedBox(height: 24.h),
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: BColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.access_time_filled, color: BColors.primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+ 90 Minuten zu Isha',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Gebetszeit um 90 Minuten verzögern',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
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


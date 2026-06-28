import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/events/event_pickers.dart';
import 'package:bbf_app/components/events/upload_events_dialog.dart';
import 'package:bbf_app/components/prayertimes_upload.dart';
// import 'package:bbf_app/components/preach/upload_khutba_dialog.dart';
import 'package:bbf_app/components/text_button.dart';
import 'package:bbf_app/screens/monitor_page.dart';
import 'package:bbf_app/screens/nav_pages/settings/bbf_info.dart';
import 'package:bbf_app/screens/nav_pages/settings/location_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:bbf_app/utils/helper/check_user_helper.dart';
import 'package:bbf_app/utils/helper/settings_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:bbf_app/components/auth_dialog.dart';
import "package:bbf_app/components/donations/donation_tile.dart";

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
  late bool isUserAdmin; // used for displaying widgets only for admin

  /*--Initialize State-------------------------------------------------------*/
  @override
  void initState() {
    super.initState();
    isUserAdmin = checkUserHelper.getUsersPrefs();
    checkUser();
  }

  // check if user is admin
  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      if (value != isUserAdmin) {
        checkUserHelper.setCheckUsersPrefs(value);
        isUserAdmin = value;
      }
    });
  }

  /*--Admins UI for modifing Iqama & Friday Prayertimes-------------------------------------------------------*/

  // Converts a "HH:mm" string from the backend into a TimeOfDay.
  // Returns null if the value is empty or not in the expected format.
  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Converts a TimeOfDay back into the "HH:mm" string format used in the backend.
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Admin can change Friday prayertimes here
  void _showDialogForFridaysPrayer() async {
    final String currentFridayPrayer1 = await prayertimesService
        .getFridayPrayer1();
    final String currentFridayPrayer2 = await prayertimesService
        .getFridayPrayer2();

    TimeOfDay? fridayPrayer1Time = _parseTimeOfDay(currentFridayPrayer1);
    TimeOfDay? fridayPrayer2Time = _parseTimeOfDay(currentFridayPrayer2);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Freitagsgebetszeiten ändern'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BTextButton(
                    onPressed: () => EventPickers.pickTime(
                      dialogContext,
                      initialTime: fridayPrayer1Time,
                      onConfirm: (time) =>
                          setDialogState(() => fridayPrayer1Time = time),
                    ),
                    text: fridayPrayer1Time == null
                        ? '1. Freitagsgebet auswählen'
                        : '1. Freitagsgebet: ${_formatTimeOfDay(fridayPrayer1Time)} Uhr',
                  ),
                  SizedBox(height: 5),
                  BTextButton(
                    onPressed: () => EventPickers.pickTime(
                      dialogContext,
                      initialTime: fridayPrayer2Time,
                      onConfirm: (time) =>
                          setDialogState(() => fridayPrayer2Time = time),
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
                      child: Text('Zurück'),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await prayertimesService.updateFridayPrayerTimes(
                          _formatTimeOfDay(fridayPrayer1Time),
                          _formatTimeOfDay(fridayPrayer2Time),
                        );
                        Navigator.pop(dialogContext);
                      },
                      child: Text('Ändern'),
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

  // Admin can change Iqama times here. Iqama values are stored as the
  // number of minutes after the prayer time, e.g. "10".
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
              title: Text('Iqama Zeiten ändern'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iqamaNumberPickerRow(
                      'Fajr',
                      fajrIqama,
                      (value) => setDialogState(() => fajrIqama = value),
                    ),
                    _iqamaNumberPickerRow(
                      'Dhur',
                      dhurIqama,
                      (value) => setDialogState(() => dhurIqama = value),
                    ),
                    _iqamaNumberPickerRow(
                      'Asr',
                      asrIqama,
                      (value) => setDialogState(() => asrIqama = value),
                    ),
                    _iqamaNumberPickerRow(
                      'Maghrib',
                      maghribIqama,
                      (value) => setDialogState(() => maghribIqama = value),
                    ),
                    _iqamaNumberPickerRow(
                      'Isha',
                      ishaIqama,
                      (value) => setDialogState(() => ishaIqama = value),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text('Zurück'),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await prayertimesService.updateIqamaTimes(
                          fajrIqama.toString(),
                          dhurIqama.toString(),
                          asrIqama.toString(),
                          maghribIqama.toString(),
                          ishaIqama.toString(),
                        );
                        Navigator.pop(dialogContext);
                      },
                      child: Text('Ändern'),
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

  Widget _iqamaNumberPickerRow(
    String prayerName,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$prayerName Iqama (Minuten)'),
          NumberPicker(
            value: value,
            minValue: 0,
            maxValue: 60,
            itemWidth: 60,
            itemHeight: 32,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Send Broadcast"),
        content: _broadcastTextFields(titleController, summaryController),
        actions: [
          _actionsRowForSendingBroadcast(
            ctx,
            titleController,
            summaryController,
          ),
        ],
      ),
    );
  }

  Row _actionsRowForSendingBroadcast(
    BuildContext ctx,
    TextEditingController titleController,
    TextEditingController summaryController,
  ) {
    return Row(
      children: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        ElevatedButton(
          child: Text("Send"),
          onPressed: () async {
            // Save message in Firestore
            await FirebaseFirestore.instance.collection("broadcasts").add({
              "title": titleController.text,
              "summary": summaryController.text,
              "timestamp": FieldValue.serverTimestamp(),
            });
            Navigator.of(ctx).pop();
          },
        ),
      ],
    );
  }

  Column _broadcastTextFields(
    TextEditingController titleController,
    TextEditingController summaryController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: "Title"),
        ),
        TextField(
          controller: summaryController,
          decoration: InputDecoration(labelText: "Summary"),
        ),
      ],
    );
  }

  /*--Settings UI-------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    // themeProvider is used to change theme of App, if user wants so
    final themeProvider = Provider.of<ThemeProvider>(context);

    // bool to check if current theme is dark theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.green.shade900, Colors.grey.shade700]
                : [Colors.grey.shade300, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // /*--Admin Section-------------------------------------------------------*/

              // Switch to Monitor mode
              if (isUserAdmin && authService.currentUser != null)
                BTextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MonitorPage()),
                    );
                  },
                  text: 'Zum Monitor-Modus wechseln',
                ),
              if (isUserAdmin && authService.currentUser != null)
                _buildSectionHeader("Admin"),
              // display settings for admins
              if (isUserAdmin && authService.currentUser != null)
                _modifyFridayPrayerTimes(),
              if (isUserAdmin && authService.currentUser != null)
                _modifyIqamaTimes(),
              // if (isUserAdmin) _uploadKhutba(context),
              if (isUserAdmin) _uploadEvent(context),
              if (isUserAdmin) _uploadPrayertimesCSV(context),
              if (isUserAdmin) _broadcastMessage(),

              /*--Donation Section-------------------------------------------------------*/
              _buildSectionHeader("Spenden"),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Über eine Spende würden wir uns freuen !',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  IconButtonForPayPal(isDark: isDark),

                  SizedBox(height: 10),

                  DividerWithText(isDark: isDark),

                  SizedBox(height: 10),

                  BankInfoCard(isDark: isDark),
                ],
              ),

              const Divider(),

              /*--App Info Section-------------------------------------------------------*/
              _buildSectionHeader("App"),

              // Switch Light/Dark Mode
              LightDarkModeSwitch(
                isDark: isDark,
                themeProvider: themeProvider,
                firestoreService: firestoreService,
              ),

              IshaSettings(settingsHelper: settingsHelper),
              // App version
              _appVersionText(context),
              const Divider(),

              // General information
              _buildSectionHeader("Rechtliches"),
              _buildLinkTile(
                context,
                "Rechtliches",
                "Alle rechtlichen Hinweise...",
              ),
              _buildLinkTile(
                context,
                "AGB",
                "Unsere allgemeinen Geschäftsbedingungen...",
              ),
              _buildLinkTile(
                context,
                "Datenschutz",
                "Informationen zum Datenschutz...",
              ),
              _buildLinkTile(
                context,
                "Über Uns",
                "Mission, Vorstand, Kontakt, Spendenlinks...",
                isAboutPage: true,
              ),
              // TODO: Comment out if its working
              // _buildLinkTile(
              //   context,
              //   "Standort der Moschee",
              //   "Adresse der BBF",
              //   isLocationPage: true,
              // ),
              const Divider(),

              // User Settings
              _buildSectionHeader("Benutzer"),

              // Log out if user is logged in
              if (!authService.currentUser!.isAnonymous) _logOut(context),

              // registration or login for guest user
              if (authService.currentUser!.isAnonymous)
                _registerOrLogin(context),

              // Delete Button if User is logged in
              if (!authService.currentUser!.isAnonymous)
                DeleteAccountButton(authService: authService),
            ],
          ),
        ),
      ),
    );
  }

  // ListTile _uploadKhutba(BuildContext context) {
  //   return ListTile(
  //     leading: const Icon(Icons.upload_file),
  //     title: const Text("Khutba hochladen"),
  //     subtitle: const Text("PDF auswählen und speichern"),
  //     onTap: () {
  //       showDialog(
  //         context: context,
  //         builder: (context) => const UploadKhutbaDialog(),
  //       );
  //     },
  //   );
  // }

  ListTile _uploadEvent(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.upload_file),
      title: const Text("Event hochladen"),
      subtitle: const Text("Markdown auswählen und speichern"),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const UploadProjectDialog(),
        );
      },
    );
  }

  ListTile _uploadPrayertimesCSV(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.upload_file),
      title: const Text("Gebetszeiten hochladen"),
      subtitle: const Text(
        "Als CSV Datei. Name der Datei im folgenden Format: prayer_times_year",
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const UploadPrayerTimesDialog(),
        );
      },
    );
  }

  ListTile _modifyIqamaTimes() {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text("Iqama Zeiten einstellen"),
      onTap: () async {
        _showDialogForIqamaTimes();
      },
    );
  }

  ListTile _modifyFridayPrayerTimes() {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text("Freitagsgebetszeiten einstellen"),
      onTap: () async {
        _showDialogForFridaysPrayer();
      },
    );
  }

  ListTile _registerOrLogin(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text("Account erstellen / einloggen"),
      onTap: () async {
        Navigator.pushNamed(
          context,
          '/authpage',
          arguments: {'showGuestLogin': true},
        );
      },
    );
  }

  ListTile _logOut(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text("Ausloggen"),
      onTap: () async {
        await authService.signOut();
        Navigator.pushNamed(context, '/authpage');
      },
    );
  }

  ListTile _broadcastMessage() {
    return ListTile(
      leading: const Icon(Icons.message),
      title: const Text("Nachricht broadcasten"),
      onTap: () async {
        _showBroadcastDialog();
      },
    );
  }

  ListTile _appVersionText(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text("App-Version"),
      trailing: Text("1.0.0", style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    String title,
    String content, {
    bool isAboutPage = false,
    bool isLocationPage = false,
  }) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (isAboutPage) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutPage()),
          );
        }
        if (isLocationPage) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MosqueLocationPage()),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Schließen"),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AuthDialogButton(
        buttonText: "Konto löschen",
        fieldLabels: ["E-Mail", "Passwort"],
        passwordFieldIndex: 1,
        confirmButtonColor: Colors.red,
        confirmButtonText: "Löschen",
        onSubmit: (values, context) async {
          final email = values["E-Mail"] ?? "";
          final password = values["Passwort"] ?? "";

          try {
            await userService.deleteUserFromBackend();
            await authService.deleteAccount(email: email, password: password);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/authpage',
              (_) => false,
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Fehler beim Löschen: $e")));
          }
        },
      ),
    );
  }
}

class LightDarkModeSwitch extends StatelessWidget {
  const LightDarkModeSwitch({
    super.key,
    required this.isDark,
    required this.themeProvider,
    required this.firestoreService,
  });

  final bool isDark;
  final ThemeProvider themeProvider;
  final SettingsService firestoreService;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Dunkelmodus"),
      value: isDark,
      // TODO: check if this exists
      activeThumbColor: BColors.primary,
      onChanged: (value) {
        themeProvider.toggleTheme();
        firestoreService.updateTheme(value ? "dark" : "light");
      },
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
    );
  }
}

class IshaSettings extends StatefulWidget {
  const IshaSettings({super.key, required this.settingsHelper});

  final SettingsHelper settingsHelper;

  @override
  State<IshaSettings> createState() => _IshaSettingsState();
}

class _IshaSettingsState extends State<IshaSettings> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text(" + 90 Minuten zu Isha"),
      value: widget.settingsHelper.getIshaSettings(),
      // activeThumbColor: BColors.primary,
      onChanged: (value) async {
        await widget.settingsHelper.setIshaSetting(value);
        setState(() {});
      },
    );
  }
}

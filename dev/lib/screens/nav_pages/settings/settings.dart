import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/uno_to_flask_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/screens/nav_pages/settings/bbf_info.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:bbf_app/components/auth_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService firestoreService = SettingsService();

  final AuthService authService = AuthService();

  final UserService userService = UserService();

  final PrayertimesService prayertimesService = PrayertimesService();

  bool isUserAdmin = false;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      isUserAdmin = value;
    });
  }

  void _showDialogForFridaysPrayer() {
    TextEditingController fridayPrayer1Controller = TextEditingController();
    TextEditingController fridayPrayer2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Iqama & Jumua\'a Zeiten ändern'),
            content: Column(
              children: [
                BTextField(
                  label: '1. Freitagsgebet',
                  icon: Icons.access_time,
                  controller: fridayPrayer1Controller,
                  obscureText: false,
                  obligatory: false,
                ),
                SizedBox(height: 5),
                BTextField(
                  label: '2. Freitagsgebet',
                  icon: Icons.access_time,
                  controller: fridayPrayer2Controller,
                  obscureText: false,
                  obligatory: false,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Zurück'),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      final fridayPrayer1 = fridayPrayer1Controller.text.trim();
                      final fridayPrayer2 = fridayPrayer2Controller.text.trim();
                      await prayertimesService.updateFridayPrayerTimes(
                        fridayPrayer1,
                        fridayPrayer2,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Ändern'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogForIqamaTimes() {
    TextEditingController fajrIqamaController = TextEditingController();
    TextEditingController dhurIqamaController = TextEditingController();
    TextEditingController asrIqamaController = TextEditingController();
    TextEditingController maghribIqamaController = TextEditingController();
    TextEditingController ishaIqamaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Iqama & Jumua\'a Zeiten ändern'),
            content: Column(
              children: [
                BTextField(
                  label: 'Fajr Iqama',
                  icon: Icons.access_time,
                  controller: fajrIqamaController,
                  obscureText: false,
                  obligatory: false,
                ),
                SizedBox(height: 5),
                BTextField(
                  label: 'Dhur Iqama',
                  icon: Icons.access_time,
                  controller: dhurIqamaController,
                  obscureText: false,
                  obligatory: false,
                ),
                SizedBox(height: 5),
                BTextField(
                  label: 'Asr Iqama',
                  icon: Icons.access_time,
                  controller: asrIqamaController,
                  obscureText: false,
                  obligatory: false,
                ),
                SizedBox(height: 5),
                BTextField(
                  label: 'Maghrib Iqama',
                  icon: Icons.access_time,
                  controller: maghribIqamaController,
                  obscureText: false,
                  obligatory: false,
                ),
                SizedBox(height: 5),
                BTextField(
                  label: 'Isha Iqama',
                  icon: Icons.access_time,
                  controller: ishaIqamaController,
                  obscureText: false,
                  obligatory: false,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Zurück'),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      final fajrIqama = fajrIqamaController.text.trim();
                      final dhurIqama = dhurIqamaController.text.trim();
                      final asrIqama = asrIqamaController.text.trim();
                      final maghribIqama = maghribIqamaController.text.trim();
                      final ishaIqama = ishaIqamaController.text.trim();

                      await prayertimesService.updateIqamaTimes(
                        fajrIqama,
                        dhurIqama,
                        asrIqama,
                        maghribIqama,
                        ishaIqama,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Ändern'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
              _buildSectionHeader("Spenden"),
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text("PayPal"),
                subtitle: const Text("paypal.me/bbf"), // TODO: richtigen Payapal namen finden
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://paypal.com', // TODO: richtigen Paypal link finden
                  );
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    debugPrint('Konnte $url nicht öffnen');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text(
                  " Bildungs- und Begegnungsverein Freiburg e.V.",
                ),
                subtitle: const Text(
                  "IBAN: DE11 6805 0101 0014 3501 24\nBIC: FRSPDE66XXX\nVerwendungszweck: Spende",
                ),
              ),

              const Divider(),
              _buildSectionHeader("App"),
              SwitchListTile(
                title: const Text("Dunkelmodus"),
                value: isDark,
                activeColor: BColors.primary,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  firestoreService.updateTheme(value ? "dark" : "light");
                },
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("App-Version"),
                trailing: const Text(
                  "1.0.0",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const Divider(),

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

              const Divider(),

              _buildSectionHeader("Benutzer"),

              if (isUserAdmin && authService.currentUser != null)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text("Freitagsgebetszeiten einstellen"),
                  onTap: () async {
                    _showDialogForFridaysPrayer();
                  },
                ),
              if (isUserAdmin && authService.currentUser != null)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text("Iqama Zeiten einstellen"),
                  onTap: () async {
                    _showDialogForIqamaTimes();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Nachricht"),
                onTap: () async {
                  NotificationServices notificationServices =
                      NotificationServices();
                  await notificationServices.displayNotification();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("ping"),
                onTap: () async {
                  UnoToFlaskService unoToFlaskService = UnoToFlaskService();
                  await unoToFlaskService.fetchAlbum();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Ausloggen"),
                onTap: () async {
                  await authService.signOut();
                  Navigator.pushNamed(context, '/authpage');
                },
              ),

              Padding(
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
                      await authService.deleteAccount(
                        email: email,
                        password: password,
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/authpage',
                        (_) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Fehler beim Löschen: $e")),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

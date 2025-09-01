import 'package:bbf_app/backend/services/notification_services.dart';
import 'package:bbf_app/backend/services/prayertimes_service.dart';
import 'package:bbf_app/backend/services/uno_to_flask_service.dart';
import 'package:bbf_app/backend/services/user_service.dart';
import 'package:bbf_app/components/text_field.dart';
import 'package:bbf_app/screens/nav_pages/settings/bbf_info.dart';
import 'package:bbf_app/screens/nav_pages/settings/location_page.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Initialize Services

  final SettingsService firestoreService = SettingsService();

  final AuthService authService = AuthService();

  final UserService userService = UserService();

  final PrayertimesService prayertimesService = PrayertimesService();

  // only display certain Widgets if user is Admin
  bool isUserAdmin = false;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  // check if user is admin
  void checkUser() async {
    if (authService.currentUser == null) {
      return;
    }
    final value = await userService.checkIfUserIsAdmin();
    setState(() {
      isUserAdmin = value;
    });
  }

  // Widgets for admin

  // Admin can change Friday prayertimes here
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

  // Admin can change Iqama times here
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

  // UI for settings

  @override
  Widget build(BuildContext context) {
    // helper Widgets

    // themeProvider is used to change theme of App, if u user wants so
    final themeProvider = Provider.of<ThemeProvider>(context);

    // bool to check if current theme is dark theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Container which contains the whole UI in settings in order to set a gradient color for background
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
              // Donation Section
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

              // App Info Section
              _buildSectionHeader("App"),

              // Switch Light/Dark Mode
              LightDarkModeSwitch(
                isDark: isDark,
                themeProvider: themeProvider,
                firestoreService: firestoreService,
              ),

              // App version
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("App-Version"),
                trailing: Text(
                  "1.0.0",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

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
              _buildLinkTile(
                context,
                "Standort der Moschee",
                "Adresse der BBF",
                isLocationPage: true,
              ),
              const Divider(),

              // User Settings
              _buildSectionHeader("Benutzer"),

              // display settings for admins
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

              // Testing purposes TODO: Remove later
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

              // Log out if user is logged in
              if (authService.currentUser != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Ausloggen"),
                  onTap: () async {
                    await authService.signOut();
                    Navigator.pushNamed(context, '/authpage');
                  },
                ),

              // Delete Button if User is logged in
              if (authService.currentUser != null)
                DeleteAccountButton(authService: authService),
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
      activeColor: BColors.primary,
      onChanged: (value) {
        themeProvider.toggleTheme();
        firestoreService.updateTheme(value ? "dark" : "light");
      },
      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
    );
  }
}

class BankInfoCard extends StatelessWidget {
  const BankInfoCard({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Copyable text
    Widget copyableRow(String label, String value) {
      return Row(
        children: [
          Expanded(
            child: Text(
              "$label: $value",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("$label copied!")));
            },
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Colors.white : Colors.green),
      ),
      child: ListTile(
        leading: const Icon(Icons.account_balance),
        title: Center(
          child: Text(
            "Bildungs- und Begegnungsverein Freiburg e.V.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            copyableRow("IBAN", "DE11 6805 0101 0014 3501 24"),
            copyableRow("BIC", "FRSPDE66XXX"),
            copyableRow("Verwendungszweck", "Spende"),
          ],
        ),
      ),
    );
  }
}

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: Divider(
              color: isDark ? Colors.white : Colors.black,
              thickness: 1,
            ),
          ),
          SizedBox(width: 10),
          Text('oder'),
          SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: Divider(
              color: isDark ? Colors.white : Colors.black,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class IconButtonForPayPal extends StatelessWidget {
  const IconButtonForPayPal({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(
          'https://www.paypal.com/donate/?hosted_button_id=ESTNXJLMMQQQS#',
        );
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          debugPrint('Konnte $url nicht öffnen');
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: isDark ? Colors.green.shade300 : Colors.green.shade200,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/images/PayPalLogo.png'),
        ),
      ),
    );
  }
}

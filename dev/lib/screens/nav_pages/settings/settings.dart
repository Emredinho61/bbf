import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:bbf_app/components/auth_dialog.dart'; // <-- Our reusable dialog button

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final List<Item> _data = generateSettingsItems();
  final SettingsService firestoreService = SettingsService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
                final isCurrentlyDark =
                    Theme.of(context).brightness == Brightness.dark;
                final newMode = isCurrentlyDark ? 'light' : 'dark';
                firestoreService.updateTheme(newMode);
              },
              icon: Theme.of(context).brightness == Brightness.dark
                  ? Image.asset('assets/icons/sun.png', height: 30)
                  : Image.asset('assets/icons/moon.png', height: 30),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      materialGapSize: 0.0,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(title: Text(item.headerValue));
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(title: Text(item.expandedValue)),
              if (item.headerValue == 'Benutzerverwaltung') ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await authService.signOut();
                      Navigator.pushNamed(context, '/authpage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ausloggen'),
                  ),
                ),
                const SizedBox(height: 8),
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
                          SnackBar(content: Text('Fehler beim Löschen: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });
  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateSettingsItems() {
  return [
    Item(
      headerValue: 'Rechtliches',
      expandedValue: 'Alle rechtlichen Hinweise...',
    ),
    Item(
      headerValue: 'AGB',
      expandedValue: 'Unsere allgemeinen Geschäftsbedingungen...',
    ),
    Item(
      headerValue: 'Datenschutz',
      expandedValue: 'Informationen zum Datenschutz...',
    ),
    Item(
      headerValue: 'Über Uns',
      expandedValue: 'Mission, Vorstand, Kontakt, Spendenlinks, ...',
    ),
    Item(
      headerValue: 'Benutzerverwaltung',
      expandedValue: 'Hier kannst du deinen Benutzer verwalten...',
    ),
    Item(headerValue: 'App-Version', expandedValue: 'Version 1.0.0'),
  ];
}

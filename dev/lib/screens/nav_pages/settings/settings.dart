import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';

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
                  child: ElevatedButton(
                    onPressed: () => _showDeleteDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Konto löschen'),
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

  void _showDeleteDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konto löschen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bitte bestätige deine E-Mail und dein Passwort:'),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-Mail'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Passwort'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                try {
                  await authService.deleteAccount(
                    email: email,
                    password: password,
                  );
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/authpage',
                    (_) => false,
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Löschen: $e')),
                  );
                }
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
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

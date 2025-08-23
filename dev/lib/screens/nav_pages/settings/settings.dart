import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbf_app/backend/services/auth_services.dart';
import 'package:bbf_app/backend/services/settings_service.dart';
import 'package:bbf_app/utils/theme/theme_provider.dart';
import 'package:bbf_app/components/auth_dialog.dart';

class SettingsPage extends StatelessWidget {
  final SettingsService firestoreService = SettingsService();
  final AuthService authService = AuthService();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        children: [
          _buildSectionHeader("App"),
          SwitchListTile(
            title: const Text("Dunkelmodus"),
            value: isDark,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
          ),

          const Divider(),

          _buildSectionHeader("Benutzer"),
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

  Widget _buildLinkTile(BuildContext context, String title, String content) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
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
      },
    );
  }
}

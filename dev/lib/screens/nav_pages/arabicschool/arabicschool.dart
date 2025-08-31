import 'package:bbf_app/components/underlined_text.dart';
import 'package:bbf_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArabicSchool extends StatefulWidget {
  const ArabicSchool({super.key});
  @override
  State<ArabicSchool> createState() => _ArabicSchoolState();
}

class _ArabicSchoolState extends State<ArabicSchool> {
  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    'Bildungsbereich',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Divider(height: 50, thickness: 2, color: BColors.primary),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: BColors.primary),
                      ),
                      elevation: 4,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade600
                          : BColors.secondary,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            children: [
                              UnderlinedText(
                                content: Text(
                                  'Unsere Mission',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Eines unserer wichtigsten Ziele bei der Gründung unseres Vereins war die Errichtung einer Schule, die die heranwachsende Generation durch qualifizierte Fachkräfte dabei unterstützt, ihre Identität und Kultur aufzubewahren.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 14),
                              UnderlinedText(
                                content: Text(
                                  'Vorstellung der Schule',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Die arabische Schule wurde 2017 mit Unterstützung und unter der Aufsicht des Vereins gegründet und wird von ca. 200 Schülern aller Altersgruppen besucht.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 14),
                              UnderlinedText(
                                content: Text(
                                  'Stufen und Alter',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Die Schule umfasst drei Vorbereitungsstufen und sechs Grundstufen.Das Alter der Schüler liegt zwischen 5 und 14 Jahren. Kinder ab 5 Jahren dürfen an der Schule angemeldet werden. Neben dem Arabisch-Unterricht bietet die Schule einen Islam-Unterricht an. Die Anmeldung erfolgt Online. Über die Aufnahme benachrichtigt die Schulleitung die Eltern.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Hier kommen Sie zur '),
                                  GestureDetector(
                                    onTap: () async {
                                      final Uri url = Uri.parse(
                                        'https://docs.google.com/forms/d/1dtCVlQnG9q_QEZIJKn6hrmwdAKrfQCM1d_6KrSD-qJM/viewform?edit_requested=true',
                                      );
                                      if (!await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      )) {
                                        debugPrint('Konnte $url nicht öffnen');
                                      }
                                    },

                                    child: UnderlinedText(
                                      content: Text('Anmeldung'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

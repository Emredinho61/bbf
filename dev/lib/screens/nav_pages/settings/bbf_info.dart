import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Über Uns"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                "Der Anfang",
                "Der Bildungs- und Begegnungsverein Freiburg e.V. ist ein unabhängiger, gemeinnütziger Verein, der sich am Gemeinschaftsleben beteiligen möchte. "
                    "Er wurde 2016 von muslimischen Freiburgern gegründet, um eine aktive Rolle auf kultureller, religiöser und gesellschaftlicher Ebene zu spielen "
                    "und um die dringenden Bedürfnisse der muslimischen Gemeinschaft in Freiburg und Umgebung gerecht zu werden.",
              ),
              _buildSection(
                "Die Identität",
                "Der Verein vertritt eine gemäßigte Ansicht, die aus dem Buch Gottes, aus der Lebensgeschichte des Propheten, der „Sunna“ "
                    "und an Beispiel der rechtschaffenen Vorgänger hergeleitet ist.",
              ),
              _buildSection(
                "Die Vision",
                "Aufbau und Entwicklung der Gesellschaft, sowie die Entwicklung der muslimischen Gemeinschaft in allen Lebensbereichen "
                    "und ihren Mitgliedern ein soziales, kulturelles Umfeld zur Verfügung zu stellen.\n\n"
                    "Der Verein wirkt in Unabhängigkeit von politischen Ausrichtungen und Parteien. "
                    "Der Verein finanziert sich über die Mitgliederbeiträge und Spenden wohltätiger Personen.",
              ),
              _buildBulletSection("Unsere Ziele", [
                "Aktive Teilnahme an der Entwicklung der Gesellschaft in Freiburg und Umgebung.",
                "Förderung der kulturellen und religiösen Begegnungen mit den unterschiedlichen Institutionen der Gesellschaft.",
                "Sich gegenüber der nicht-muslimischen Gesellschaft zu öffnen und die kulturellen Werte des Islams aufzuzeigen.",
                "Planen und durchführen von karitativen und ehrenamtlichen Aktivitäten.",
                "Den Jugendlichen eine Orientierung geben, um Werte des Edels und Tugend zu vermitteln.",
                "Ausbau der institutionellen Arbeit und Förderung der Zusammenarbeit aller Muslime in unserer Stadt.",
                "Den Bedürfnissen der arabischen und muslimischen Gemeinschaft nachzukommen.",
                "Förderung der akademischen und beruflichen Entwicklung sowie Integration.",
              ]),
              _buildBulletSection("Unsere Grundsätze", [
                "Bewahrung der menschlichen, islamischen Werte und Moral.",
                "Umsetzung der toleranten islamischen Prinzipien.",
                "Zielerreichung durch fleißige Arbeit und Ehrgeiz.",
                "Engagement zum Erfolg mit höchster Qualität und Effizienz.",
                "Koordination, Zusammenarbeit, Einigkeit und Einsatz aller Kräfte.",
                "Arbeiten in einem wissenschaftlichen Rahmen für höchste Qualität.",
                "Gute Beziehungen mit allen gesellschaftlichen Partnern pflegen.",
                "Geordnete institutionelle Arbeit durch Planung und Disziplin.",
              ]),
              _buildSection(
                "Der aktuelle Vorstand",
                "Der aktuelle Vorstand wurde am 09.03.2023 für 4 Jahre gewählt und besteht aus:\n\n"
                    "• Abderrahim Jahdari: Vorsitzender\n"
                    "• Qais Alketib: Stellvertretender Vorsitzender\n"
                    "• Markus Hanser: Kassenwart\n"
                    "• Rauia Jahdar: Mitglied\n"
                    "• Hamouda Belakhal: Mitglied",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBulletSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15, height: 1.4),
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
}

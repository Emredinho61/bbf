import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateMonthlyPrayerPdf(
  List<Map<String, String>> csvData,
  String firstPrayer,
  String secondPrayer,
) async {
  final pdf = pw.Document();

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  final monthRows = csvData.where((row) {
    if (row['Date'] == null) return false;
    try {
      final parts = row['Date']!.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      return date.month == currentMonth && date.year == currentYear;
    } catch (_) {
      return false;
    }
  }).toList();

  pdf.addPage(
    pw.MultiPage(
      footer: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Text(
              'Erstes Freitagsgebet: $firstPrayer Uhr   |   Zweites Freitagsgebet: $secondPrayer Uhr',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Bildungs- und Begegnung Freiburg e.V. | Rufacherstr. 5, 79110 Freiburg',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              'Sparkasse Freiburg | IBAN: DE11 6805 0101 0014 3501 24 | BIC: FRSPDE66XXX',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Seite ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      },
      build: (context) => [
        pw.Center(
          child: pw.Text(
            "Gebetszeiten - ${_monthName(currentMonth)} $currentYear",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.TableHelper.fromTextArray(
            headers: ['Datum', 'Fajr', 'Sonnenaufgang', 'Dhur', 'Asr', 'Maghrib', 'Isha'],
            data: monthRows.map((row) {
              return [
                row['Date'] ?? '',
                row['Fajr'] ?? '',
                row['Sunrise'] ?? '',
                row['Dhur'] ?? '',
                row['Asr'] ?? '',
                row['Maghrib'] ?? '',
                row['Isha'] ?? '',
                
              ];
            }).toList(),
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green),
            cellAlignment: pw.Alignment.center,
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Gebetszeiten_${now.month}_${now.year}.pdf',
  );
}

String _monthName(int month) {
  const months = [
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember",
  ];
  return months[month - 1];
}

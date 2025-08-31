import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateMonthlyPrayerPdf(List<Map<String, String>> csvData) async {
  final pdf = pw.Document();

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  // actual month inshallah
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

  // table
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Center(
          child: pw.Text(
            "Gebetszeiten - ${now.month}.${now.year}",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Datum', 'Fajr', 'Dhur', 'Asr', 'Maghrib', 'Isha', 'Sonnenaufgang'],
          data: monthRows.map((row) {
            return [
              row['Date'] ?? '',
              row['Fajr'] ?? '',
              row['Dhur'] ?? '',
              row['Asr'] ?? '',
              row['Maghrib'] ?? '',
              row['Isha'] ?? '',
              row['Sunrise'] ?? '',
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
      ],
    ),
  );

  // save pdf 
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Gebetszeiten_${now.month}_${now.year}.pdf',
  );
}

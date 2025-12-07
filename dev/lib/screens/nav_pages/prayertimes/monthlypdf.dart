import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateMonthlyPrayerPdf(
  List<Map<String, String>> csvData,
  String firstPrayer,
  String secondPrayer,
  int month,
  int year,
) async {
  final pdf = pw.Document();

  final selectedMonth = month;
  final selectedYear = year;

  final monthRows = csvData.where((row) {
    if (row['Date'] == null) return false;
    try {
      final parts = row['Date']!.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);
      return date.month == selectedMonth && date.year == selectedYear;
    } catch (_) {
      return false;
    }
  }).toList();

  final rowsWithDate = monthRows.map((row) {
    final parts = row['Date']!.split('.');
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    return {
      'row': row,
      'date': date,
      'isFriday': date.weekday == DateTime.friday,
    };
  }).toList();

  pdf.addPage(
    pw.MultiPage(
      maxPages: 1, // forces everything on a single page
      margin: const pw.EdgeInsets.only(left: 50, right: 0, top: 30, bottom: 30),
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
            "Gebetszeiten - ${_monthName(selectedMonth)} $selectedYear",
            style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 35),

        pw.Table(
          border: pw.TableBorder.all(width: 0),
          columnWidths: {
            0: const pw.FixedColumnWidth(55),
            1: const pw.FixedColumnWidth(50),
            2: const pw.FixedColumnWidth(80),
            3: const pw.FixedColumnWidth(50),
            4: const pw.FixedColumnWidth(50),
            5: const pw.FixedColumnWidth(60),
            6: const pw.FixedColumnWidth(50),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green),
              children: [
                _headerCell("Datum"),
                _headerCell("Fajr"),
                _headerCell("Sonnenaufgang"),
                _headerCell("Dhur"),
                _headerCell("Asr"),
                _headerCell("Maghrib"),
                _headerCell("Isha"),
              ],
            ),

            ...rowsWithDate.map((entry) {
              final row = entry['row'] as Map<String, String>;
              final isFriday = entry['isFriday'] as bool;

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isFriday
                      ? PdfColors
                            .lightGreen // highlights the fridays
                      : PdfColors.white,
                ),
                children: [
                  _cell(row['Date']),
                  _cell(row['Fajr']),
                  _cell(row['Sunrise']),
                  _cell(row['Dhur']),
                  _cell(row['Asr']),
                  _cell(row['Maghrib']),
                  _cell(row['Isha']),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: "Gebetszeiten - ${_monthName(month)} $year",
  );
}

pw.Widget _headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _cell(String? text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(3),
    child: pw.Text(
      text ?? '',
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    ),
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

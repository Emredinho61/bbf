// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ── Palette ─────────────────────────────────────────────────────────────────
const _kTeal = PdfColor(0.05, 0.26, 0.20); // header + footer dark teal
const _kMonthBar = PdfColor(0.08, 0.20, 0.16); // month bar, slightly darker
const _kMonthBadge = PdfColor(0.04, 0.14, 0.11); // day-number badge
const _kAccentGreen = PdfColor(0.13, 0.55, 0.33); // logo circle accent
const _kFridayRow = PdfColor(0.82, 0.94, 0.84); // Friday highlight
const _kAltRow = PdfColor(0.96, 0.98, 0.96); // alternating row tint
const _kBorder = PdfColor(0.78, 0.78, 0.78); // table grid

Future<void> generateMonthlyPrayerPdf(
  List<Map<String, String>> csvData,
  String firstPrayer,
  String secondPrayer,
  int month,
  int year,
) async {
  // ── Fonts ────────────────────────────────────────────────────────────────
  final latin = await PdfGoogleFonts.notoSansRegular();
  final latinBold = await PdfGoogleFonts.notoSansBold();
  final arabic = await PdfGoogleFonts.notoNaskhArabicRegular();

  // ── Logo asset ───────────────────────────────────────────────────────────
  final logoData = await rootBundle.load('assets/images/bbf-logo.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  // ── Filter CSV to requested month ────────────────────────────────────────
  final entries = csvData
      .where((row) {
        if (row['Date'] == null) return false;
        try {
          final p = row['Date']!.split('.');
          final d = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
          return d.month == month && d.year == year;
        } catch (_) {
          return false;
        }
      })
      .map((row) {
        final p = row['Date']!.split('.');
        final date = DateTime(
          int.parse(p[2]),
          int.parse(p[1]),
          int.parse(p[0]),
        );
        return {
          'row': row,
          'date': date,
          'isFriday': date.weekday == DateTime.friday,
        };
      })
      .toList();

  // ── Build PDF ────────────────────────────────────────────────────────────
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(latin, latinBold, arabic, logoImage),
          _monthBar(month, year, latinBold, logoImage),
          pw.Expanded(child: _table(entries, latin, latinBold, arabic)),
          _footer(firstPrayer, secondPrayer, latin, latinBold),
        ],
      ),
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'Gebetszeiten - ${_monthName(month)} $year',
  );
}

// ── Header ──────────────────────────────────────────────────────────────────

pw.Widget _header(
  pw.Font latin,
  pw.Font latinBold,
  pw.Font arabic,
  pw.MemoryImage logo,
) {
  return pw.Container(
    color: _kTeal,
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Left block
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'مواقيت الصلاة لمدينة فرايبورغ',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabic,
                color: PdfColors.white,
                fontSize: 9,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Gebetszeiten für Freiburg',
              style: pw.TextStyle(
                font: latinBold,
                color: PdfColors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
        // Center logo
        pw.Image(logo, width: 46, height: 46),
        // Right block
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'جمعية الثقافة والتواصل فرايبورغ',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: arabic,
                color: PdfColors.white,
                fontSize: 9,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Bildung und Begegnung Freiburg',
              style: pw.TextStyle(
                font: latinBold,
                color: PdfColors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Month bar ────────────────────────────────────────────────────────────────

pw.Widget _monthBar(
  int month,
  int year,
  pw.Font latinBold,
  pw.MemoryImage logo,
) {
  return pw.Container(
    color: _kMonthBar,
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: pw.Row(
      children: [
        // Day badge
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _kMonthBadge,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Text(
            month.toString().padLeft(2, '0'),
            style: pw.TextStyle(
              font: latinBold,
              color: PdfColors.white,
              fontSize: 26,
            ),
          ),
        ),
        pw.SizedBox(width: 18),
        // Month + year
        pw.Expanded(
          child: pw.Text(
            '${_monthName(month)} $year',
            style: pw.TextStyle(
              font: latinBold,
              color: PdfColors.white,
              fontSize: 20,
            ),
          ),
        ),
        // Circular logo badge
        pw.Container(
          width: 46,
          height: 46,
          decoration: const pw.BoxDecoration(
            color: _kAccentGreen,
            shape: pw.BoxShape.circle,
          ),
          padding: const pw.EdgeInsets.all(4),
          child: pw.Center(child: pw.Image(logo, width: 36, height: 36)),
        ),
      ],
    ),
  );
}

// ── Table ────────────────────────────────────────────────────────────────────

pw.Widget _table(
  List<Map<String, dynamic>> entries,
  pw.Font latin,
  pw.Font latinBold,
  pw.Font arabic,
) {
  // Column definitions: (German label, Arabic label)
  const cols = [
    ('Datum', 'التاريخ'),
    ('Tag', 'اليوم'),
    ('Morgen', 'الفجر'),
    ('Sonnenaufgang', 'الشروق'),
    ('Mittag', 'الظهر'),
    ('Nachmittag', 'العصر'),
    ('Abend', 'المغرب'),
    ('Nacht', 'العشاء'),
  ];

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    child: pw.Table(
      border: pw.TableBorder.all(color: _kBorder, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.3), // Datum
        1: pw.FlexColumnWidth(1.5), // Tag
        2: pw.FlexColumnWidth(1.0), // Morgen
        3: pw.FlexColumnWidth(1.8), // Sonnenaufgang (longest label)
        4: pw.FlexColumnWidth(1.0), // Mittag
        5: pw.FlexColumnWidth(1.4), // Nachmittag
        6: pw.FlexColumnWidth(1.1), // Abend
        7: pw.FlexColumnWidth(1.0), // Nacht
      },
      children: [
        // Header row
        pw.TableRow(
          children: cols
              .map((c) => _headerCell(c.$1, c.$2, latinBold, arabic))
              .toList(),
        ),

        // Data rows
        ...entries.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value['row'] as Map<String, String>;
          final date = e.value['date'] as DateTime;
          final isFriday = e.value['isFriday'] as bool;

          final bg = isFriday
              ? _kFridayRow
              : (i.isOdd ? _kAltRow : PdfColors.white);

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _cell(row['Date'] ?? '', latin, bold: isFriday),
              _cell(_weekdayName(date.weekday), latin, bold: isFriday),
              _cell(row['Fajr'] ?? '', latin, bold: isFriday),
              _cell(row['Sunrise'] ?? '', latin, bold: isFriday),
              _cell(row['Dhur'] ?? '', latin, bold: isFriday),
              _cell(row['Asr'] ?? '', latin, bold: isFriday),
              _cell(row['Maghrib'] ?? '', latin, bold: isFriday),
              _cell(row['Isha'] ?? '', latin, bold: isFriday),
            ],
          );
        }),
      ],
    ),
  );
}

pw.Widget _headerCell(String de, String ar, pw.Font latinBold, pw.Font arabic) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 3),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          de,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: latinBold, fontSize: 8),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          ar,
          textAlign: pw.TextAlign.center,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: arabic,
            fontSize: 7,
            color: const PdfColor(0.3, 0.3, 0.3),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _cell(String text, pw.Font font, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        font: font,
        fontSize: 8.5,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

// ── Footer ───────────────────────────────────────────────────────────────────

pw.Widget _footer(
  String firstPrayer,
  String secondPrayer,
  pw.Font latin,
  pw.Font latinBold,
) {
  return pw.Container(
    color: _kTeal,
    padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Jumu'a info line
        pw.Text(
          'Erstes Freitagsgebet: $firstPrayer Uhr   |   Zweites Freitagsgebet: $secondPrayer Uhr',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: latin,
            color: PdfColors.white,
            fontSize: 7.5,
          ),
        ),
        pw.SizedBox(height: 6),
        // Address / bank row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _footerCol('Rufacherstr. 5', '79110 Freiburg', latin, latinBold),
            _footerCol('Spendenkonto', 'Sparkasse Freiburg', latin, latinBold),
            _footerCol('IBAN', 'DE11 6805 0101 0014 3501 24', latin, latinBold),
            _footerCol('BIC', 'FRSPDE66XXX', latin, latinBold),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _footerCol(
  String label,
  String value,
  pw.Font latin,
  pw.Font latinBold,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          font: latinBold,
          color: PdfColors.white,
          fontSize: 8,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          font: latin,
          color: const PdfColor(0.85, 0.85, 0.85),
          fontSize: 7.5,
        ),
      ),
    ],
  );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _weekdayName(int weekday) {
  const names = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  return names[weekday - 1];
}

String _monthName(int month) {
  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return months[month - 1];
}

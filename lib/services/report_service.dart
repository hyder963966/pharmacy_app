import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/drug.dart';
import 'formatters.dart';

class ReportService {
  Future<void> printInventoryReport(List<Drug> drugs) async {
    final pdf = pw.Document();
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Dubai-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Dubai-Bold.ttf'),
    );
    final logoBytes = (await rootBundle.load(
      'assets/images/saydaliti_logo.jpg',
    )).buffer.asUint8List();
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'تقرير مخزون صيدليتي',
                    style: pw.TextStyle(
                      font: bold,
                      color: PdfColor.fromHex('#0D6E6E'),
                      fontSize: 24,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${now.year}/${now.month}/${now.day}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.Container(
                width: 54,
                height: 54,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  image: pw.DecorationImage(image: pw.MemoryImage(logoBytes)),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('#D8E8E4')),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.3),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(2),
            },
            children: [
              _row(
                ['السعر', 'الكمية', 'الشكل', 'المجموعة', 'الدواء'],
                bold,
                isHeader: true,
              ),
              ...drugs.map(
                (drug) => _row(
                  [
                    formatMoney(drug.price),
                    formatQuantity(drug.quantity),
                    drug.dosageForm,
                    drug.therapeuticGroup,
                    drug.tradeName,
                  ],
                  regular,
                  isLow: drug.isLowStock,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'الأدوية ذات الكمية الحرجة مميزة بخلفية فاتحة.',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#B42318'),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'saydaliti-inventory-report.pdf',
      onLayout: (_) async => pdf.save(),
    );
  }

  pw.TableRow _row(
    List<String> cells,
    pw.Font font, {
    bool isHeader = false,
    bool isLow = false,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isHeader
            ? PdfColor.fromHex('#0D6E6E')
            : isLow
            ? PdfColor.fromHex('#FFF1F0')
            : PdfColors.white,
      ),
      children: cells.map((text) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: font,
              color: isHeader ? PdfColors.white : PdfColors.black,
              fontSize: isHeader ? 11 : 10,
            ),
          ),
        );
      }).toList(),
    );
  }
}

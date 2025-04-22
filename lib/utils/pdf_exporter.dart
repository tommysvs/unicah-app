import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFExporter {
  static Future<void> exportToPDF(
    List<Map<String, dynamic>> periods,
    String title,
    String careerName,
  ) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/LogoUNICAH2.png',
      )).buffer.asUint8List(),
    );

    final sortedPeriods = List<Map<String, dynamic>>.from(periods)..sort(
      (a, b) => _romanToInt(
        a['romanNumber'],
      ).compareTo(_romanToInt(b['romanNumber'])),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 50, height: 50),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      careerName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.normal,
                        color: PdfColors.blueGrey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
                pw.SizedBox(width: 50),
              ],
            ),
            pw.SizedBox(height: 16),

            ...sortedPeriods.map((period) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Periodo: ${period['romanNumber']}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        ...((period['classes'] as List<dynamic>).map((
                          classData,
                        ) {
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 8),
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      classData['className'],
                                      style: const pw.TextStyle(fontSize: 12),
                                    ),
                                    pw.Text(
                                      '(${classData['classCode']})',
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      classData['status'],
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        fontWeight: pw.FontWeight.bold,
                                        color:
                                            classData['status'] == 'Aprobada'
                                                ? PdfColors.green
                                                : (classData['status'] ==
                                                        'Reprobada'
                                                    ? PdfColors.red
                                                    : (classData['status'] ==
                                                            'Cursando'
                                                        ? PdfColors.orange
                                                        : PdfColors.grey)),
                                      ),
                                    ),
                                    if (classData['finalGrade'] != null)
                                      pw.Text(
                                        'Nota: ${classData['finalGrade']}',
                                        style: const pw.TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  pw.Divider(color: PdfColors.grey400),
                ],
              );
            }).toList(),

            pw.Spacer(),
            pw.Text(
              'Generado por la aplicación UNICAH',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static int _romanToInt(String roman) {
    final romanMap = {
      'I': 1,
      'II': 2,
      'III': 3,
      'IV': 4,
      'V': 5,
      'VI': 6,
      'VII': 7,
      'VIII': 8,
      'IX': 9,
      'X': 10,
      'XI': 11,
      'XII': 12,
      'XIII': 13,
      'XIV': 14,
      'XV': 15,
    };

    return romanMap[roman] ?? 0;
  }
}

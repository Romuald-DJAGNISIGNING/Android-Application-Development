import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/export_artifact.dart';
import '../../models/export_format.dart';
import '../../models/processing_report.dart';
import 'base_report_exporter.dart';

class PdfReportExporter extends BaseReportExporter {
  const PdfReportExporter();

  @override
  ExportFormat get format => ExportFormat.pdf;

  @override
  Future<ExportArtifact> export(
    ProcessingReport report,
    String destinationPath,
  ) async {
    final document = pw.Document();
    final generatedOn = DateFormat('MMM d, y - HH:mm').format(DateTime.now());
    final summary = report.summary;

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(18),
              gradient: const pw.LinearGradient(
                colors: [PdfColor.fromInt(0xFF18314F), PdfColor.fromInt(0xFF24706A)],
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Student Grade Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on $generatedOn',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _summaryCard('Rows', '${summary.totalRows}'),
              _summaryCard('Average', summary.average.toStringAsFixed(2)),
              _summaryCard('Median', summary.median.toStringAsFixed(2)),
              _summaryCard('Pass Rate', '${summary.passRate.toStringAsFixed(2)}%'),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text('Processed Rows', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: gradeHeaders,
            data: buildGradeRows(report),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF18314F)),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF7F1E8)),
            border: null,
          ),
          if (report.issues.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text('Issues', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: const ['Row', 'Severity', 'Code', 'Message'],
              data: buildIssueRecords(report)
                  .map(
                    (issue) => [
                      '${issue['rowIndex']}',
                      '${issue['severity']}'.toUpperCase(),
                      '${issue['code']}',
                      '${issue['message']}',
                    ],
                  )
                  .toList(growable: false),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFB8743C)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              border: null,
            ),
          ],
        ],
      ),
    );

    return writeBytes(await document.save(), destinationPath);
  }

  pw.Widget _summaryCard(String label, String value) => pw.Container(
    width: 120,
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(14),
      color: const PdfColor.fromInt(0xFFF7F1E8),
      border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5D8C8)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF6B7280))),
        pw.SizedBox(height: 5),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

import 'package:intl/intl.dart';

import '../../models/export_artifact.dart';
import '../../models/export_format.dart';
import '../../models/processing_report.dart';
import 'base_report_exporter.dart';

class WordReportExporter extends BaseReportExporter {
  const WordReportExporter();

  @override
  ExportFormat get format => ExportFormat.word;

  @override
  Future<ExportArtifact> export(
    ProcessingReport report,
    String destinationPath,
  ) {
    final generatedOn = DateFormat('MMM d, y - HH:mm').format(DateTime.now());
    final buffer = StringBuffer()
      ..writeln(r'{\rtf1\ansi\deff0')
      ..writeln(r'{\fonttbl{\f0 Calibri;}{\f1 Cambria;}}')
      ..writeln(r'\viewkind4\uc1\pard\sa180')
      ..writeln(r'\f1\fs34\b Student Grade Report\b0\par')
      ..writeln('\\f0\\fs20 Generated on $generatedOn\\par')
      ..writeln(r'\par')
      ..writeln(r'\b Summary\b0\par')
      ..writeln('Rows processed: ${report.summary.totalRows}\\par')
      ..writeln('Average score: ${report.summary.average.toStringAsFixed(2)}\\par')
      ..writeln('Median score: ${report.summary.median.toStringAsFixed(2)}\\par')
      ..writeln('Pass rate: ${report.summary.passRate.toStringAsFixed(2)}%\\par')
      ..writeln(r'\par')
      ..writeln(r'\b Processed Rows\b0\par');

    for (final row in buildGradeRows(report)) {
      buffer
        ..writeln(escapeRtf(row.take(5).join(' | ')) + r'\par')
        ..writeln(escapeRtf('Status: ${row[6]} | Source: ${row[7]}') + r'\par')
        ..writeln(escapeRtf('Reasons: ${row[8].isEmpty ? 'None' : row[8]}') + r'\par\par');
    }

    if (report.issues.isNotEmpty) {
      buffer.writeln(r'\b Issues\b0\par');
      for (final issue in buildIssueRecords(report)) {
        buffer.writeln(
          escapeRtf(
            'Row ${issue['rowIndex']} - ${issue['severity']}: ${issue['code']} -> ${issue['message']}',
          ) + r'\par',
        );
      }
    }

    buffer.writeln('}');
    return writeText(buffer.toString(), destinationPath);
  }
}

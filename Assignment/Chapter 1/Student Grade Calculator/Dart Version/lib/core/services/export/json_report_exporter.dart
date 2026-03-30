import 'dart:convert';

import '../../models/export_artifact.dart';
import '../../models/export_format.dart';
import '../../models/processing_report.dart';
import 'base_report_exporter.dart';

class JsonReportExporter extends BaseReportExporter {
  const JsonReportExporter();

  @override
  ExportFormat get format => ExportFormat.json;

  @override
  Future<ExportArtifact> export(
    ProcessingReport report,
    String destinationPath,
  ) {
    final payload = JsonEncoder.withIndent('  ').convert({
      'generatedAt': DateTime.now().toIso8601String(),
      'summary': buildSummaryRecord(report),
      'results': buildResultRecords(report),
      'issues': buildIssueRecords(report),
    });
    return writeText(payload, destinationPath);
  }
}

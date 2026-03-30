import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../contracts/report_exporter.dart';
import '../../models/export_artifact.dart';
import '../../models/export_target.dart';
import '../../models/grade_config.dart';
import '../../models/processing_report.dart';

abstract class BaseReportExporter implements ReportExporter {
  const BaseReportExporter();

  Future<ExportArtifact> writeBytes(
    List<int> bytes,
    String destinationPath,
  ) async {
    final file = File(destinationPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return ExportArtifact(
      path: destinationPath,
      sizeBytes: bytes.length,
      format: format,
      target: ExportTarget.local,
      exportedAt: DateTime.now(),
      locationLabel: p.dirname(destinationPath),
    );
  }

  Future<ExportArtifact> writeText(String text, String destinationPath) =>
      writeBytes(utf8.encode(text), destinationPath);

  List<String> get gradeHeaders => const [
    'Row',
    'Name',
    'Matricule',
    'Final Score',
    'Letter',
    'Pass',
    'Status',
    'Source',
    'Reasons',
  ];

  List<List<String>> buildGradeRows(ProcessingReport report) => report.results
      .map(
        (result) => [
          result.rowIndex.toString(),
          result.name ?? '',
          result.matricule ?? '',
          formatScore(result.finalScore),
          result.letter.label,
          result.pass ? 'YES' : 'NO',
          result.status.name.toUpperCase(),
          result.source,
          result.reasons.join(' | '),
        ],
      )
      .toList(growable: false);

  List<Map<String, Object?>> buildResultRecords(ProcessingReport report) => report
      .results
      .map(
        (result) => {
          'rowIndex': result.rowIndex,
          'name': result.name,
          'matricule': result.matricule,
          'finalScore': result.finalScore,
          'letter': result.letter.label,
          'pass': result.pass,
          'status': result.status.name,
          'source': result.source,
          'reasons': result.reasons,
        },
      )
      .toList(growable: false);

  Map<String, Object?> buildSummaryRecord(ProcessingReport report) => {
    'totalRows': report.summary.totalRows,
    'gradedRows': report.summary.gradedRows,
    'unknownRows': report.summary.unknownRows,
    'average': report.summary.average,
    'median': report.summary.median,
    'passRate': report.summary.passRate,
    'gradeCounts': {
      for (final entry in report.summary.gradeCounts.entries)
        entry.key.label: entry.value,
    },
  };

  List<Map<String, Object?>> buildIssueRecords(ProcessingReport report) => report
      .issues
      .map(
        (issue) => {
          'rowIndex': issue.rowIndex,
          'severity': issue.severity.name,
          'code': issue.code,
          'message': issue.message,
        },
      )
      .toList(growable: false);

  String formatScore(double? score) => score == null ? '' : score.toStringAsFixed(2);

  String escapeRtf(String value) => value
      .replaceAll('\\', r'\\')
      .replaceAll('{', r'\{')
      .replaceAll('}', r'\}')
      .replaceAll('\n', r'\line ');
}

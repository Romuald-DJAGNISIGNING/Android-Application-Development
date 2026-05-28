import '../../models/export_artifact.dart';
import '../../models/export_format.dart';
import '../../models/processing_report.dart';
import 'base_report_exporter.dart';

class CsvReportExporter extends BaseReportExporter {
  const CsvReportExporter();

  @override
  ExportFormat get format => ExportFormat.csv;

  @override
  Future<ExportArtifact> export(
    ProcessingReport report,
    String destinationPath,
  ) {
    final rows = [gradeHeaders, ...buildGradeRows(report)];
    final csv = rows.map(_encodeRow).join('\n');
    return writeText(csv, destinationPath);
  }

  String _encodeRow(List<String> row) => row
      .map((value) => '"${value.replaceAll('"', '""')}"')
      .join(',');
}

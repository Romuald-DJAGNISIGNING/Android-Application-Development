import '../models/export_artifact.dart';
import '../models/export_format.dart';
import '../models/processing_report.dart';

abstract interface class ReportExporter {
  ExportFormat get format;

  Future<ExportArtifact> export(
    ProcessingReport report,
    String destinationPath,
  );
}

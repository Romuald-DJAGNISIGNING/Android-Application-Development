import '../models/export_artifact.dart';

abstract interface class ReportShareService {
  Future<void> shareArtifacts(
    List<ExportArtifact> artifacts, {
    String? message,
  });
}

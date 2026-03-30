import '../models/export_artifact.dart';

abstract interface class CloudSyncService {
  Future<ExportArtifact> syncArtifact(
    ExportArtifact artifact,
    String destinationDirectory,
  );
}

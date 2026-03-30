import 'dart:io';

import 'package:path/path.dart' as p;

import '../../contracts/cloud_sync_service.dart';
import '../../models/export_artifact.dart';
import '../../models/export_target.dart';

class DesktopCloudSyncService implements CloudSyncService {
  const DesktopCloudSyncService();

  @override
  Future<ExportArtifact> syncArtifact(
    ExportArtifact artifact,
    String destinationDirectory,
  ) async {
    final directory = Directory(destinationDirectory);
    await directory.create(recursive: true);

    final targetPath = await _uniquePath(directory.path, artifact.fileName);
    final copied = await File(artifact.path).copy(targetPath);

    return ExportArtifact(
      path: copied.path,
      sizeBytes: await copied.length(),
      format: artifact.format,
      target: ExportTarget.cloud,
      exportedAt: DateTime.now(),
      locationLabel: directory.path,
    );
  }

  Future<String> _uniquePath(String directory, String fileName) async {
    final extension = p.extension(fileName);
    final stem = p.basenameWithoutExtension(fileName);
    var candidate = p.join(directory, fileName);
    var index = 1;

    while (await File(candidate).exists()) {
      candidate = p.join(directory, '$stem-$index$extension');
      index++;
    }

    return candidate;
  }
}

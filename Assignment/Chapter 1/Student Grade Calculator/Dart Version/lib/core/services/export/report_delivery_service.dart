import 'dart:io';

import 'package:path/path.dart' as p;

import '../../contracts/cloud_sync_service.dart';
import '../../contracts/report_share_service.dart';
import '../../models/export_artifact.dart';
import '../../models/export_format.dart';
import '../../models/processing_report.dart';
import 'report_exporter_factory.dart';

class ReportDeliveryService {
  const ReportDeliveryService({
    required this.exporterFactory,
    required this.cloudSyncService,
    required this.shareService,
  });

  final ReportExporterFactory exporterFactory;
  final CloudSyncService cloudSyncService;
  final ReportShareService shareService;

  Future<ExportArtifact> exportToPath({
    required ProcessingReport report,
    required ExportFormat format,
    required String destinationPath,
  }) {
    return exporterFactory.create(format).export(report, destinationPath);
  }

  Future<ExportArtifact> exportToCloudDirectory({
    required ProcessingReport report,
    required ExportFormat format,
    required String destinationDirectory,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp('gradecalc-export-');
    try {
      final tempPath = p.join(tempDir.path, format.suggestedFileName());
      final localArtifact = await exporterFactory
          .create(format)
          .export(report, tempPath);
      return cloudSyncService.syncArtifact(localArtifact, destinationDirectory);
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  Future<void> shareArtifact(ExportArtifact artifact) {
    return shareService.shareArtifacts(
      [artifact],
      message: 'Student grade report exported as ${artifact.format.label}.',
    );
  }
}

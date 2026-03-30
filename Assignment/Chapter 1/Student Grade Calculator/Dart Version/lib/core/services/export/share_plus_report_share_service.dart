import 'package:share_plus/share_plus.dart';

import '../../contracts/report_share_service.dart';
import '../../models/export_artifact.dart';
import '../../models/export_format.dart';

class SharePlusReportShareService implements ReportShareService {
  const SharePlusReportShareService();

  @override
  Future<void> shareArtifacts(
    List<ExportArtifact> artifacts, {
    String? message,
  }) {
    final files = artifacts
        .map((artifact) => XFile(artifact.path, mimeType: artifact.format.mimeType))
        .toList(growable: false);

    return SharePlus.instance.share(
      ShareParams(
        files: files,
        text: message ?? 'Student grade report ready to share.',
        title: 'Student Grade Calculator',
      ),
    );
  }
}

import 'export_format.dart';
import 'export_target.dart';

class ExportArtifact {
  const ExportArtifact({
    required this.path,
    required this.sizeBytes,
    required this.format,
    required this.target,
    required this.exportedAt,
    required this.locationLabel,
  });

  final String path;
  final int sizeBytes;
  final ExportFormat format;
  final ExportTarget target;
  final DateTime exportedAt;
  final String locationLabel;

  String get fileName => path.split(RegExp(r'[/\\]')).last;
}

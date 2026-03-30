enum ExportTarget {
  local,
  cloud,
}

extension ExportTargetX on ExportTarget {
  String get label => switch (this) {
    ExportTarget.local => 'Local Device',
    ExportTarget.cloud => 'Cloud Folder',
  };

  String get description => switch (this) {
    ExportTarget.local => 'Save the report directly on this computer.',
    ExportTarget.cloud =>
      'Copy the report into a synced folder such as OneDrive, Dropbox, or Google Drive Desktop.',
  };
}

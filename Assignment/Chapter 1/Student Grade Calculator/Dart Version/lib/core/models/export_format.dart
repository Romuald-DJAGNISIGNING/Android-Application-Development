enum ExportFormat {
  excel,
  csv,
  json,
  pdf,
  word,
}

extension ExportFormatX on ExportFormat {
  String get label => switch (this) {
    ExportFormat.excel => 'Excel',
    ExportFormat.csv => 'CSV',
    ExportFormat.json => 'JSON',
    ExportFormat.pdf => 'PDF',
    ExportFormat.word => 'Word (RTF)',
  };

  String get extension => switch (this) {
    ExportFormat.excel => 'xlsx',
    ExportFormat.csv => 'csv',
    ExportFormat.json => 'json',
    ExportFormat.pdf => 'pdf',
    ExportFormat.word => 'rtf',
  };

  String get mimeType => switch (this) {
    ExportFormat.excel =>
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ExportFormat.csv => 'text/csv',
    ExportFormat.json => 'application/json',
    ExportFormat.pdf => 'application/pdf',
    ExportFormat.word => 'application/rtf',
  };

  String suggestedFileName([String stem = 'student_grade_report']) =>
      '$stem.$extension';
}

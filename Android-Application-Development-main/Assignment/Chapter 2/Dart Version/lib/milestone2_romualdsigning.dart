final class StudentRecord {
  const StudentRecord({
    required this.name,
    required this.matricule,
    required this.score,
  });

  final String? name;
  final String? matricule;
  final double? score;

  bool get hasIdentity =>
      (name?.trim().isNotEmpty ?? false) ||
      (matricule?.trim().isNotEmpty ?? false);

  String get displayName {
    final cleanName = name?.trim();
    if (cleanName != null && cleanName.isNotEmpty) {
      return cleanName;
    }

    final cleanMatricule = matricule?.trim();
    if (cleanMatricule != null && cleanMatricule.isNotEmpty) {
      return cleanMatricule;
    }

    return 'Unknown';
  }
}

// I kept this generic because the same helper works for formatting, mapping, or exporting later.
List<T> customProcess<T>(
  List<StudentRecord> items,
  T Function(StudentRecord) transform,
) => items.map(transform).toList(growable: false);

void runMilestone2Demo() {
  print('[Milestone 2 Demo]');

  final students = [
    const StudentRecord(name: 'Alice', matricule: 'ST001', score: 82),
    const StudentRecord(name: null, matricule: 'ST002', score: 67.5),
    const StudentRecord(name: '', matricule: null, score: null),
    const StudentRecord(name: 'Brian', matricule: 'ST004', score: 91),
  ];

  final validStudents = students
      .where((student) => student.hasIdentity)
      .toList(growable: false);
  final passedStudents = validStudents
      .where((student) => (student.score ?? 0) >= 65)
      .toList(growable: false);
  final scoreSum = validStudents
      .map((student) => student.score ?? 0)
      .fold<double>(0, (sum, score) => sum + score);
  final average = validStudents.isEmpty ? 0 : scoreSum / validStudents.length;

  final labels = customProcess(
    validStudents,
    (student) =>
        '${student.displayName} -> ${student.score?.toString() ?? 'X'}',
  );

  print('Total records: ${students.length}');
  print('Valid records: ${validStudents.length}');
  print('Passed records: ${passedStudents.length}');
  print('Average score: ${average.toStringAsFixed(2)}');
  print('Custom HOF output: ${labels.join(', ')}');
}

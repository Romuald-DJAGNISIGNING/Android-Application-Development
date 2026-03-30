import '../models/student_input_row.dart';

abstract interface class StudentInputParser {
  Future<List<StudentInputRow>> parseFile(String path);
}

final class CourseStudent {
  const CourseStudent({
    required this.name,
    required this.matricule,
    required this.ca,
    required this.exam,
  });

  final String name;
  final String matricule;
  final double ca;
  final double exam;
}

abstract interface class GradePolicy {
  String letterFor(double score);
}

final class StrictGradePolicy implements GradePolicy {
  const StrictGradePolicy();

  @override
  String letterFor(double score) => switch (score) {
    >= 85 => 'A',
    >= 80 => 'B+',
    >= 75 => 'B',
    >= 70 => 'C+',
    >= 65 => 'C',
    >= 60 => 'D+',
    >= 55 => 'D',
    _ => 'F',
  };
}

abstract class ScoreComponent {
  const ScoreComponent(this.weight);

  final double weight;

  double value(CourseStudent student);

  double weighted(CourseStudent student) => value(student) * weight;
}

final class ContinuousAssessment extends ScoreComponent {
  const ContinuousAssessment() : super(0.30);

  @override
  double value(CourseStudent student) => student.ca;
}

final class FinalExam extends ScoreComponent {
  const FinalExam() : super(0.70);

  @override
  double value(CourseStudent student) => student.exam;
}

final class StudentGradeCalculator {
  const StudentGradeCalculator({
    required this.policy,
    required this.components,
  });

  final GradePolicy policy;
  final List<ScoreComponent> components;

  (double, String) compute(CourseStudent student) {
    // Components stay polymorphic here, so adding quizzes or labs later is easy.
    final score = components.fold<double>(
      0,
      (sum, component) => sum + component.weighted(student),
    );
    return (score, policy.letterFor(score));
  }
}

void runMilestone3Demo() {
  print('[Milestone 3 Demo]');

  const students = [
    CourseStudent(name: 'Alice', matricule: 'ST001', ca: 26, exam: 78),
    CourseStudent(name: 'Brian', matricule: 'ST002', ca: 18, exam: 62),
    CourseStudent(name: 'Carla', matricule: 'ST003', ca: 28, exam: 84),
  ];

  const calculator = StudentGradeCalculator(
    policy: StrictGradePolicy(),
    components: [ContinuousAssessment(), FinalExam()],
  );

  for (final student in students) {
    final (score, letter) = calculator.compute(student);
    print(
      '${student.name} (${student.matricule}) -> ${score.toStringAsFixed(2)} [$letter]',
    );
  }
}

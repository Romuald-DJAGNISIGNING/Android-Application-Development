class Person {
  const Person({required this.name, required this.age});

  final String name;
  final int age;
}

List<int> processList(List<int> numbers, bool Function(int) predicate) =>
    numbers.where(predicate).toList(growable: false);

Map<String, int> mapWordLengths(List<String> words) => {
  for (final word in words) word: word.length,
};

double averageAgeStartingWith(List<Person> people, Set<String> initials) {
  final ages = people
      .where((person) => initials.contains(person.name[0].toUpperCase()))
      .map((person) => person.age)
      .toList(growable: false);

  return ages.isEmpty
      ? 0
      : ages.fold<int>(0, (sum, age) => sum + age) / ages.length;
}

void runFunctionExercises() {
  print('[Functions and Collections Exercises]');

  final numbers = [2, 5, 8, 11, 14, 17];
  final evenNumbers = processList(numbers, (value) => value.isEven);
  print('Exercise 1 - filtered even numbers: $evenNumbers');

  final words = ['dart', 'collection', 'lambda', 'map', 'filter'];
  final lengths = mapWordLengths(words);
  final longerThanFour = lengths.entries
      .where((entry) => entry.value > 4)
      .map((entry) => '${entry.key}:${entry.value}')
      .toList(growable: false);
  print('Exercise 2 - word lengths: $lengths');
  print('Exercise 2 - length > 4: $longerThanFour');

  final people = [
    const Person(name: 'Alice', age: 20),
    const Person(name: 'Brian', age: 24),
    const Person(name: 'Carla', age: 22),
    const Person(name: 'Ben', age: 26),
    const Person(name: 'David', age: 21),
  ];
  final averageAge = averageAgeStartingWith(people, {'A', 'B'});
  print(
    'Exercise 3 - average age for A/B names: ${averageAge.toStringAsFixed(2)}',
  );
}

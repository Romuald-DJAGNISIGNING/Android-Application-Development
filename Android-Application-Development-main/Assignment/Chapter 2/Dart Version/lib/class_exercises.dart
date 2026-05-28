sealed class NetworkState {
  const NetworkState();
}

final class Loading extends NetworkState {
  const Loading();
}

final class Success extends NetworkState {
  const Success(this.payload);

  final String payload;
}

final class Failure extends NetworkState {
  const Failure(this.reason);

  final String reason;
}

abstract class Animal {
  const Animal({required this.name, required this.legs});

  final String name;
  final int legs;

  String sound();

  String describe() => "$name has $legs legs and says '${sound()}'";
}

final class Dog extends Animal {
  const Dog(String name) : super(name: name, legs: 4);

  @override
  String sound() => 'Woof';
}

final class Cat extends Animal {
  const Cat(String name) : super(name: name, legs: 4);

  @override
  String sound() => 'Meow';
}

abstract interface class Drawable {
  double area();
}

final class Circle implements Drawable {
  const Circle(this.radius);

  final double radius;

  @override
  double area() => 3.141592653589793 * radius * radius;
}

final class Square implements Drawable {
  const Square(this.side);

  final double side;

  @override
  double area() => side * side;
}

String handleState(NetworkState state) => switch (state) {
  Loading() => 'Loading...',
  Success(:final payload) => 'Success: $payload',
  Failure(:final reason) => 'Error: $reason',
};

void runClassExercises() {
  print('[Classes and OOP Exercises]');

  final zoo = [const Dog('Rex'), const Cat('Milo')];
  print(
    'Exercise 1 - zoo: ${zoo.map((animal) => animal.describe()).join(', ')}',
  );

  final states = [
    const Loading(),
    const Success('Report downloaded'),
    const Failure('Timeout'),
  ];
  print('Exercise 2 - network states: ${states.map(handleState).join(', ')}');

  final shapes = [const Circle(3), const Square(4)];
  final areas = shapes
      .map((shape) => shape.area().toStringAsFixed(2))
      .join(', ');
  print('Exercise 3 - shape areas: $areas');
}

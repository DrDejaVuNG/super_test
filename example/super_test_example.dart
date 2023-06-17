import 'package:flutter_super/flutter_super.dart';
import 'package:super_test/super_test.dart';

class CounterNotifier extends RxNotifier<int> {
  @override
  int watch() {
    return 0; // Initial state
  }

  void increment() {
    state++; // Update the state
  }
}

void main() {
  testRxNotifier<CounterNotifier, int>(
    'Outputs [11] when the increment method is called and seed 10',
    build: CounterNotifier(),
    seed: 10,
    act: (notifier) => notifier.increment(),
    expect: const <int>[11],
  );
}

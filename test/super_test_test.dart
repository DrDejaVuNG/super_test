import 'package:dart_super/dart_super.dart';
import 'package:super_test/super_test.dart';

class CounterNotifier extends RxNotifier<int> {
  @override
  int initial() {
    return 0; // Initial state
  }

  void increment() {
    state++; // Update the state
  }
}

class CounterController extends SuperController {
  final _count = 0.rx; // RxInt(0);

  int get count => _count.state;

  void increment() {
    _count.state++;
  }

  @override
  void onDisable() {
    _count.dispose(); // Dispose Rx object.
    super.onDisable();
  }
}

void main() {
  testController<CounterController, int>(
    'Outputs [1, 2] when the increment method is called multiple times '
    'with asynchronous act, 1',
    build: () => CounterController(),
    state: (controller) => controller.count,
    act: (controller) async {
      controller._count.state++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      controller._count.state++;
    },
    expect: () => const <int>[1, 2],
  );

  testRxT<int>(
    'Outputs [2] when the increment method is called twice and skip: 1, 3',
    build: () => 0.rx,
    act: (rx) {
      rx.state++;
      rx.state++;
    },
    skip: 1,
    expect: () => const <int>[2],
  );

  testRxT<int>(
    'Outputs [11] when the increment method is called and seed 10',
    build: () => 0.rx,
    seed: () => 10,
    act: (rx) => rx.state++,
    expect: () => const <int>[11],
  );

  testRxNotifier<CounterNotifier, int>(
    'Outputs [2] when the increment method is called twice and skip: 1',
    build: () => CounterNotifier(),
    act: (notifier) {
      notifier
        ..increment()
        ..increment();
    },
    skip: 1,
    expect: () => const <int>[2],
  );

  testRxNotifier<CounterNotifier, int>(
    'Outputs [11] when the increment method is called and seed 10',
    build: () => CounterNotifier(),
    seed: () => 10,
    act: (notifier) => notifier.increment(),
    expect: () => const <int>[11],
  );
}

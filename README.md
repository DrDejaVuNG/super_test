<p align="center">
  Credits to <a href="https://pub.dev/packages/bloc_test">bloc_test</a> for the orignal model
</p>

---

# Super Test

Developed to simplify testing of SuperControllers, RxNotifiers and RxTs. Designed for the [flutter_super](https://pub.dev/packages/flutter_super) package.

---

## Create a Mock 

```dart
class MockCounterController extends CounterController {}

class MockCounterNotifier extends CounterNotifier {}
```

## Controller Tests

Test case for a `SuperController` object.

The `testController` function is used to define a test case for a `SuperController` object. It takes various parameters to configure the test case, including the `description` of the test, the `build` function to create the `SuperController` object, functions for handling enable, alive, and disable states, setup and teardown functions, initial state `seed`, actions to perform on the controller, a wait duration, expected outcomes, verification functions, error handling, and optional `tags` for categorization.

Example usage:

```dart
testController<MyController, int>(
  'MyController test',
  build: MyController(),
  state: (controller) => controller.myState,
  onEnable: (controller) {
    // Handle the enable state.
  },
  onAlive: (controller) {
    // Handle the alive state.
  },
  onDisable: (controller) {
    // Handle the disable state.
  },
  setUp: () {
    // Perform setup operations.
  },
  seed: 10,
  act: (controller) async {
    // Perform actions on the controller.
  },
  wait: const Duration(seconds: 1),
  expect: [10],
  verify: (controller) async {
    // Perform additional verifications.
  },
  tearDown: () {
    // Perform teardown operations.
  },
);
```

In the above example, the [testController] function is used to define a test case for a custom [SuperController] object that holds an integer value. The test case includes a description, a [build] function to create the [SuperController] object, functions to handle the enable, alive, and disable states, setup and teardown functions, an initial state [seed], actions to perform on the controller, a wait duration, expected outcomes, verification functions, and teardown operations. The test case can be executed by running the test suite.

The [testController] function provides a convenient way to define and organize test cases for [SuperController] objects in unit tests.

## RxT Tests

Defines a test case for a [RxT] object.

The [testRxT] function defines a test case for a specific [RxT] object, which represents a reactive state container. It allows you to set up the initial state, perform actions on the state, and verify the expected behavior and outcomes.

The [testRxT] function takes various parameters to configure the test  case, such as the test description, setup and teardown functions, actions to perform on the state, expected outcomes, and error handling. It uses the [test] library from the `test` package to define and run the actual test.

Example usage:

```dart
testRxT<int>(
 'RxT test case',
 build: RxT<int>(0),
 act: (rx) => rx.value = 10,
 expect: [10],
);
```

In the above example, the [testRxT] function is used to define a test case for an [RxT] object that holds an integer value. The test case sets up the initial state, performs an action by assigning the value 10 to the state, and expects the state to have the value 10. The test case is then run using the [test] library.

The [testRxT] function simplifies the testing of reactive state containers, allowing you to define clear and concise test cases that cover different scenarios and behaviors of the state.

## RxNotifier Tests

Defines a test case for a [RxNotifier] object.

The [testRxNotifier] function defines a test case for a specific [RxNotifier] object, which represents a reactive state container. It allows you to set up the initial state, perform actions on the state, and verify the expected behavior and outcomes.

The [testRxNotifier] function takes various parameters to configure the test case, such as the test description, setup and teardown functions, actions to perform on the state, expected outcomes, and error handling. It uses the [test] library from the `test` package to define and run the actual test.

Example usage:

```dart
testRxNotifier<int>(
 'RxNotifier test case',
 build: RxNotifier<int>(0),
 act: (notifier) => notifier.value = 10,
 expect: [10],
);
```

In the above example, the [testRxNotifier] function is used to define a test case for an [RxNotifier] object that holds an integer value. The test case sets up the initial state, performs an action by assigning the value 10 to the state, and expects the state to have the value 10. The test case is then run using the [test] library.

The [testRxNotifier] function simplifies the testing of reactive state containers, allowing you to define clear and concise test cases that cover different scenarios and behaviors of the state.

## Additional Information

For more information on all the APIs and more, check out the [API reference](https://pub.dev/documentation/super_test/latest).

## Requirements

- Dart 3: >= 3.0.0

## Maintainers

- [Seyon Anko](https://github.com/DrDejaVuNG)

## Credits

All credits to God Almighty who guided me through the project.

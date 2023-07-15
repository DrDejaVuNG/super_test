import 'dart:async';

import 'package:dart_super/dart_super.dart';
import 'package:meta/meta.dart';
import 'package:super_test/src/core.dart';
import 'package:test/test.dart' as test;

/// Defines a test case for a [RxNotifier] object.
///
/// The [testRxNotifier] function defines a test case for a specific [RxNotifier] object, which represents
/// a reactive state container. It allows you to set up the initial state, perform actions
/// on the state, and verify the expected behavior and outcomes.
///
/// The [testRxNotifier] function takes various parameters to configure the test case, such as the
/// test description, setup and teardown functions, actions to perform on the state, expected
/// outcomes, and error handling. It uses the [test] library from the `test` package to define
/// and run the actual test.
///
/// Example usage:
/// ```dart
/// testRxNotifier<int>(
///   'RxNotifier test case',
///   build: RxNotifier<int>(0),
///   act: (notifier) => notifier.value = 10,
///   expect: [10],
/// );
/// ```
///
/// In the above example, the [testRxNotifier] function is used to define a test case for an [RxNotifier] object
/// that holds an integer value. The test case sets up the initial state, performs an action by
/// assigning the value 10 to the state, and expects the state to have the value 10. The test case
/// is then run using the [test] library.
///
/// The [testRxNotifier] function simplifies the testing of reactive state containers, allowing you to
/// define clear and concise test cases that cover different scenarios and behaviors of the state.
@isTest
void testRxNotifier<S extends RxNotifier<T>, T>(
  String description, {
  required S build,
  FutureOr<void> Function()? setUp,
  T? seed,
  FutureOr<void> Function(S notifier)? act,
  Duration? wait,
  int skip = 0,
  List<T>? expect,
  FutureOr<void> Function(S notifier)? verify,
  Object? errors,
  FutureOr<void> Function()? tearDown,
  dynamic tags,
}) {
  test.test(
    description,
    () async {
      await _rxNotifierTest<S, T>(
        setUp: setUp,
        build: build,
        seed: seed,
        act: act,
        wait: wait,
        skip: skip,
        expect: expect,
        verify: verify,
        errors: errors,
        tearDown: tearDown,
      );
    },
    tags: tags,
  );
}

/// Internal runner for the [testRxNotifier] function.
///
/// The [_rxNotifierTest] function is an internal function used by the [testRxNotifier] function to execute
/// the actual test case. It handles the setup, execution, verification, and teardown of the
/// test case for an [RxNotifier] object.
///
/// It takes various parameters to configure the test case, including the [build] function to create
/// the [RxNotifier] object, setup and teardown functions, initial state [seed], actions to perform on the notifier,
/// expected outcomes, error handling, and verification functions.
///
/// Example usage:
/// ```dart
/// _rxNotifierTest<MyNotifier, int>(
///   setUp: () async {
///     // Perform setup operations.
///   },
///   build: () => MyNotifier(),
///   act: (notifier) async {
///     // Perform actions on the notifier.
///   },
///   wait: const Duration(seconds: 1),
///   expect: [10],
///   verify: (notifier) async {
///     // Perform additional verifications.
///   },
///   tearDown: () async {
///     // Perform teardown operations.
///   },
/// );
/// ```
///
/// In the above example, the [_rxNotifierTest] function is used internally by the [testRxNotifier] function
/// to execute a test case for a custom [RxNotifier] object that holds an integer value. The function defines
/// the setup, teardown, actions, and verifications to be performed on the notifier. It uses the [build]
/// function to create the [RxNotifier] object, performs the setup, actions, and verifications, and handles
/// the teardown of the test case.
///
/// The [_rxNotifierTest] function is not intended to be used directly but provides the implementation for
/// the [testRxNotifier] function.
Future<void> _rxNotifierTest<S extends RxNotifier<T>, T>({
  required S build,
  required int skip,
  FutureOr<void> Function()? setUp,
  T? seed,
  FutureOr<void> Function(S notifier)? act,
  Duration? wait,
  List<T>? expect,
  FutureOr<void> Function(S notifier)? verify,
  Object? errors,
  FutureOr<void> Function()? tearDown,
}) async {
  var shallowEquality = false;
  final unhandledErrors = <Object>[];

  try {
    await runZoneGuarded(() async {
      await setUp?.call();
      final states = <T>[];
      final notifier = build;
      var changes = 0;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (seed != null) notifier.state = seed;
      notifier.addListener(() {
        if (skip == 0 || changes == skip) {
          states.add(notifier.state);
        }
        changes++;
      });

      try {
        await act?.call(notifier);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }

      if (wait != null) await Future<void>.delayed(wait);
      notifier.dispose();

      if (expect != null) {
        final dynamic expected = expect;
        shallowEquality = '$states' == '$expected';
        try {
          test.expect(states, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality || expected is! List<T>) rethrow;
          final diff = differ(expected: expected, actual: states);
          final message = '${e.message}\n$diff';
          throw test.TestFailure(message);
        }
      }
      await verify?.call(notifier);
      await tearDown?.call();
    });
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      throw test.TestFailure(
        '''
${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testRxNotifier rather than concrete state instances.\n''',
      );
    }
    if (errors == null || !unhandledErrors.contains(error)) {
      rethrow;
    }
  }

  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors));
}

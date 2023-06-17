import 'dart:async';

import 'package:flutter_super/flutter_super.dart';
import 'package:meta/meta.dart';
import 'package:super_test/src/core.dart';
import 'package:test/test.dart' as test;

/// Defines a test case for a [RxT] object.
///
/// The [testRxT] function defines a test case for a specific [RxT] object, which represents
/// a reactive state container. It allows you to set up the initial state, perform actions
/// on the state, and verify the expected behavior and outcomes.
///
/// The [testRxT] function takes various parameters to configure the test case, such as the
/// test description, setup and teardown functions, actions to perform on the state, expected
/// outcomes, and error handling. It uses the [test] library from the `test` package to define
/// and run the actual test.
///
/// Example usage:
/// ```dart
/// testRxT<int>(
///   'RxT test case',
///   build: RxT<int>(0),
///   act: (rx) => rx.value = 10,
///   expect: [10],
/// );
/// ```
///
/// In the above example, the [testRxT] function is used to define a test case for an [RxT] object
/// that holds an integer value. The test case sets up the initial state, performs an action by
/// assigning the value 10 to the state, and expects the state to have the value 10. The test case
/// is then run using the [test] library.
///
/// The [testRxT] function simplifies the testing of reactive state containers, allowing you to
/// define clear and concise test cases that cover different scenarios and behaviors of the state.
@isTest
void testRxT<T>(
  String description, {
  required RxT<T> build,
  FutureOr<void> Function()? setUp,
  T? seed,
  FutureOr<void> Function(RxT<T> rx)? act,
  Duration? wait,
  int skip = 0,
  List<T>? expect,
  FutureOr<void> Function(RxT<T> rx)? verify,
  Object? errors,
  FutureOr<void> Function()? tearDown,
  dynamic tags,
}) {
  test.test(
    description,
    () async {
      await _rxtTest<T>(
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

/// Internal runner for the [testRxT] function.
///
/// The [_rxtTest] function is an internal function used by the [testRxT] function to execute
/// the actual test case. It handles the setup, execution, verification, and teardown of the
/// test case for an [RxT] object.
///
/// It takes various parameters to configure the test case, including the [build] function to create
/// the [RxT] object, setup and teardown functions, initial state [seed], actions to perform on the state,
/// expected outcomes, error handling, and verification functions.
///
/// Example usage:
/// ```dart
/// _rxtTest<int>(
///   setUp: () async {
///     // Perform setup operations.
///   },
///   build: RxT<int>(),
///   act: (rx) async {
///     // Perform actions on the state.
///   },
///   wait: const Duration(seconds: 1),
///   expect: [10],
///   verify: (rx) async {
///     // Perform additional verifications.
///   },
///   tearDown: () async {
///     // Perform teardown operations.
///   },
/// );
/// ```
///
/// In the above example, the [_rxtTest] function is used internally by the [testRxT] function
/// to execute a test case for an [RxT] object that holds an integer value. The function defines
/// the setup, teardown, actions, and verifications to be performed on the state. It uses the [build]
/// function to create the [RxT] object, performs the setup, actions, and verifications, and handles
/// the teardown of the test case.
///
/// The [_rxtTest] function is not intended to be used directly but provides the implementation for
/// the [testRxT] function.
Future<void> _rxtTest<T>({
  required RxT<T> build,
  required int skip,
  FutureOr<void> Function()? setUp,
  T? seed,
  FutureOr<void> Function(RxT<T> rx)? act,
  Duration? wait,
  List<T>? expect,
  FutureOr<void> Function(RxT<T> rx)? verify,
  Object? errors,
  FutureOr<void> Function()? tearDown,
}) async {
  var shallowEquality = false;
  final unhandledErrors = <Object>[];

  try {
    await runZoneGuarded(() async {
      await setUp?.call();
      final states = <T>[];
      final rx = build;
      var changes = 0;

      if (seed != null) rx.value = seed;
      rx.addListener(() {
        if (skip == 0 || changes == skip) {
          states.add(rx.value);
        }
        changes++;
      });

      try {
        await act?.call(rx);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }

      if (wait != null) await Future<void>.delayed(wait);
      rx.dispose();

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
      await verify?.call(rx);
      await tearDown?.call();
    });
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      throw test.TestFailure(
        '''
${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testRxT rather than concrete state instances.\n''',
      );
    }
    if (errors == null || !unhandledErrors.contains(error)) {
      rethrow;
    }
  }

  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors));
}

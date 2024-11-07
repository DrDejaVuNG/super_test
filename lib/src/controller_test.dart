// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:dart_super/dart_super.dart';
import 'package:meta/meta.dart';
import 'package:super_test/src/core.dart';
import 'package:test/test.dart' as test;

/// Test case for a [SuperController] object.
///
/// The [testController] function is used to define a test case for a [SuperController] object.
/// It takes various parameters to configure the test case, including the [description] of the test,
/// the [build] function to create the [SuperController] object, functions for handling enable, alive,
/// and disable states, setup and teardown functions, initial state [seed], actions to perform on the controller,
/// a wait duration, expected outcomes, verification functions, error handling, and optional [tags] for categorization.
///
/// Example usage:
/// ```dart
/// testController<MyController, int>(
///   'MyController test',
///   build: () => MyController(),
///   state: (controller) => controller.myState,
///   onEnable: () {
///     // Handle the enable state.
///   },
///   onAlive: () {
///     // Handle the alive state.
///   },
///   onDisable: () {
///     // Handle the disable state.
///   },
///   setUp: () {
///     // Perform setup operations.
///   },
///   seed: () => 10,
///   act: (controller) async {
///     // Perform actions on the controller.
///   },
///   wait: const Duration(seconds: 1),
///   expect: () => [10],
///   verify: (controller) async {
///     // Perform additional verifications.
///   },
///   tearDown: () {
///     // Perform teardown operations.
///   },
/// );
/// ```
///
/// In the above example, the [testController] function is used to define a test case for a custom
/// [SuperController] object that holds an integer value. The test case includes a description, a [build]
/// function to create the [SuperController] object, functions to handle the enable, alive, and disable states,
/// setup and teardown functions, an initial state [seed], actions to perform on the controller, a wait duration,
/// expected outcomes, verification functions, and teardown operations. The test case can be executed by running the test suite.
///
/// The [testController] function provides a convenient way to define and organize test cases for
/// [SuperController] objects in unit tests.
@isTest
void testController<S extends SuperController, T>(
  String description, {
  required S Function() build,
  required T Function(S controller) state,
  void Function(S controller)? onEnable,
  void Function(S controller)? onAlive,
  void Function(S controller)? onDisable,
  FutureOr<void> Function()? setUp,
  T Function()? seed,
  FutureOr<void> Function(S controller)? act,
  Duration? wait,
  int skip = 0,
  List<T> Function()? expect,
  FutureOr<void> Function(S controller)? verify,
  Object Function()? errors,
  FutureOr<void> Function()? tearDown,
  dynamic tags,
}) {
  test.test(
    description,
    () async {
      await _controllerTest<S, T>(
        setUp: setUp,
        build: build,
        state: state,
        seed: seed,
        onEnable: onEnable,
        onAlive: onAlive,
        onDisable: onDisable,
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

/// Internal runner for [testController].
///
/// This function is responsible for executing the test case defined by the [testController] function.
/// It performs setup operations, creates the [SuperController] object, sets up listeners for state changes,
/// executes actions on the controller, waits for a specified duration, disposes of the controller, handles
/// the disable state, performs verifications, and handles errors.
Future<void> _controllerTest<S extends SuperController, T>({
  required S Function() build,
  required T Function(S controller) state,
  required int skip,
  void Function(S controller)? onEnable,
  void Function(S controller)? onAlive,
  void Function(S controller)? onDisable,
  FutureOr<void> Function()? setUp,
  T Function()? seed,
  FutureOr<void> Function(S controller)? act,
  Duration? wait,
  List<T> Function()? expect,
  FutureOr<void> Function(S controller)? verify,
  Object Function()? errors,
  FutureOr<void> Function()? tearDown,
}) async {
  var shallowEquality = false;
  final unhandledErrors = <Object>[];

  try {
    await runZoneGuarded(() async {
      await setUp?.call();
      final states = <T>[];
      final controller = build();

      onEnable?.call(controller);

      RxListener.listen();
      state(controller);
      final mergeRx = RxListener.listenedRx<T>();
      final rx = mergeRx.children[0]!;
      var changes = 0;

      if (seed != null) rx.state = seed();
      rx.addListener(() {
        if (skip == 0 || changes == skip) {
          states.add(rx.state);
        }
        changes++;
      });

      onAlive?.call(controller);

      try {
        await act?.call(controller);
      } catch (error) {
        if (errors == null) rethrow;
        unhandledErrors.add(error);
      }
      if (wait != null) await Future<void>.delayed(wait);
      if (rx is RxT) rx.dispose();
      if (rx is RxNotifier) rx.dispose();

      onDisable?.call(controller);

      if (expect != null) {
        final dynamic expected = expect();
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
      await verify?.call(controller);
      await tearDown?.call();
    });
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      throw test.TestFailure(
        '''
${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the testController rather than concrete state instances.\n''',
      );
    }
    if (errors == null || !unhandledErrors.contains(error)) {
      rethrow;
    }
  }

  if (errors != null) test.expect(unhandledErrors, test.wrapMatcher(errors()));
}

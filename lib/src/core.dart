import 'dart:async';

import 'package:diff_match_patch/diff_match_patch.dart';

/// Executes a function within a guarded zone, capturing and handling
/// any errors that occur.
///
/// The [runZoneGuarded] function runs the provided [body] function
/// within a [runZonedGuarded] zone, ensuring that any synchronous or
/// asynchronous errors thrown within the zone are caught and handled
/// properly. The [body] function should represent the code that needs
/// to be executed within the guarded zone.
///
/// The [runZoneGuarded] function returns a [Future] that completes
/// when the [body] function and any subsequent asynchronous operations
/// complete. If an error occurs within the zone, the returned [Future]
/// completes with an error.
///
/// Example usage:
/// ```dart
/// runZoneGuarded(() async {
///   // Perform operations within the guarded zone.
///   await someAsyncOperation();
///   performSomeSyncOperation();
///   // ...
/// });
/// ```
///
/// In the above example, the [runZoneGuarded] function is used to
/// execute a block of code that performs asynchronous and synchronous
/// operations. Any errors thrown within the guarded zone are captured
/// and handled appropriately, allowing the execution to continue without
/// crashing the application.
///
/// The [runZoneGuarded] function is particularly useful when dealing
/// with code that can potentially throw exceptions or errors, providing
/// a mechanism to gracefully handle and recover from errors within a
/// specific context or scope.
Future<void> runZoneGuarded(Future<void> Function() body) {
  final completer = Completer<void>();
  runZonedGuarded(() async {
    await body();
    if (!completer.isCompleted) completer.complete();
  }, (error, stackTrace) {
    if (!completer.isCompleted) completer.completeError(error, stackTrace);
  });
  return completer.future;
}

/// Performs a diff comparison between two objects and returns a
/// formatted string of the differences.
///
/// The [differ] function takes two objects, [expected] and [actual],
/// and performs a comparison between them using the `diff` function
/// from the [diff_match_patch] library. It then formats the differences
/// into a readable string representation and returns it.
///
/// The [expected] and [actual] objects can be of any type, as long
/// as they have a valid string representation. The differences between
/// the two objects are calculated based on their string representations.
///
/// Example usage:
/// ```dart
/// final expected = 'Hello, world!';
/// final actual = 'Hello, flutter!';
///
/// final differences = differ(expected: expected, actual: actual);
/// print(differences);
/// ```
///
/// In the above example, the [differ] function is used to compare two
/// strings, `expected` and `actual`. It calculates the differences
/// between the two strings and formats them into a readable string.
/// The formatted differences are then printed to the console.
///
/// The [differ] function is useful for comparing and visualizing the
/// differences between two objects, such as strings or text, providing
/// insights into what has changed or how the objects differ.
String differ({required dynamic expected, required dynamic actual}) {
  final buffer = StringBuffer();
  final differences = diff(expected.toString(), actual.toString());
  buffer
    ..writeln('${"=" * 4} diff ${"=" * 40}')
    ..writeln()
    ..writeln(differences.toPrettyString())
    ..writeln()
    ..writeln('${"=" * 4} end diff ${"=" * 36}');
  return buffer.toString();
}

/// An extension on the [List] class that converts a list of [Diff]
/// objects to a formatted string.
extension on List<Diff> {
  /// Converts a list of [Diff] objects to a formatted string.
  ///
  /// The [toPrettyString] function iterates over each [Diff] object
  /// in the list and converts it to a formatted string representation
  /// based on the operation type.
  /// The formatted string includes color codes to differentiate between
  /// identical text, deleted text, and inserted text.
  ///
  /// Example usage:
  /// ```dart
  /// final diffs = [
  ///   Diff(DIFF_EQUAL, 'The quick '),
  ///   Diff(DIFF_DELETE, 'brown '),
  ///   Diff(DIFF_INSERT, 'red '),
  ///   Diff(DIFF_EQUAL, 'fox'),
  /// ];
  ///
  /// final prettyString = diffs.toPrettyString();
  /// print(prettyString);
  /// ```
  ///
  /// In the above example, the [toPrettyString] function is called
  /// on a list of [Diff] objects, representing the differences between
  /// two texts. The function converts the differences into a formatted
  /// string, including color-coded annotations for identical, deleted,
  /// and inserted text. The formatted string is then printed to the console.
  ///
  /// The [toPrettyString] function is useful for visualizing the differences
  /// between two texts or strings and highlighting the parts that have
  /// been deleted or inserted, making it easier to understand and
  /// analyze the changes.
  String toPrettyString() {
    String identical(String str) => '\u001b[90m$str\u001B[0m';
    String deletion(String str) => '\u001b[31m[-$str-]\u001B[0m';
    String insertion(String str) => '\u001b[32m{+$str+}\u001B[0m';

    final buffer = StringBuffer();
    for (final difference in this) {
      switch (difference.operation) {
        case DIFF_EQUAL:
          buffer.write(identical(difference.text));
          break;
        case DIFF_DELETE:
          buffer.write(deletion(difference.text));
          break;
        case DIFF_INSERT:
          buffer.write(insertion(difference.text));
          break;
      }
    }
    return buffer.toString();
  }
}

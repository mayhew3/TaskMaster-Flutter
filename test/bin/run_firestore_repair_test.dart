/// Runner for firestore_repair CLI tool
///
/// Usage: flutter test test/bin/run_firestore_repair_test.dart
///
/// This is a workaround because `dart run` doesn't work with Flutter-dependent
/// packages like cloud_firestore. Running through `flutter test` provides the
/// Flutter engine needed by these packages.
@Tags(['cli'])
library;

import 'package:flutter_test/flutter_test.dart';
import '../../bin/firestore_repair.dart' as repair_tool;

void main() {
  test('Run firestore_repair with args from environment', () async {
    // Get args from environment variable, or use defaults
    final argsEnv = const String.fromEnvironment('ARGS', defaultValue: '--help');
    final args = argsEnv.split(' ').where((s) => s.isNotEmpty).toList();

    print('Running firestore_repair with args: $args');
    await repair_tool.main(args);
  }, tags: ['cli']);
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global setup that runs before every test file in this package.
/// Used by `flutter test` automatically when this file is present at
/// `test/flutter_test_config.dart`.
///
/// TM-359:
/// 1. Initializes the test widgets binding so non-widget unit tests can
///    still drive plugins that route through method channels (notably
///    `SharedPreferences.getInstance()`, which the new TaskListView
///    persistence layer depends on).
/// 2. Seeds `SharedPreferences` with an empty mock store so the app's
///    `sharedPreferencesProvider` resolves without an explicit override.
///    Individual tests can override per-test by calling
///    `SharedPreferences.setMockInitialValues({...})` with seed data,
///    or clear the singleton between tests via
///    `await (await SharedPreferences.getInstance()).clear()` in
///    setUp().
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await testMain();
}

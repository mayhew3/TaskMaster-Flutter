import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provides the singleton [SharedPreferences] instance.
///
/// Asynchronous — bootstrap (`main.dart`) awaits the future before
/// `runApp` so by the time the widget tree mounts, the value is ready.
/// Consumers that need to read it synchronously should handle the
/// `AsyncValue.loading` state gracefully (e.g. fall back to defaults
/// until the value resolves).
///
/// Tests: the project's `test/flutter_test_config.dart` calls
/// `SharedPreferences.setMockInitialValues({})` before every test file,
/// so `getInstance()` resolves to an empty in-memory store on the next
/// microtask. Tests that want pre-populated state can either call
/// `setMockInitialValues` themselves with seed data, or override this
/// provider directly with an already-loaded instance.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

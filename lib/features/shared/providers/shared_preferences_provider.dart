import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provides the singleton [SharedPreferences] instance.
///
/// Synchronous — bootstrap (`main.dart`) calls
/// `SharedPreferences.getInstance()` and supplies the resolved value via
/// an override on `ProviderScope`. The override is **required**: the
/// uninjected base provider throws, which guarantees synchronous
/// consumers (e.g. `taskListViewProvider`) never see a missing instance
/// at runtime.
///
/// Tests:
/// ```dart
/// SharedPreferences.setMockInitialValues({});
/// final prefs = await SharedPreferences.getInstance();
/// container = ProviderContainer(overrides: [
///   sharedPreferencesProvider.overrideWithValue(prefs),
/// ]);
/// ```
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a resolved '
    'SharedPreferences instance. Bootstrap (main.dart) handles this via '
    '`overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]`; '
    'tests should do the same after `SharedPreferences.setMockInitialValues`.',
  );
}

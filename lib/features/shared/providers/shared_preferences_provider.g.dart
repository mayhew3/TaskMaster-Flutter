// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

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

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
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
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

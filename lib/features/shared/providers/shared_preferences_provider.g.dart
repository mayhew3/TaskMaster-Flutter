// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

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

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
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
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'4cba2b80ee7cc89e95fb5be4b3dc93f09210eba2';

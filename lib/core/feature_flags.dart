/// Feature flags for gradual migration from Redux to Riverpod
///
/// Usage:
/// - During development: Set flags to true to test new Riverpod implementations
/// - In production: Keep flags false until feature is fully tested
/// - After migration complete: Remove flags and old Redux code
///
/// Example:
/// ```dart
/// // Run with Riverpod stats screen
/// flutter run --dart-define=USE_RIVERPOD_STATS=true
///
/// // Run with Redux (default)
/// flutter run
/// ```
class FeatureFlags {
  /// Use Riverpod implementation for Stats screen
  /// Default: false (use Redux)
  static const bool useRiverpodForStats =
      bool.fromEnvironment('USE_RIVERPOD_STATS', defaultValue: false);

  /// Use Riverpod implementation for Tasks list screen
  /// Default: false (use Redux)
  static const bool useRiverpodForTasks =
      bool.fromEnvironment('USE_RIVERPOD_TASKS', defaultValue: false);

  /// Use Riverpod implementation for Sprint screens
  /// Default: false (use Redux)
  static const bool useRiverpodForSprints =
      bool.fromEnvironment('USE_RIVERPOD_SPRINTS', defaultValue: false);

  /// Use go_router for navigation
  /// Default: false (use manual navigation)
  static const bool useGoRouter =
      bool.fromEnvironment('USE_GO_ROUTER', defaultValue: false);

  /// Helper to check if any Riverpod features are enabled
  static bool get anyRiverpodEnabled =>
      useRiverpodForStats || useRiverpodForTasks || useRiverpodForSprints;

  /// Print feature flag status (useful for debugging)
  static void printStatus() {
    print('=== Feature Flags Status ===');
    print('Riverpod Stats: $useRiverpodForStats');
    print('Riverpod Tasks: $useRiverpodForTasks');
    print('Riverpod Sprints: $useRiverpodForSprints');
    print('go_router: $useGoRouter');
    print('Any Riverpod: $anyRiverpodEnabled');
    print('===========================');
  }
}

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
  /// Default: true (Riverpod enabled by default)
  static const bool useRiverpodForStats =
      bool.fromEnvironment('USE_RIVERPOD_STATS', defaultValue: true);

  /// Use Riverpod implementation for Tasks list screen
  /// Default: true (Riverpod enabled by default)
  static const bool useRiverpodForTasks =
      bool.fromEnvironment('USE_RIVERPOD_TASKS', defaultValue: true);

  /// Use Riverpod implementation for Sprint screens
  /// Default: true (Riverpod enabled by default)
  static const bool useRiverpodForSprints =
      bool.fromEnvironment('USE_RIVERPOD_SPRINTS', defaultValue: true);

  /// Use go_router for navigation
  /// Default: false (use manual navigation)
  static const bool useGoRouter =
      bool.fromEnvironment('USE_GO_ROUTER', defaultValue: false);

  /// Use Riverpod implementation for Authentication
  /// Default: true (Riverpod enabled by default)
  static const bool useRiverpodForAuth =
      bool.fromEnvironment('USE_RIVERPOD_AUTH', defaultValue: true);

  /// Helper to check if any Riverpod features are enabled
  static bool get anyRiverpodEnabled =>
      useRiverpodForStats || useRiverpodForTasks || useRiverpodForSprints || useRiverpodForAuth;

  /// Print feature flag status (useful for debugging)
  static void printStatus() {
    print('=== Feature Flags Status ===');
    print('Riverpod Auth: $useRiverpodForAuth');
    print('Riverpod Stats: $useRiverpodForStats');
    print('Riverpod Tasks: $useRiverpodForTasks');
    print('Riverpod Sprints: $useRiverpodForSprints');
    print('go_router: $useGoRouter');
    print('Any Riverpod: $anyRiverpodEnabled');
    print('===========================');
  }
}

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaster/app_theme.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/notification_providers.dart';
import 'package:taskmaster/core/services/auth_service.dart';
import 'package:taskmaster/core/services/sync_service.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/shared/providers/navigation_provider.dart';
import 'package:taskmaster/helpers/task_selectors.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/features/shared/presentation/offline_banner.dart';
import 'package:taskmaster/features/shared/presentation/planning_home.dart';
import 'package:taskmaster/features/tasks/presentation/stats_screen.dart';

/// Riverpod-based main app widget
/// This replaces the Redux-based TaskMasterApp when useRiverpodForAuth is enabled
class RiverpodTaskMasterApp extends ConsumerStatefulWidget {
  final String emulatorHost;

  const RiverpodTaskMasterApp({super.key, required this.emulatorHost});

  @override
  ConsumerState<RiverpodTaskMasterApp> createState() => _RiverpodTaskMasterAppState();
}

class _RiverpodTaskMasterAppState extends ConsumerState<RiverpodTaskMasterApp> {
  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  @override
  void initState() {
    super.initState();
    _configureFirestore();
  }

  void _configureFirestore() {
    final firestore = FirebaseFirestore.instance;

    if (serverEnv == 'local') {
      final emulatorHost = widget.emulatorHost;
      print('🔧 USING LOCAL FIRESTORE EMULATOR');
      print('📡 Connecting to: $emulatorHost:8085');
      print('⚠️  Make sure Firebase emulator is running: firebase emulators:start');
      firestore.useFirestoreEmulator(emulatorHost, 8085);
      firestore.settings = const Settings(
        persistenceEnabled: false,
      );
    } else {
      print('☁️  USING PRODUCTION FIRESTORE (serverEnv: $serverEnv)');
      firestore.settings = const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'TaskMaster 3000',
      theme: taskMasterTheme,
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.authenticating:
        return const _SplashScreen(message: 'Signing in...');

      case AuthStatus.unauthenticated:
        return _SignInScreen(
          errorMessage: authState.errorMessage,
          onSignIn: () => ref.read(authProvider.notifier).signIn(),
        );

      case AuthStatus.personNotFound:
        return _SignInScreen(
          errorMessage: authState.errorMessage ?? 'Account not found',
          onSignIn: () => ref.read(authProvider.notifier).signIn(),
          showSignOutOption: true,
          onSignOut: () => ref.read(authProvider.notifier).signOut(),
        );

      case AuthStatus.connectionError:
        return _ConnectionErrorScreen(
          message: authState.errorMessage ?? 'Connection failed',
          onRetry: () => ref.read(authProvider.notifier).retry(),
        );

      case AuthStatus.authenticated:
        return const _AuthenticatedHome();
    }
  }
}

/// Splash screen shown during auth initialization
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Sign-in screen
class _SignInScreen extends StatelessWidget {
  const _SignInScreen({
    this.errorMessage,
    required this.onSignIn,
    this.showSignOutOption = false,
    this.onSignOut,
  });

  final String? errorMessage;
  final VoidCallback onSignIn;
  final bool showSignOutOption;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster 3000'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              errorMessage ?? 'You are not currently signed in.',
              textAlign: TextAlign.center,
              style: errorMessage != null
                  ? const TextStyle(color: Colors.red)
                  : null,
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: onSignIn,
                  child: const Text('SIGN IN'),
                ),
                if (showSignOutOption && onSignOut != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onSignOut,
                    child: const Text('Try a different account'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Connection error screen (e.g., Firestore emulator not running)
class _ConnectionErrorScreen extends StatelessWidget {
  const _ConnectionErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                serverEnv == 'local'
                    ? 'Firestore Emulator Not Running'
                    : 'Connection Error',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (serverEnv == 'local') ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To fix this:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1. Open a new terminal\n'
                        '2. Run: firebase emulators:start\n'
                        '3. Wait for "All emulators ready!"\n'
                        '4. Press Retry below',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main app content when authenticated
class _AuthenticatedHome extends ConsumerStatefulWidget {
  const _AuthenticatedHome();

  @override
  ConsumerState<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends ConsumerState<_AuthenticatedHome> {
  late final List<TopNavItem> _navItems;
  bool _initialSyncDone = false;

  @override
  void initState() {
    super.initState();
    _navItems = [
      TopNavItem.init(
        label: 'Plan',
        icon: Icons.assignment,
        widgetGetter: () => PlanningHome(),
      ),
      TopNavItem.init(
        label: 'Tasks',
        icon: Icons.list,
        widgetGetter: () => const TaskListScreen(),
      ),
      TopNavItem.init(
        label: 'Stats',
        icon: Icons.show_chart,
        widgetGetter: () => const StatsScreen(),
      ),
    ];

    _setupBadgeUpdater();

    // Bootstrap SyncService and wait for the first round of Firestore snapshots
    // before showing the main UI. Falls back to local cache after 8 seconds
    // (covers the offline case).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final personDocId = ref.read(personDocIdProvider);
      if (personDocId != null) {
        final syncService = ref.read(syncServiceProvider);
        await syncService.start(personDocId);
        await syncService.initialPullComplete
            .timeout(const Duration(seconds: 8), onTimeout: () {});
      }
      if (mounted) {
        setState(() => _initialSyncDone = true);
      }
      _syncNotificationsInBackground();
    });
  }

  @override
  void dispose() {
    // Fire-and-forget: dispose() is sync, so we can't await stop(). The
    // `.ignore()` marks the intent explicitly so the linter doesn't warn.
    ref.read(syncServiceProvider).stop().ignore();
    super.dispose();
  }

  void _setupBadgeUpdater() {
    // Badge updates will be handled by watching tasks provider
    // TODO: Implement badge updates via Riverpod
  }

  /// Sync notifications in background AFTER UI renders (non-blocking)
  Future<void> _syncNotificationsInBackground() async {
    try {
      print('⏱️ _syncNotificationsInBackground: Starting background sync');
      final stopwatch = Stopwatch()..start();

      final tasks = await ref.read(tasksWithRecurrencesProvider.future);
      final sprints = await ref.read(sprintsProvider.future);
      final notificationHelper = ref.read(notificationHelperProvider);

      // Get active sprint
      final builtSprints = BuiltList<Sprint>(sprints);
      final activeSprint = activeSprintSelector(builtSprints);

      // Full sync in background
      await notificationHelper.syncNotificationForTasksAndSprint(
        tasks,
        activeSprint,
      );

      print('⏱️ _syncNotificationsInBackground: Completed in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('⚠️ _syncNotificationsInBackground: Error (non-blocking): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen until the first round of Firestore snapshots arrives
    // (or timeout for the offline case — then local cache is used).
    if (!_initialSyncDone) {
      return const _SplashScreen(message: 'Loading your tasks...');
    }

    // Watch the tab index provider (also clears recentlyCompleted on tab change - TM-312)
    final selectedIndex = ref.watch(activeTabIndexProvider);

    // Get the current screen widget
    final currentScreen = _navItems[selectedIndex].widgetGetter();

    // Build with navigation bar - using Scaffold's bottomNavigationBar slot
    // for proper Material 3 layout (not Column which caused excess padding)
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: currentScreen),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: TaskColors.menuColor,
        indicatorColor: TaskColors.backgroundColor,
        height: 70,
        onDestinationSelected: (index) {
          // Use provider to change tab - this also clears recentlyCompleted (TM-312)
          ref.read(activeTabIndexProvider.notifier).setTab(index);
        },
        destinations: _navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

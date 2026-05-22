import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/app_theme.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/providers/notification_providers.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/core/services/sync_service.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/features/shared/providers/navigation_provider.dart';
import 'package:taskmaestro/helpers/task_selectors.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/top_nav_item.dart';
import 'package:taskmaestro/features/shared/presentation/planning_home.dart';
import 'package:taskmaestro/features/tasks/presentation/stats_screen.dart';
import 'package:taskmaestro/features/family/presentation/family_tab_screen.dart';
import 'package:taskmaestro/features/family/presentation/pending_invitation_banner.dart';
import 'package:taskmaestro/features/family/providers/family_providers.dart';
import 'package:taskmaestro/features/sync/presentation/sync_conflict_banner.dart';
import 'package:taskmaestro/features/sync/providers/sync_conflict_providers.dart';
import 'package:taskmaestro/core/platform/form_factor.dart';
import 'package:taskmaestro/features/shared/presentation/app_drawer.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_container.dart';
import 'package:taskmaestro/features/shared/presentation/wide/right_pane_selection_sync.dart';
import 'package:taskmaestro/features/shared/presentation/wide/wide_nav_sidebar.dart';

/// Riverpod-based main app widget
/// This replaces the Redux-based TaskMaestroApp when useRiverpodForAuth is enabled
class RiverpodTaskMaestroApp extends ConsumerStatefulWidget {
  final String emulatorHost;

  const RiverpodTaskMaestroApp({super.key, required this.emulatorHost});

  @override
  ConsumerState<RiverpodTaskMaestroApp> createState() =>
      _RiverpodTaskMaestroAppState();
}

class _RiverpodTaskMaestroAppState
    extends ConsumerState<RiverpodTaskMaestroApp> {
  static const serverEnv = String.fromEnvironment(
    'SERVER',
    defaultValue: 'heroku',
  );

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
      print(
        '⚠️  Make sure Firebase emulator is running: firebase emulators:start',
      );
      firestore.useFirestoreEmulator(emulatorHost, 8085);
      firestore.settings = const Settings(persistenceEnabled: false);
    } else if (kIsWeb) {
      // TM-353: do NOT enable Firestore IndexedDB persistence on web.
      // Drift (IndexedDB-backed on web) is the durable UI source of
      // truth, so Firestore's own persistence is redundant — and
      // enabling it blocks the first Firestore operation on
      // IndexedDB-persistence init, which hung app startup at
      // "Signing In…". In-memory cache is the right choice here.
      print('☁️  USING PRODUCTION FIRESTORE (web, serverEnv: $serverEnv)');
      firestore.settings = const Settings(persistenceEnabled: false);
    } else {
      print('☁️  USING PRODUCTION FIRESTORE (serverEnv: $serverEnv)');
      firestore.settings = const Settings(
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'TaskMaestro',
      theme: taskMaestroTheme,
      darkTheme: taskMaestroTheme,
      themeMode: ThemeMode.dark,
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

/// Splash screen shown during auth initialization and initial sync.
///
/// Displays the full TaskMaestro splash image full-bleed (matching the OS-level
/// splash on iOS / Android pre-12 / web). On Android 12+, the OS splash is
/// limited to a centered icon by Google's Splash Screen API, so this widget
/// provides the full wordmark splash once Flutter takes over.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({required this.message});

  final String message;

  // Sampled dominant color of the icon/splash; matches the native splash bg
  // (windowSplashScreenBackground on Android, LaunchBackground on iOS) so
  // there is no visible seam at handoff.
  static const Color _splashBackground = Color(0xFF2B72C2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.asset(
              'assets/launcher/TaskMaestro_Splash.png',
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      appBar: AppBar(title: const Text('TaskMaestro')),
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
                FilledButton(onPressed: onSignIn, child: const Text('SIGN IN')),
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
  const _ConnectionErrorScreen({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  static const serverEnv = String.fromEnvironment(
    'SERVER',
    defaultValue: 'heroku',
  );

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
              const Icon(Icons.error_outline, size: 80, color: Colors.white),
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
                style: const TextStyle(fontSize: 16, color: Colors.white),
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
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
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
        destination: NavDestination.plan,
      ),
      TopNavItem.init(
        label: 'Tasks',
        icon: Icons.list,
        widgetGetter: () => const TaskListScreen(),
        destination: NavDestination.tasks,
      ),
      TopNavItem.init(
        label: 'Stats',
        icon: Icons.show_chart,
        widgetGetter: () => const StatsScreen(),
        destination: NavDestination.stats,
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
        final email = ref.read(currentUserProvider)?.email;
        await syncService.start(personDocId, email: email);
        await syncService.initialPullComplete.timeout(
          const Duration(seconds: 8),
          onTimeout: () {},
        );
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

      print(
        '⏱️ _syncNotificationsInBackground: Completed in ${stopwatch.elapsedMilliseconds}ms',
      );
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

    // Compose the live nav-item list. The Family tab is spliced in between
    // Tasks and Stats only when the current user is in a family (TM-335);
    // when solo, the layout matches the original 3-tab arrangement.
    final inFamily = ref.watch(currentFamilyDocIdProvider) != null;
    final liveNavItems = <TopNavItem>[
      _navItems[0], // Plan
      _navItems[1], // Tasks
      if (inFamily)
        TopNavItem.init(
          label: 'Family',
          icon: Icons.family_restroom,
          widgetGetter: () => const FamilyTabScreen(),
          destination: NavDestination.family,
        ),
      _navItems[2], // Stats
    ];
    final clampedIndex = selectedIndex
        .clamp(0, liveNavItems.length - 1)
        .toInt();
    // Write the clamped value back to the provider when a layout change (e.g.
    // leaving the family) makes the stored index out of range. Done in a
    // post-frame callback to avoid mutating provider state during build.
    if (clampedIndex != selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(activeTabIndexProvider.notifier)
              .clampToLayout(liveNavItems.length);
        }
      });
    }
    // TM-382 perf: nav clicks used to re-watch the destination's
    // providers and rebuild its full grouped list on every swap.
    // IndexedStack keeps all tab bodies mounted so switching destinations
    // toggles which child paints — no unmount/remount, no provider
    // re-watch, no list rebuild on swap. Steady-state cost: each tab's
    // providers stay subscribed; acceptable since they're keepAlive and
    // the "recently-completed clears on tab switch" contract is driven
    // by setTab, not mount lifecycle.
    final currentScreen = IndexedStack(
      index: clampedIndex,
      children: [for (final item in liveNavItems) item.widgetGetter()],
    );

    // Status-bar inset handling depends on whether any banner is visible:
    // - When showing, the banner self-wraps in SafeArea(top: true) so it
    //   sits below the system icons; we then strip MediaQuery.padding.top
    //   for currentScreen so the inner-tab AppBar doesn't double-inset
    //   (which would leave a status-bar-tall dead strip below the banner).
    // - When hidden, the banner collapses to SizedBox.shrink and the inner
    //   AppBar handles its own status-bar inset normally.
    final hasPendingInvite =
        (ref.watch(pendingInvitationsForMeProvider).value ?? const [])
            .isNotEmpty;
    final hasSyncConflict = ref.watch(allConflictsCountProvider) > 0;
    final hasAnyBanner = hasPendingInvite || hasSyncConflict;
    final tabBody = hasAnyBanner
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: currentScreen,
          )
        : currentScreen;

    // TM-382: branch only the chrome. The shared state above (nav items,
    // clamped index, banners, tabBody) is computed once; the compact
    // subtree below is byte-for-byte identical to the pre-TM-382 build.
    if (isWideLayout(MediaQuery.sizeOf(context))) {
      return _buildWideShell(
        context: context,
        liveNavItems: liveNavItems,
        clampedIndex: clampedIndex,
        hasPendingInvite: hasPendingInvite,
        tabBody: tabBody,
      );
    }
    return _buildCompactShell(
      context: context,
      liveNavItems: liveNavItems,
      clampedIndex: clampedIndex,
      hasPendingInvite: hasPendingInvite,
      tabBody: tabBody,
    );
  }

  /// Compact / phone shell — unchanged from before TM-382: a bottom
  /// [NavigationBar] plus the banner Column. This widget subtree must
  /// remain identical to the legacy build (regression guard).
  Widget _buildCompactShell({
    required BuildContext context,
    required List<TopNavItem> liveNavItems,
    required int clampedIndex,
    required bool hasPendingInvite,
    required Widget tabBody,
  }) {
    return Scaffold(
      body: Column(
        children: [
          const PendingInvitationBanner(),
          // Both banners self-wrap in SafeArea(top: true). When the
          // invitation banner is also visible above us, strip our top
          // status-bar inset so we don't double-pad below it.
          MediaQuery.removePadding(
            context: context,
            removeTop: hasPendingInvite,
            child: const SyncConflictBanner(),
          ),
          Expanded(child: tabBody),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: clampedIndex,
        backgroundColor: TaskColors.menuColor,
        indicatorColor: TaskColors.backgroundColor,
        height: 70,
        onDestinationSelected: (index) {
          ref.read(activeTabIndexProvider.notifier).setTab(index);
        },
        destinations: liveNavItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  /// Wide adaptive shell (TM-382, Story 1 of Epic TM-188): the left
  /// [WideNavSidebar] replaces the bottom nav; the banner Column + tab
  /// body keep their existing structure and order to the right.
  ///
  /// TM-383 (Story 2) adds an optional third Row cell — the
  /// [RightPaneContainer] — at logical widths ≥1200dp
  /// ([isTwoPaneWideLayout]). The right pane sits OUTSIDE the center
  /// Column so that banners only span the center region, matching the
  /// prototype's "right pane is its own surface" treatment.
  Widget _buildWideShell({
    required BuildContext context,
    required List<TopNavItem> liveNavItems,
    required int clampedIndex,
    required bool hasPendingInvite,
    required Widget tabBody,
  }) {
    final isTwoPane = isTwoPaneWideLayout(MediaQuery.sizeOf(context));

    return Scaffold(
      drawer: const AppDrawer(),
      // TM-384: wrap the wide shell in RightPaneSelectionSync — flips
      // `rightPaneProvider` to `.editor` on a non-null selection and
      // back to `.empty` when the user re-taps a row to deselect (so
      // the right pane returns to the "Select a task" empty state
      // rather than a blank pane).
      body: RightPaneSelectionSync(
        child: Row(
          children: [
            WideNavSidebar(
              navItems: liveNavItems,
              selectedIndex: clampedIndex,
              onSelectDestination: (index) {
                ref.read(activeTabIndexProvider.notifier).setTab(index);
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const PendingInvitationBanner(),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: hasPendingInvite,
                    child: const SyncConflictBanner(),
                  ),
                  Expanded(child: tabBody),
                ],
              ),
            ),
            if (isTwoPane)
              const SizedBox(
                  width: kRightPaneWidth, child: RightPaneContainer()),
          ],
        ),
      ),
    );
  }
}

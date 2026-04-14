import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';
import 'package:taskmaster/core/providers/sync_status_provider.dart';
import 'package:taskmaster/features/shared/presentation/connection_status_indicator.dart';

/// Tests for TM-340: in-AppBar connection status indicator
///
/// Replaces the deleted OfflineBanner test. Verifies priority ordering
/// (offline > error > syncing > idle) and no-layout-shift rendering.
void main() {
  Widget harness({
    required bool online,
    required SyncStatus syncStatus,
  }) {
    return ProviderScope(
      overrides: [
        connectivityProvider.overrideWith((ref) => Stream.value(online)),
        syncStatusControllerProvider.overrideWith(
          () => _FakeSyncStatusController(syncStatus),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          appBar: _TestAppBar(),
        ),
      ),
    );
  }

  group('ConnectionStatusIndicator (TM-340)', () {
    testWidgets('online + idle renders nothing visible', (tester) async {
      await tester.pumpWidget(harness(online: true, syncStatus: SyncStatus.idle));
      await tester.pump(); // Let stream emit

      expect(find.text('Offline'), findsNothing);
      expect(find.text('Sync failed'), findsNothing);
      // SizedBox.shrink is still rendered but has no text/icon children
      expect(find.byIcon(Icons.cloud_off), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('online + syncing renders 3 fixed dots', (tester) async {
      await tester.pumpWidget(
        harness(online: true, syncStatus: SyncStatus.syncing),
      );
      await tester.pump(); // Let stream emit
      await tester.pump(const Duration(milliseconds: 50)); // Let animation tick

      // 3 circular Containers (dots) inside the indicator
      final dotContainers = tester
          .widgetList<Container>(find.descendant(
            of: find.byType(ConnectionStatusIndicator),
            matching: find.byType(Container),
          ))
          .where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      }).toList();
      expect(dotContainers.length, 3,
          reason: 'Expected 3 circular dot containers');

      // Exactly one dot has full opacity; others are translucent
      final opacities = dotContainers.map((c) {
        final bg = (c.decoration as BoxDecoration).color!;
        return bg.a;
      }).toList();
      final fullDots = opacities.where((a) => a > 0.9).length;
      final dimDots = opacities.where((a) => a < 0.5).length;
      expect(fullDots, 1, reason: 'Exactly one dot should be fully opaque');
      expect(dimDots, 2, reason: 'Two dots should be translucent');

      // No pill labels
      expect(find.text('Offline'), findsNothing);
      expect(find.text('Sync failed'), findsNothing);

      // Stop animation before disposal
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('online + error renders red "Sync failed" pill', (tester) async {
      await tester.pumpWidget(
        harness(online: true, syncStatus: SyncStatus.error),
      );
      await tester.pump();

      expect(find.text('Sync failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Offline'), findsNothing);
    });

    testWidgets('offline renders orange "Offline" pill', (tester) async {
      await tester.pumpWidget(
        harness(online: false, syncStatus: SyncStatus.idle),
      );
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('offline takes priority over sync error', (tester) async {
      await tester.pumpWidget(
        harness(online: false, syncStatus: SyncStatus.error),
      );
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Sync failed'), findsNothing);
    });

    testWidgets('offline takes priority over syncing', (tester) async {
      await tester.pumpWidget(
        harness(online: false, syncStatus: SyncStatus.syncing),
      );
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('error takes priority over syncing when online', (tester) async {
      await tester.pumpWidget(
        harness(online: true, syncStatus: SyncStatus.error),
      );
      await tester.pump();

      expect(find.text('Sync failed'), findsOneWidget);
    });
  });
}

/// Minimal AppBar harness hosting only the indicator. The AppBar itself
/// has fixed height so the test verifies the indicator fits without
/// expanding layout.
class _TestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TestAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Test'),
      actions: const [ConnectionStatusIndicator()],
    );
  }
}

/// Fake notifier used via overrideWith — builds with a fixed initial status
/// so we can simulate each state.
class _FakeSyncStatusController extends SyncStatusController {
  _FakeSyncStatusController(this._initial);

  final SyncStatus _initial;

  @override
  SyncStatus build() => _initial;
}

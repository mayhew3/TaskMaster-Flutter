import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';
import 'package:taskmaster/core/providers/sync_status_provider.dart';
import 'package:taskmaster/features/shared/presentation/offline_banner.dart';

class _FakeSyncController extends SyncStatusController {
  _FakeSyncController(this._status);
  final SyncStatus _status;
  @override
  SyncStatus build() => _status;
}

Widget _wrap({required bool online, required SyncStatus syncStatus}) {
  return ProviderScope(
    overrides: [
      connectivityProvider.overrideWith((_) => Stream.value(online)),
      syncStatusControllerProvider
          .overrideWith(() => _FakeSyncController(syncStatus)),
    ],
    child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
  );
}

void main() {
  group('OfflineBanner', () {
    testWidgets('shows nothing when online and idle', (tester) async {
      await tester.pumpWidget(_wrap(online: true, syncStatus: SyncStatus.idle));
      await tester.pump();
      expect(find.text('Syncing…'), findsNothing);
      expect(find.textContaining('Offline'), findsNothing);
      // Banner renders SizedBox.shrink — no Material descendant inside it.
      expect(
        find.descendant(
            of: find.byType(OfflineBanner), matching: find.byType(Material)),
        findsNothing,
      );
    });

    testWidgets('shows "Offline" banner when offline', (tester) async {
      await tester.pumpWidget(
          _wrap(online: false, syncStatus: SyncStatus.idle));
      await tester.pump();
      expect(
        find.textContaining('Offline'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Syncing…" banner when syncing', (tester) async {
      await tester.pumpWidget(
          _wrap(online: true, syncStatus: SyncStatus.syncing));
      await tester.pump();
      expect(find.text('Syncing…'), findsOneWidget);
    });

    testWidgets('shows "Offline" when offline and syncing (offline wins)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(online: false, syncStatus: SyncStatus.syncing));
      await tester.pump();
      expect(find.textContaining('Offline'), findsOneWidget);
      expect(find.text('Syncing…'), findsNothing);
    });

    testWidgets('shows "Sync failed" banner when sync has errored',
        (tester) async {
      await tester.pumpWidget(
          _wrap(online: true, syncStatus: SyncStatus.error));
      await tester.pump();
      expect(find.textContaining('Sync failed'), findsOneWidget);
    });

    testWidgets('shows "Offline" when offline and error (offline wins)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(online: false, syncStatus: SyncStatus.error));
      await tester.pump();
      expect(find.textContaining('Offline'), findsOneWidget);
      expect(find.textContaining('Sync failed'), findsNothing);
    });

    testWidgets('offline banner has amber color', (tester) async {
      await tester.pumpWidget(
          _wrap(online: false, syncStatus: SyncStatus.idle));
      await tester.pump();
      final material = tester.widget<Material>(find.descendant(
          of: find.byType(OfflineBanner), matching: find.byType(Material)));
      expect(material.color, Colors.orange.shade700);
    });

    testWidgets('syncing banner has blue color', (tester) async {
      await tester.pumpWidget(
          _wrap(online: true, syncStatus: SyncStatus.syncing));
      await tester.pump();
      final material = tester.widget<Material>(find.descendant(
          of: find.byType(OfflineBanner), matching: find.byType(Material)));
      expect(material.color, const Color(0xFF1565C0));
    });

    testWidgets('error banner has red color', (tester) async {
      await tester.pumpWidget(
          _wrap(online: true, syncStatus: SyncStatus.error));
      await tester.pump();
      final material = tester.widget<Material>(find.descendant(
          of: find.byType(OfflineBanner), matching: find.byType(Material)));
      expect(material.color, Colors.red.shade700);
    });
  });
}

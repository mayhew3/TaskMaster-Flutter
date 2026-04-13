import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/sync_status_provider.dart';

/// Top-of-screen banner that reflects offline / syncing state.
///
/// - Nothing shown when online and idle.
/// - Muted-blue "Syncing…" banner when [SyncStatus.syncing].
/// - Red "Sync failed" banner when [SyncStatus.error].
/// - Amber "Offline" banner when connectivity is false.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final syncStatus = ref.watch(syncStatusControllerProvider);

    final online = connectivityAsync.valueOrNull ?? true;

    if (online && syncStatus == SyncStatus.idle) {
      return const SizedBox.shrink();
    }

    // Priority: offline > error > syncing. Error is shown even when online
    // so users can distinguish a sync failure from an in-progress sync.
    final (text, color) = switch ((online, syncStatus)) {
      (false, _) => (
          'Offline — changes will sync when reconnected',
          Colors.orange.shade700,
        ),
      (_, SyncStatus.error) => (
          'Sync failed — some changes will retry',
          Colors.red.shade700,
        ),
      (_, SyncStatus.syncing) => ('Syncing…', const Color(0xFF1565C0)),
      _ => ('Syncing…', const Color(0xFF1565C0)),
    };

    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/sync_status_provider.dart';

/// Top-of-screen banner that reflects offline / syncing state.
///
/// - Nothing shown when online and idle.
/// - Muted-blue "Syncing…" banner when [SyncStatus.syncing].
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

    final (text, color) = switch ((online, syncStatus)) {
      (_, SyncStatus.syncing) => ('Syncing…', const Color(0xFF1565C0)),
      (false, _) => ('Offline — changes will sync when reconnected', Colors.orange.shade700),
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

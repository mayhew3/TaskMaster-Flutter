import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_conflict_providers.dart';
import 'sync_conflicts_screen.dart';

/// TM-342: banner mounted above the home Scaffold body. Visible across all
/// tabs whenever any task or recurrence is in `pendingConflict`. Tapping
/// "Resolve" opens [SyncConflictsScreen] which lists conflicts and routes
/// each to a per-conflict dialog. Returns [SizedBox.shrink] when the count
/// is zero so it consumes no vertical space.
class SyncConflictBanner extends ConsumerWidget {
  const SyncConflictBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(allConflictsCountProvider);
    if (count == 0) return const SizedBox.shrink();

    return Material(
      color: Colors.orange.shade800,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 sync conflict needs your attention.'
                      : '$count sync conflicts need your attention.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SyncConflictsScreen(),
                    ),
                  );
                },
                child: const Text('Resolve'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

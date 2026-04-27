import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sync_conflict_providers.dart';
import 'sync_conflict_detail_dialog.dart';

/// TM-342: list of all currently pending sync conflicts (tasks + recurrences).
/// Tapping a row opens [SyncConflictDetailDialog] for resolution.
///
/// Renders distinct loading / error / data states for each underlying stream
/// rather than treating "not yet loaded" as empty (which would briefly
/// mislead the user into thinking the banner had nothing to show). When
/// rows exist whose `conflictRemoteJson` envelope can't be decoded, surfaces
/// a "stuck" recovery section with a force-clear action — without this, the
/// user would have no way to exit `pendingConflict` for those rows.
class SyncConflictsScreen extends ConsumerWidget {
  const SyncConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskConflictsAsync = ref.watch(taskConflictsProvider);
    final recurrenceConflictsAsync = ref.watch(recurrenceConflictsProvider);
    final stuckCount = ref.watch(stuckConflictsCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Conflicts')),
      body: _buildBody(
        context,
        ref,
        taskConflictsAsync: taskConflictsAsync,
        recurrenceConflictsAsync: recurrenceConflictsAsync,
        stuckCount: stuckCount,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<List<TaskConflict>> taskConflictsAsync,
    required AsyncValue<List<RecurrenceConflict>> recurrenceConflictsAsync,
    required int stuckCount,
  }) {
    // While either stream is still loading, show a spinner. Treating "not
    // yet emitted" as empty is what Copilot flagged in round 4.
    if (taskConflictsAsync.isLoading || recurrenceConflictsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskConflictsAsync.hasError || recurrenceConflictsAsync.hasError) {
      final error =
          taskConflictsAsync.error ?? recurrenceConflictsAsync.error;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Failed to load conflicts: $error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      );
    }

    final taskConflicts = taskConflictsAsync.value ?? const [];
    final recurrenceConflicts = recurrenceConflictsAsync.value ?? const [];

    if (taskConflicts.isEmpty &&
        recurrenceConflicts.isEmpty &&
        stuckCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No sync conflicts. Looks like everything is in sync.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      children: [
        if (taskConflicts.isNotEmpty) ...[
          const _SectionHeader(label: 'Tasks'),
          ...taskConflicts.map(
            (c) => _ConflictTile(
              title: c.local.name,
              subtitle: _summarizeTaskDelta(c),
              isDelete: c.priorSyncState == 'pendingDelete',
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => SyncConflictDetailDialog.task(conflict: c),
              ),
            ),
          ),
        ],
        if (recurrenceConflicts.isNotEmpty) ...[
          const _SectionHeader(label: 'Recurrences'),
          ...recurrenceConflicts.map(
            (c) => _ConflictTile(
              title: c.local.name,
              subtitle: _summarizeRecurrenceDelta(c),
              isDelete: c.priorSyncState == 'pendingDelete',
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    SyncConflictDetailDialog.recurrence(conflict: c),
              ),
            ),
          ),
        ],
        if (stuckCount > 0) _StuckConflictsCard(stuckCount: stuckCount),
      ],
    );
  }

  static String _summarizeTaskDelta(TaskConflict c) {
    if (c.priorSyncState == 'pendingDelete') {
      return 'You deleted this; another device modified it.';
    }
    final remoteAt = c.remote.lastModified;
    return 'Modified by another device${remoteAt == null ? '' : ' at ${DateFormat.yMd().add_jm().format(remoteAt.toLocal())}'}';
  }

  static String _summarizeRecurrenceDelta(RecurrenceConflict c) {
    if (c.priorSyncState == 'pendingDelete') {
      return 'You deleted this recurrence; another device modified it.';
    }
    final remoteAt = c.remote.lastModified;
    return 'Modified by another device${remoteAt == null ? '' : ' at ${DateFormat.yMd().add_jm().format(remoteAt.toLocal())}'}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
      ),
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.title,
    required this.subtitle,
    required this.isDelete,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isDelete ? Icons.delete_outline : Icons.merge_type,
        color: Colors.orange.shade800,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// TM-342: Recovery card shown when one or more pendingConflict rows have
/// undecodable `conflictRemoteJson` envelopes. Without this, those rows are
/// invisible to the dialog flow and the user has no way to clear them.
class _StuckConflictsCard extends ConsumerWidget {
  const _StuckConflictsCard({required this.stuckCount});

  final int stuckCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Text(
                  stuckCount == 1
                      ? '1 stuck conflict'
                      : '$stuckCount stuck conflicts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Some conflict details could not be loaded (likely from an '
              'older app version). Force-clearing keeps your local edits and '
              'tries to push again on the next sync.',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _forceClear(context, ref),
                child: const Text('Force clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _forceClear(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(forceClearStuckConflictsProvider.notifier).call();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Force-cleared stuck conflicts.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear: $e')),
      );
    }
  }
}

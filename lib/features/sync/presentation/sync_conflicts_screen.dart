import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sync_conflict_providers.dart';
import 'sync_conflict_detail_dialog.dart';

/// TM-342: list of all currently pending sync conflicts (tasks + recurrences).
/// Tapping a row opens [SyncConflictDetailDialog] for resolution.
class SyncConflictsScreen extends ConsumerWidget {
  const SyncConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskConflicts =
        ref.watch(taskConflictsProvider).valueOrNull ?? const [];
    final recurrenceConflicts =
        ref.watch(recurrenceConflictsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Conflicts')),
      body: (taskConflicts.isEmpty && recurrenceConflicts.isEmpty)
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No sync conflicts. Looks like everything is in sync.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
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
                        builder: (_) =>
                            SyncConflictDetailDialog.task(conflict: c),
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
              ],
            ),
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

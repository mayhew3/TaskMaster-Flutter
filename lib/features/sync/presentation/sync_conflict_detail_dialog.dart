import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/sync_conflict_providers.dart';

/// TM-342: per-conflict modal showing the local pending edit alongside the
/// remote version. Buttons: **Keep mine** (force-push local), **Use latest**
/// (overwrite local with remote), **Cancel** (defer — banner stays up).
///
/// One dialog handles both task and recurrence conflicts via the named
/// constructors [SyncConflictDetailDialog.task] and
/// [SyncConflictDetailDialog.recurrence]; internally they render different
/// field rows.
class SyncConflictDetailDialog extends ConsumerWidget {
  const SyncConflictDetailDialog._({
    required this.title,
    required this.priorSyncState,
    required this.fieldRows,
    required this.onKeepMine,
    required this.onUseLatest,
  });

  factory SyncConflictDetailDialog.task({required TaskConflict conflict}) {
    final rows = <_FieldComparison>[
      _FieldComparison('Name', conflict.local.name, conflict.remote.name),
      _FieldComparison('Description', conflict.local.description ?? '—',
          conflict.remote.description ?? '—'),
      _FieldComparison('Project', conflict.local.project ?? '—',
          conflict.remote.project ?? '—'),
      _FieldComparison('Context', conflict.local.context ?? '—',
          conflict.remote.context ?? '—'),
      _FieldComparison(
          'Start',
          _fmtDate(conflict.local.startDate),
          _fmtDate(conflict.remote.startDate)),
      _FieldComparison(
          'Target',
          _fmtDate(conflict.local.targetDate),
          _fmtDate(conflict.remote.targetDate)),
      _FieldComparison(
          'Due',
          _fmtDate(conflict.local.dueDate),
          _fmtDate(conflict.remote.dueDate)),
      _FieldComparison(
          'Urgent',
          _fmtDate(conflict.local.urgentDate),
          _fmtDate(conflict.remote.urgentDate)),
    ];

    return SyncConflictDetailDialog._(
      title: conflict.priorSyncState == 'pendingDelete'
          ? 'Delete vs. Update'
          : 'Task Conflict',
      priorSyncState: conflict.priorSyncState,
      fieldRows: rows,
      onKeepMine: (ref) =>
          ref.read(keepLocalConflictProvider.notifier).callTask(conflict),
      onUseLatest: (ref) =>
          ref.read(acceptRemoteConflictProvider.notifier).callTask(conflict),
    );
  }

  factory SyncConflictDetailDialog.recurrence(
      {required RecurrenceConflict conflict}) {
    final rows = <_FieldComparison>[
      _FieldComparison('Name', conflict.local.name, conflict.remote.name),
      _FieldComparison(
          'Recur every',
          '${conflict.local.recurNumber} ${conflict.local.recurUnit}',
          '${conflict.remote.recurNumber} ${conflict.remote.recurUnit}'),
      _FieldComparison(
          'Wait until complete',
          conflict.local.recurWait ? 'Yes' : 'No',
          conflict.remote.recurWait ? 'Yes' : 'No'),
      _FieldComparison(
          'Iteration',
          conflict.local.recurIteration.toString(),
          conflict.remote.recurIteration.toString()),
    ];

    return SyncConflictDetailDialog._(
      title: conflict.priorSyncState == 'pendingDelete'
          ? 'Delete vs. Update (Recurrence)'
          : 'Recurrence Conflict',
      priorSyncState: conflict.priorSyncState,
      fieldRows: rows,
      onKeepMine: (ref) => ref
          .read(keepLocalConflictProvider.notifier)
          .callRecurrence(conflict),
      onUseLatest: (ref) => ref
          .read(acceptRemoteConflictProvider.notifier)
          .callRecurrence(conflict),
    );
  }

  final String title;
  final String priorSyncState;
  final List<_FieldComparison> fieldRows;
  final Future<void> Function(WidgetRef ref) onKeepMine;
  final Future<void> Function(WidgetRef ref) onUseLatest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDelete = priorSyncState == 'pendingDelete';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDelete)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'You deleted this; another device modified it after.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              const _Header(),
              const Divider(height: 1),
              ...fieldRows.map((r) => r.build(context)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _resolve(context, ref, useLatest: false),
          child: Text(isDelete ? 'Keep delete' : 'Keep mine'),
        ),
        ElevatedButton(
          onPressed: () => _resolve(context, ref, useLatest: true),
          child: const Text('Use latest'),
        ),
      ],
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref,
      {required bool useLatest}) async {
    try {
      if (useLatest) {
        await onUseLatest(ref);
      } else {
        await onKeepMine(ref);
      }
      // The user could have dismissed the dialog (back gesture / tap-outside)
      // while the resolution was running. Calling Navigator.pop() blindly
      // would pop the underlying route in that case.
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Failed to resolve: $e')),
      );
    }
  }

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat.yMd().add_jm().format(dt.toLocal());
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 100),
          Expanded(child: Text('Mine', style: style)),
          Expanded(child: Text('Latest', style: style)),
        ],
      ),
    );
  }
}

class _FieldComparison {
  _FieldComparison(this.label, this.local, this.remote);

  final String label;
  final String local;
  final String remote;

  Widget build(BuildContext context) {
    final differs = local != remote;
    final highlight = differs ? Colors.orange.shade50 : null;
    return Container(
      color: highlight,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              local,
              style: differs
                  ? const TextStyle(fontWeight: FontWeight.w500)
                  : null,
            ),
          ),
          Expanded(
            child: Text(
              remote,
              style: differs
                  ? const TextStyle(fontWeight: FontWeight.w500)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

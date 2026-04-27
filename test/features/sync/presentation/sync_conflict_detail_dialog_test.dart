import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/sync/presentation/sync_conflict_detail_dialog.dart';
import 'package:taskmaster/features/sync/providers/sync_conflict_providers.dart';
import 'package:taskmaster/models/task_item.dart';

TaskItem _task({required String name, String? description}) {
  return TaskItem((b) => b
    ..docId = 'doc-1'
    ..dateAdded = DateTime.utc(2024, 1, 1)
    ..personDocId = 'p1'
    ..name = name
    ..description = description
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false);
}

void main() {
  Widget _harness(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: Scaffold(body: Builder(builder: (ctx) => child))),
    );
  }

  testWidgets('renders both versions side by side', (tester) async {
    final conflict = TaskConflict(
      local: _task(name: 'Mine', description: 'Local description'),
      remote: _task(name: 'Theirs', description: 'Remote description'),
      priorSyncState: 'pendingUpdate',
    );

    await tester.pumpWidget(_harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                SyncConflictDetailDialog.task(conflict: conflict),
          ),
          child: const Text('Open'),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Mine'), findsWidgets,
        reason: 'header column "Mine" plus the Name field value');
    expect(find.text('Theirs'), findsOneWidget);
    expect(find.text('Local description'), findsOneWidget);
    expect(find.text('Remote description'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Keep mine'), findsOneWidget);
    expect(find.text('Use latest'), findsOneWidget);
  });

  testWidgets('delete-vs-edit conflict shows different title and button',
      (tester) async {
    final conflict = TaskConflict(
      local: _task(name: 'Local'),
      remote: _task(name: 'Remote'),
      priorSyncState: 'pendingDelete',
    );

    await tester.pumpWidget(_harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                SyncConflictDetailDialog.task(conflict: conflict),
          ),
          child: const Text('Open'),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete vs. Update'), findsOneWidget);
    expect(find.text('Keep delete'), findsOneWidget,
        reason:
            'pendingDelete renders the keep-mine button as "Keep delete" so '
            'the user knows what they are committing to');
    expect(find.text('Keep mine'), findsNothing);
  });

  testWidgets('Cancel closes the dialog without resolving', (tester) async {
    final conflict = TaskConflict(
      local: _task(name: 'Local'),
      remote: _task(name: 'Remote'),
      priorSyncState: 'pendingUpdate',
    );

    await tester.pumpWidget(_harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                SyncConflictDetailDialog.task(conflict: conflict),
          ),
          child: const Text('Open'),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsNothing,
        reason: 'dialog should be closed after tapping Cancel');
  });
}

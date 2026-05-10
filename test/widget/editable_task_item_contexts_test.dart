import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/contexts/providers/context_providers.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/context_icon.dart';
import 'package:taskmaestro/models/context.dart';
import 'package:taskmaestro/models/task_context.dart';
import 'package:taskmaestro/models/task_item.dart';

/// Tests for the task-list card meta-row context icon cluster (TM-181).
///
/// The cluster renders icons-only (no text) between the area badge and the
/// time/priority/points block. Resolution of `iconName` happens at render
/// time off `contextsProvider`, so the test stubs that provider with a
/// known catalog list.

Context _ctx({required String name, String? iconName}) {
  return Context((b) => b
    ..docId = 'cat-$name'
    ..dateAdded = DateTime.utc(2026, 1, 1)
    ..name = name
    ..sortOrder = 0
    ..iconName = iconName
    ..personDocId = 'me');
}

TaskItem _taskWith(List<TaskContext> contexts) {
  return TaskItem((b) => b
    ..docId = 'tic-1'
    ..dateAdded = DateTime.now().toUtc()
    ..personDocId = 'me'
    ..name = 'Sample'
    ..area = 'Work'
    ..offCycle = false
    ..skipped = false
    ..pendingCompletion = false
    ..contexts = ListBuilder<TaskContext>(contexts));
}

Widget _wrap({
  required TaskItem task,
  required List<Context> catalog,
}) {
  return ProviderScope(
    overrides: [
      areaColorsProvider.overrideWith((ref) => const <String, Color>{}),
      contextsProvider.overrideWith((ref) => Stream.value(catalog)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: EditableTaskItemWidget(
            taskItem: task,
            highlightSprint: false,
            onTaskCompleteToggle: (_) => null,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Card meta row context icons', () {
    testWidgets('renders ContextIcon for each catalog-matched context',
        (tester) async {
      final catalog = [
        _ctx(name: 'Phone', iconName: 'phone'),
        _ctx(name: 'Computer', iconName: 'computer'),
      ];
      final task = _taskWith([
        TaskContext.named('Phone'),
        TaskContext.named('Computer'),
      ]);
      await tester.pumpWidget(_wrap(task: task, catalog: catalog));
      await tester.pumpAndSettle();
      // Both contexts have catalog matches with iconName set → 2 icons.
      expect(find.byType(ContextIcon), findsNWidgets(2));
    });

    testWidgets('renders no ContextIcon when contexts is empty',
        (tester) async {
      final task = _taskWith(const []);
      await tester.pumpWidget(_wrap(task: task, catalog: const []));
      await tester.pumpAndSettle();
      expect(find.byType(ContextIcon), findsNothing);
    });

    testWidgets('skips contexts whose catalog row has no iconName',
        (tester) async {
      final catalog = [
        _ctx(name: 'Phone', iconName: 'phone'),
        // User-created context without an icon assigned (Tier 1 default).
        _ctx(name: 'Custom', iconName: null),
      ];
      final task = _taskWith([
        TaskContext.named('Phone'),
        TaskContext.named('Custom'),
      ]);
      await tester.pumpWidget(_wrap(task: task, catalog: catalog));
      await tester.pumpAndSettle();
      // Only Phone has an icon → 1 ContextIcon.
      expect(find.byType(ContextIcon), findsOneWidget);
    });

    testWidgets('skips contexts whose name is not in the catalog',
        (tester) async {
      final catalog = [
        _ctx(name: 'Phone', iconName: 'phone'),
      ];
      final task = _taskWith([
        TaskContext.named('Phone'),
        // Bare name not in catalog (e.g. legacy migration value, or
        // a context that was deleted from the catalog).
        TaskContext.named('GhostContext'),
      ]);
      await tester.pumpWidget(_wrap(task: task, catalog: catalog));
      await tester.pumpAndSettle();
      expect(find.byType(ContextIcon), findsOneWidget);
    });
  });
}

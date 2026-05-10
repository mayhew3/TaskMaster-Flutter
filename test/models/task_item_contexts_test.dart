import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/models/task_context.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_item_blueprint.dart';

/// Tests for `TaskItem.contexts` schema migration (TM-181).
///
/// Covers:
/// 1. blueprint round-trip (createBlueprint → mutate → diff)
/// 2. hasChanges / hasChangesBlueprint detect context-list edits
/// 3. legacy bare-string Firestore JSON (`context: "Phone"`) reads as a
///    single-element contexts list via `applyLegacyContextFallback`
/// 4. New default is empty list (not null)

TaskItem _bareTask({
  String docId = 't-1',
  List<TaskContext> contexts = const [],
}) {
  return TaskItem((b) => b
    ..docId = docId
    ..dateAdded = DateTime.now().toUtc()
    ..personDocId = 'me'
    ..name = 'Sample'
    ..offCycle = false
    ..skipped = false
    ..contexts.replace(contexts));
}

void main() {
  group('TaskItem.contexts default', () {
    test('a fresh TaskItem has an empty contexts list (not null)', () {
      final task = _bareTask();
      expect(task.contexts, isEmpty);
    });
  });

  group('createBlueprint round-trip', () {
    test('blueprint.contexts mirrors the source TaskItem list', () {
      final task = _bareTask(contexts: [
        TaskContext.named('Phone'),
        TaskContext((b) => b
          ..name = 'Computer'
          ..value = 30),
      ]);
      final bp = task.createBlueprint();
      expect(bp.contexts, hasLength(2));
      expect(bp.contexts[0].name, 'Phone');
      expect(bp.contexts[1].name, 'Computer');
      expect(bp.contexts[1].value, 30);
    });
  });

  group('hasChanges detection', () {
    test('add → returns true', () {
      final task = _bareTask(contexts: [TaskContext.named('Phone')]);
      final bp = task.createBlueprint()
        ..contexts = [
          TaskContext.named('Phone'),
          TaskContext.named('Computer'),
        ];
      expect(task.hasChangesBlueprint(bp), isTrue);
    });

    test('remove → returns true', () {
      final task = _bareTask(contexts: [
        TaskContext.named('Phone'),
        TaskContext.named('Computer'),
      ]);
      final bp = task.createBlueprint()
        ..contexts = [TaskContext.named('Phone')];
      expect(task.hasChangesBlueprint(bp), isTrue);
    });

    test('reorder → returns true (order-sensitive)', () {
      final task = _bareTask(contexts: [
        TaskContext.named('Phone'),
        TaskContext.named('Computer'),
      ]);
      final bp = task.createBlueprint()
        ..contexts = [
          TaskContext.named('Computer'),
          TaskContext.named('Phone'),
        ];
      expect(task.hasChangesBlueprint(bp), isTrue);
    });

    test('identical contents → returns false', () {
      final task = _bareTask(contexts: [TaskContext.named('Phone')]);
      final bp = task.createBlueprint();
      expect(task.hasChangesBlueprint(bp), isFalse);
    });

    test('value diff (same name, different value) → returns true', () {
      final task = _bareTask(contexts: [
        TaskContext((b) => b
          ..name = 'Phone'
          ..value = 5),
      ]);
      final bp = task.createBlueprint()
        ..contexts = [
          TaskContext((b) => b
            ..name = 'Phone'
            ..value = 6),
        ];
      expect(task.hasChangesBlueprint(bp), isTrue);
    });
  });

  group('blueprint.hasChanges (against TaskItem)', () {
    test('detects an added context', () {
      final task = _bareTask(contexts: [TaskContext.named('Phone')]);
      final bp = TaskItemBlueprint()
        ..name = task.name
        ..personDocId = task.personDocId
        ..offCycle = false
        ..contexts = [
          TaskContext.named('Phone'),
          TaskContext.named('Email'),
        ];
      expect(bp.hasChanges(task), isTrue);
    });
  });

  group('legacy Firestore bare-string fallback', () {
    test('JSON with `context: "Phone"` deserializes as single-element list',
        () {
      // applyLegacyContextFallback mutates the map in place; mirror what
      // sync_service does on every Firestore snapshot read.
      final json = <String, dynamic>{
        'docId': 'legacy-1',
        'dateAdded': DateTime.now().toUtc(),
        'personDocId': 'me',
        'name': 'Legacy',
        'context': 'Phone',
        'offCycle': false,
        'skipped': false,
        'priorityScaleVersion': 1,
        'pendingCompletion': false,
      };
      TaskItem.applyLegacyContextFallback(json);
      expect(json.containsKey('context'), isFalse);
      expect(json['contexts'], isA<List<Object?>>());
      final list = json['contexts'] as List;
      expect(list, hasLength(1));
      expect((list.first as Map)['name'], 'Phone');
    });

    test('null/empty legacy string yields no contexts list', () {
      final json = <String, dynamic>{
        'context': null,
      };
      TaskItem.applyLegacyContextFallback(json);
      // Null legacy → key removed, no contexts injected.
      expect(json.containsKey('context'), isFalse);
      expect(json.containsKey('contexts'), isFalse);
    });

    test('skip legacy when contexts already present', () {
      final json = <String, dynamic>{
        'context': 'Phone', // stale residue
        'contexts': [
          {'name': 'Email'},
        ],
      };
      TaskItem.applyLegacyContextFallback(json);
      expect(json.containsKey('context'), isFalse);
      // contexts is preserved as-is — the new shape wins.
      expect((json['contexts'] as List), hasLength(1));
      expect(((json['contexts'] as List).first as Map)['name'], 'Email');
    });
  });
}

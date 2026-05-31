import 'package:built_collection/built_collection.dart';
import 'package:taskmaestro/features/sprints/logic/plan_preview_generation.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';
import 'package:taskmaestro/models/task_recurrence.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_data_builder.dart';
import '../../../mocks/mock_recurrence_builder.dart';

/// TM-388 — pure preview-generation helper. The picker and the sidebar
/// facet count both call this so the displayed previews and the tallied
/// previews can't drift. These tests pin the helper's contracts directly
/// (the in-widget pre-TM-388 recursion was covered by
/// `recurrence_iteration_safety_test.dart`; this file covers the lifted
/// helper that subsumed it, including the orchestration branches the
/// prior file couldn't reach because it re-implemented just the
/// recursion locally).
void main() {
  MockTaskItemBuilder dailyBuilder() {
    final builder = MockTaskItemBuilder.withDates()
      ..withDueDateAnchor()
      ..recurNumber = 1
      ..recurUnit = 'Days'
      ..recurWait = false
      ..recurIteration = 1
      ..recurrenceDocId = MockTaskItemBuilder.me;
    builder.taskRecurrence = _dailyRecurrenceFor(builder);
    return builder;
  }

  group('generatePlanPreviews', () {
    test('happy path: a recurring source produces in-window previews', () {
      final source = dailyBuilder().create();
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));

      final previews = generatePlanPreviews(
        allTasks: BuiltList<TaskItem>([source]),
        activeSprint: null,
        endDate: endDate,
        allRecurrences: const [],
        now: DateTime.now(),
      );

      // Daily recurrence over 14 days → some previews (exact count
      // depends on date-offset math from the source's anchor).
      expect(previews, isNotEmpty);
      expect(previews.length, lessThan(20));
    });

    test('recurWait == true → no previews generated for that source', () {
      final builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = true
        ..recurIteration = 1
        ..recurrenceDocId = MockTaskItemBuilder.me;
      builder.taskRecurrence = _dailyRecurrenceFor(builder)..recurWait = true;
      final source = builder.create();
      final endDate = DateTime.now().toUtc().add(const Duration(days: 30));

      final previews = generatePlanPreviews(
        allTasks: BuiltList<TaskItem>([source]),
        activeSprint: null,
        endDate: endDate,
        allRecurrences: const [],
        now: DateTime.now(),
      );

      expect(previews, isEmpty);
    });

    test(
        'recurrence not found in allRecurrences AND source has no inline '
        'recurrence → skipped', () {
      // Source has recurrenceDocId pointing at a doc that doesn't exist
      // anywhere; helper should `continue` past it without crashing.
      final builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceDocId = 'missing-rec';
      // intentionally do NOT set taskRecurrence
      final source = builder.create();
      final endDate = DateTime.now().toUtc().add(const Duration(days: 30));

      final previews = generatePlanPreviews(
        allTasks: BuiltList<TaskItem>([source]),
        activeSprint: null,
        endDate: endDate,
        allRecurrences: const <TaskRecurrence>[],
        now: DateTime.now(),
      );

      expect(previews, isEmpty);
    });

    test(
        'depth cap: a daily recurrence with a far-future end date returns '
        'exactly 365 previews', () {
      final source = dailyBuilder().create();
      // 3-year window would generate ~1095 daily iterations without the cap.
      final endDate = DateTime.now().toUtc().add(const Duration(days: 1095));

      final previews = generatePlanPreviews(
        allTasks: BuiltList<TaskItem>([source]),
        activeSprint: null,
        endDate: endDate,
        allRecurrences: const [],
        now: DateTime.now(),
      );

      expect(previews.length, equals(365));
    });

    test(
        'defensive: a task with recurrenceDocId but null recurIteration is '
        'skipped, not crashed-on (TM-388 R2)', () {
      // Construct a corrupt-shaped TaskItem directly — the builder
      // would set recurIteration alongside recurrenceDocId, so bypass
      // it. This is the data-integrity-violation path the R2 reviewer
      // flagged: a single bad task previously force-unwrapped through
      // recurIteration! during the sort and would have thrown,
      // breaking the whole plan-mode sidebar tally.
      final corrupt = TaskItem((b) => b
        ..docId = 'corrupt'
        ..name = 'Corrupt Task'
        ..personDocId = 'p'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc()
        ..dueDate = DateTime.now().toUtc().add(const Duration(days: 2))
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurrenceDocId = 'rec-corrupt'
        ..recurIteration = null);
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));

      // Must not throw; corrupt source produces no previews.
      final previews = generatePlanPreviews(
        allTasks: BuiltList<TaskItem>([corrupt]),
        activeSprint: null,
        endDate: endDate,
        allRecurrences: const [],
        now: DateTime.now(),
      );

      expect(previews, isEmpty);
    });
  });

  group('previewShouldPreselect', () {
    test('true when preview is due before endDate', () {
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));
      final preview = TaskItemRecurPreview('p')
        ..dueDate = endDate.subtract(const Duration(days: 1));
      expect(previewShouldPreselect(preview, endDate), isTrue);
    });

    test('true when preview is urgent before endDate', () {
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));
      final preview = TaskItemRecurPreview('p')
        ..urgentDate = endDate.subtract(const Duration(days: 1));
      expect(previewShouldPreselect(preview, endDate), isTrue);
    });

    test(
        'false when preview is only target-before / scheduled-before '
        '(not urgent/due)', () {
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));
      final preview = TaskItemRecurPreview('p')
        ..targetDate = endDate.subtract(const Duration(days: 1))
        ..startDate = endDate.subtract(const Duration(days: 2));
      expect(previewShouldPreselect(preview, endDate), isFalse);
    });

    test('false when preview has no date fields before endDate', () {
      final endDate = DateTime.now().toUtc().add(const Duration(days: 14));
      final preview = TaskItemRecurPreview('p');
      expect(previewShouldPreselect(preview, endDate), isFalse);
    });
  });
}

// Local mirror of the helper in recurrence_iteration_safety_test.dart —
// kept private here so the tests don't pull a cross-test import.
MockTaskRecurrenceBuilder _dailyRecurrenceFor(MockTaskItemBuilder builder) {
  final anchorDate = builder.getAnchorDate()!;
  return MockTaskRecurrenceBuilder()
    ..docId = MockTaskItemBuilder.me
    ..name = builder.name
    ..recurNumber = 1
    ..recurUnit = 'Days'
    ..recurWait = false
    ..recurIteration = 1
    ..anchorDate = anchorDate;
}

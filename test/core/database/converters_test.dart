import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/converters.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';

void main() {
  final now = DateTime(2025, 6, 15, 12, 0, 0, 0, 0);
  const personDocId = 'person-1';

  group('TaskItem ↔ Drift row', () {
    TaskItem _makeTask({
      String docId = 'task-1',
      String name = 'Test task',
    }) {
      return TaskItem((b) => b
        ..docId = docId
        ..dateAdded = now
        ..personDocId = personDocId
        ..name = name
        ..offCycle = false);
    }

    test('taskItemToCompanion preserves all fields', () {
      final task = _makeTask();
      final companion = taskItemToCompanion(task);
      expect(companion.docId.value, 'task-1');
      expect(companion.name.value, 'Test task');
      expect(companion.personDocId.value, personDocId);
    });

    test('taskBlueprintToCompanion maps blueprint fields', () {
      final blueprint = TaskItemBlueprint()
        ..name = 'Blueprint task'
        ..urgency = 3
        ..priority = 5
        ..startDate = now;

      final companion = taskBlueprintToCompanion(
        docId: 'bp-1',
        personDocId: personDocId,
        dateAdded: now,
        blueprint: blueprint,
      );

      expect(companion.docId.value, 'bp-1');
      expect(companion.name.value, 'Blueprint task');
      expect(companion.urgency.value, 3);
      expect(companion.priority.value, 5);
      expect(companion.startDate.value, now);
    });

    test('taskBlueprintToDiff sets mutable fields', () {
      final blueprint = TaskItemBlueprint()
        ..name = 'Updated'
        ..completionDate = now;

      final diff = taskBlueprintToDiff(blueprint);
      expect(diff.name.value, 'Updated');
      expect(diff.completionDate.value, now);
      // Identity fields should be absent.
      expect(diff.docId.present, isFalse);
      expect(diff.dateAdded.present, isFalse);
    });
  });

  group('TaskRecurrence ↔ Drift row', () {
    AnchorDate _makeAnchorDate() {
      return AnchorDate((b) => b
        ..dateValue = now
        ..dateType = TaskDateTypes.start);
    }

    TaskRecurrence _makeRecurrence() {
      return TaskRecurrence((b) => b
        ..docId = 'rec-1'
        ..dateAdded = now
        ..personDocId = personDocId
        ..name = 'Daily'
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = _makeAnchorDate().toBuilder());
    }

    test('taskRecurrenceToCompanion → taskRecurrenceFromRow round-trip', () {
      final recurrence = _makeRecurrence();
      final companion = taskRecurrenceToCompanion(recurrence);

      expect(companion.docId.value, 'rec-1');
      expect(companion.recurUnit.value, 'Days');
      expect(companion.anchorDateJson.present, isTrue);

      // Verify the JSON round-trips correctly via recurrenceBlueprintToCompanion.
      final blueprint = TaskRecurrenceBlueprint()
        ..name = 'Weekly'
        ..recurNumber = 1
        ..recurUnit = 'Weeks'
        ..recurWait = false
        ..recurIteration = 2
        ..anchorDate = _makeAnchorDate();

      final bpCompanion = recurrenceBlueprintToCompanion(
        docId: 'rec-2',
        personDocId: personDocId,
        dateAdded: now,
        blueprint: blueprint,
      );
      expect(bpCompanion.docId.value, 'rec-2');
      expect(bpCompanion.recurUnit.value, 'Weeks');
      expect(bpCompanion.recurIteration.value, 2);
    });

    test('anchorDate JSON round-trips through companion', () {
      final recurrence = _makeRecurrence();
      final companion = taskRecurrenceToCompanion(recurrence);
      // JSON must contain expected keys.
      final json = companion.anchorDateJson.value;
      expect(json, contains('"dateValue"'));
      expect(json, contains('"dateType"'));
      expect(json, contains('"Start"'));
    });

    test('recurrenceBlueprintToDiff only sets present fields', () {
      final blueprint = TaskRecurrenceBlueprint()..recurIteration = 5;
      final diff = recurrenceBlueprintToDiff(blueprint);
      expect(diff.recurIteration.value, 5);
      // Fields not set on blueprint should be absent.
      expect(diff.name.present, isFalse);
      expect(diff.recurUnit.present, isFalse);
    });
  });

  group('Sprint ↔ Drift row', () {
    test('sprintAssignmentToCompanion round-trip', () {
      final sa = SprintAssignment((b) => b
        ..docId = 'sa-1'
        ..taskDocId = 'task-1'
        ..sprintDocId = 'sprint-1');
      final companion = sprintAssignmentToCompanion(sa);
      expect(companion.docId.value, 'sa-1');
      expect(companion.taskDocId.value, 'task-1');
      expect(companion.sprintDocId.value, 'sprint-1');
    });

    test('sprintToCompanion preserves all top-level fields', () {
      final sprint = Sprint((b) => b
        ..docId = 'sprint-1'
        ..dateAdded = now
        ..startDate = now
        ..endDate = now.add(const Duration(days: 7))
        ..numUnits = 5
        ..unitName = 'Points'
        ..personDocId = personDocId
        ..sprintNumber = 3);
      final companion = sprintToCompanion(sprint);
      expect(companion.docId.value, 'sprint-1');
      expect(companion.sprintNumber.value, 3);
      expect(companion.numUnits.value, 5);
    });
  });
}

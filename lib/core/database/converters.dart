import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart';

import '../../models/anchor_date.dart' as m;
import '../../models/sprint.dart' as m;
import '../../models/sprint_assignment.dart' as m;
import '../../models/task_date_type.dart';
import '../../models/task_item.dart' as m;
import '../../models/task_recurrence.dart' as m;
import 'app_database.dart';

/// Bidirectional converters between Drift row structs and built_value models.
/// Single source of truth for field mapping between local SQLite and the
/// in-memory domain model. The `syncState` column is intentionally not exposed
/// here — DAOs manage it.

// ── Task ─────────────────────────────────────────────────────────────────────

m.TaskItem taskItemFromRow(Task row) {
  return m.TaskItem((b) => b
    ..docId = row.docId
    ..dateAdded = row.dateAdded
    ..personDocId = row.personDocId
    ..name = row.name
    ..description = row.description
    ..project = row.project
    ..context = row.taskContext
    ..urgency = row.urgency
    ..priority = row.priority
    ..duration = row.duration
    ..gamePoints = row.gamePoints
    ..startDate = row.startDate
    ..targetDate = row.targetDate
    ..dueDate = row.dueDate
    ..urgentDate = row.urgentDate
    ..completionDate = row.completionDate
    ..recurNumber = row.recurNumber
    ..recurUnit = row.recurUnit
    ..recurWait = row.recurWait
    ..recurrenceDocId = row.recurrenceDocId
    ..recurIteration = row.recurIteration
    ..retired = row.retired
    ..retiredDate = row.retiredDate
    ..offCycle = row.offCycle);
}

TasksCompanion taskItemToCompanion(m.TaskItem task) {
  return TasksCompanion(
    docId: Value(task.docId),
    dateAdded: Value(task.dateAdded),
    personDocId: Value(task.personDocId),
    name: Value(task.name),
    description: Value(task.description),
    project: Value(task.project),
    taskContext: Value(task.context),
    urgency: Value(task.urgency),
    priority: Value(task.priority),
    duration: Value(task.duration),
    gamePoints: Value(task.gamePoints),
    startDate: Value(task.startDate),
    targetDate: Value(task.targetDate),
    dueDate: Value(task.dueDate),
    urgentDate: Value(task.urgentDate),
    completionDate: Value(task.completionDate),
    recurNumber: Value(task.recurNumber),
    recurUnit: Value(task.recurUnit),
    recurWait: Value(task.recurWait),
    recurrenceDocId: Value(task.recurrenceDocId),
    recurIteration: Value(task.recurIteration),
    retired: Value(task.retired),
    retiredDate: Value(task.retiredDate),
    offCycle: Value(task.offCycle),
  );
}

// ── TaskRecurrence ───────────────────────────────────────────────────────────

m.TaskRecurrence taskRecurrenceFromRow(TaskRecurrence row) {
  return m.TaskRecurrence((b) => b
    ..docId = row.docId
    ..dateAdded = row.dateAdded
    ..personDocId = row.personDocId
    ..name = row.name
    ..recurNumber = row.recurNumber
    ..recurUnit = row.recurUnit
    ..recurWait = row.recurWait
    ..recurIteration = row.recurIteration
    ..anchorDate = _anchorDateFromJson(row.anchorDateJson).toBuilder());
}

TaskRecurrencesCompanion taskRecurrenceToCompanion(m.TaskRecurrence recurrence) {
  return TaskRecurrencesCompanion(
    docId: Value(recurrence.docId),
    dateAdded: Value(recurrence.dateAdded),
    personDocId: Value(recurrence.personDocId),
    name: Value(recurrence.name),
    recurNumber: Value(recurrence.recurNumber),
    recurUnit: Value(recurrence.recurUnit),
    recurWait: Value(recurrence.recurWait),
    recurIteration: Value(recurrence.recurIteration),
    anchorDateJson: Value(_anchorDateToJson(recurrence.anchorDate)),
  );
}

String _anchorDateToJson(m.AnchorDate anchorDate) {
  return jsonEncode({
    'dateValue': anchorDate.dateValue.toIso8601String(),
    'dateType': anchorDate.dateType.label,
  });
}

m.AnchorDate _anchorDateFromJson(String json) {
  final map = jsonDecode(json) as Map<String, dynamic>;
  final dateType = TaskDateTypes.getTypeWithLabel(map['dateType'] as String);
  if (dateType == null) {
    throw FormatException('Unknown TaskDateType label: ${map['dateType']}');
  }
  return m.AnchorDate((b) => b
    ..dateValue = DateTime.parse(map['dateValue'] as String)
    ..dateType = dateType);
}

// ── Sprint + SprintAssignment ────────────────────────────────────────────────

m.Sprint sprintFromRow(Sprint row, List<SprintAssignment> assignmentRows) {
  return m.Sprint((b) => b
    ..docId = row.docId
    ..dateAdded = row.dateAdded
    ..startDate = row.startDate
    ..endDate = row.endDate
    ..closeDate = row.closeDate
    ..numUnits = row.numUnits
    ..unitName = row.unitName
    ..personDocId = row.personDocId
    ..sprintNumber = row.sprintNumber
    ..retired = row.retired
    ..retiredDate = row.retiredDate
    ..sprintAssignments = ListBuilder<m.SprintAssignment>(
        assignmentRows.map(sprintAssignmentFromRow)));
}

SprintsCompanion sprintToCompanion(m.Sprint sprint) {
  return SprintsCompanion(
    docId: Value(sprint.docId),
    dateAdded: Value(sprint.dateAdded),
    startDate: Value(sprint.startDate),
    endDate: Value(sprint.endDate),
    closeDate: Value(sprint.closeDate),
    numUnits: Value(sprint.numUnits),
    unitName: Value(sprint.unitName),
    personDocId: Value(sprint.personDocId),
    sprintNumber: Value(sprint.sprintNumber),
    retired: Value(sprint.retired),
    retiredDate: Value(sprint.retiredDate),
  );
}

m.SprintAssignment sprintAssignmentFromRow(SprintAssignment row) {
  return m.SprintAssignment((b) => b
    ..docId = row.docId
    ..taskDocId = row.taskDocId
    ..sprintDocId = row.sprintDocId
    ..retired = row.retired
    ..retiredDate = row.retiredDate);
}

SprintAssignmentsCompanion sprintAssignmentToCompanion(
    m.SprintAssignment assignment) {
  return SprintAssignmentsCompanion(
    docId: Value(assignment.docId),
    taskDocId: Value(assignment.taskDocId),
    sprintDocId: Value(assignment.sprintDocId),
    retired: Value(assignment.retired),
    retiredDate: Value(assignment.retiredDate),
  );
}

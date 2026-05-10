import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart';

import '../../models/anchor_date.dart' as m;
import '../../models/area.dart' as m;
import '../../models/area_blueprint.dart';
import '../../models/context.dart' as m;
import '../../models/context_blueprint.dart';
import '../../models/family.dart' as m;
import '../../models/family_invitation.dart' as m;
import '../../models/person.dart' as m;
import '../../models/sprint.dart' as m;
import '../../models/sprint_assignment.dart' as m;
import '../../models/task_context.dart' as m;
import '../../models/task_date_type.dart';
import '../../models/task_item.dart' as m;
import '../../models/task_item_blueprint.dart';
import '../../models/task_recurrence.dart' as m;
import '../../models/task_recurrence_blueprint.dart';
import 'app_database.dart';

/// Bidirectional converters between Drift row structs and built_value models.
/// Single source of truth for field mapping between local SQLite and the
/// in-memory domain model. The `syncState` column is intentionally not exposed
/// here — DAOs manage it.

// Drift stores dateTime() columns as epoch milliseconds and returns local-time
// DateTimes on read-back. built_value's DatePassThroughSerializer requires UTC,
// so we normalise every DateTime coming out of Drift.
DateTime _utc(DateTime dt) => dt.isUtc ? dt : dt.toUtc();
DateTime? _utcOrNull(DateTime? dt) => dt == null ? null : _utc(dt);

// ── TaskContexts (TM-181) ────────────────────────────────────────────────────
//
// Tasks store contexts as a JSON-encoded `List<TaskContext>` in the
// `tasks.task_contexts` TEXT column (and as a JSON list under the same
// `taskContexts` field in Firestore). [parseTaskContexts] is the single source
// of truth for deserialization; both the Drift `taskItemFromRow` path and the
// Firestore `_legacyContextFallback` hook in TaskRepository feed through it
// so the legacy bare-string fallback (a v7 row's lone `"Phone"` value, or a
// pre-181 Firestore doc's `context: "Phone"` field) lands as a single-element
// list `[{name: "Phone", value: null}]` consistently.

/// Parse a value loaded from a `taskContexts` slot into a domain list.
///
/// Accepts:
/// - `null` / empty → empty list.
/// - JSON string encoding `List<{name, value?}>` → typed list.
/// - JSON string encoding a bare `String` (legacy single-value Drift row) →
///   single-element list with that name.
/// - Plain `String` (legacy migrated v7 row whose value isn't JSON) →
///   single-element list with that name.
/// - Plain `List` of maps or strings (Firestore round-trip when the field
///   was already migrated server-side) → typed list.
List<m.TaskContext> parseTaskContexts(dynamic raw) {
  if (raw == null) return const [];
  dynamic value = raw;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.startsWith('[') || trimmed.startsWith('"')) {
      try {
        value = jsonDecode(trimmed);
      } catch (_) {
        // Not valid JSON — treat the whole string as a single context name.
        return [m.TaskContext.named(trimmed)];
      }
    } else {
      return [m.TaskContext.named(trimmed)];
    }
  }
  if (value is String) {
    // jsonDecode returned a bare string (legacy `'"Phone"'` JSON quoting).
    return [m.TaskContext.named(value)];
  }
  if (value is List) {
    final out = <m.TaskContext>[];
    for (final entry in value) {
      if (entry is Map) {
        final name = entry['name'];
        if (name is! String || name.isEmpty) continue;
        final v = entry['value'];
        out.add(m.TaskContext((b) => b
          ..name = name
          ..value = v is int ? v : (v is num ? v.toInt() : null)));
      } else if (entry is String && entry.isNotEmpty) {
        out.add(m.TaskContext.named(entry));
      }
    }
    return out;
  }
  return const [];
}

/// Encode a domain list to a JSON string for storage in the `taskContexts`
/// Drift TEXT column. Empty list → empty string (NOT null) so an explicit
/// "no contexts" save round-trips deterministically.
String? serializeTaskContexts(Iterable<m.TaskContext>? list) {
  if (list == null) return null;
  final encoded = list
      .map((c) => {
            'name': c.name,
            if (c.value != null) 'value': c.value,
          })
      .toList(growable: false);
  if (encoded.isEmpty) return null;
  return jsonEncode(encoded);
}

// ── Task ─────────────────────────────────────────────────────────────────────

m.TaskItem taskItemFromRow(Task row) {
  return m.TaskItem((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..personDocId = row.personDocId
    ..familyDocId = row.familyDocId
    ..name = row.name
    ..description = row.description
    ..area = row.area
    ..contexts = ListBuilder<m.TaskContext>(parseTaskContexts(row.taskContexts))
    ..urgency = row.urgency
    ..priority = row.priority
    ..priorityScaleVersion = row.priorityScaleVersion
    ..duration = row.duration
    ..gamePoints = row.gamePoints
    ..startDate = _utcOrNull(row.startDate)
    ..targetDate = _utcOrNull(row.targetDate)
    ..dueDate = _utcOrNull(row.dueDate)
    ..urgentDate = _utcOrNull(row.urgentDate)
    ..completionDate = _utcOrNull(row.completionDate)
    ..recurNumber = row.recurNumber
    ..recurUnit = row.recurUnit
    ..recurWait = row.recurWait
    ..recurrenceDocId = row.recurrenceDocId
    ..recurIteration = row.recurIteration
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate)
    ..offCycle = row.offCycle
    ..skipped = row.skipped
    ..lastModified = _utcOrNull(row.lastModified));
}

TasksCompanion taskItemToCompanion(m.TaskItem task) {
  return TasksCompanion(
    docId: Value(task.docId),
    dateAdded: Value(task.dateAdded),
    personDocId: Value(task.personDocId),
    familyDocId: Value(task.familyDocId),
    name: Value(task.name),
    description: Value(task.description),
    area: Value(task.area),
    taskContexts: Value(serializeTaskContexts(task.contexts)),
    urgency: Value(task.urgency),
    priority: Value(task.priority),
    priorityScaleVersion: Value(task.priorityScaleVersion),
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
    skipped: Value(task.skipped),
    lastModified: Value(task.lastModified),
  );
}

// ── TaskRecurrence ───────────────────────────────────────────────────────────

m.TaskRecurrence taskRecurrenceFromRow(TaskRecurrence row) {
  return m.TaskRecurrence((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..personDocId = row.personDocId
    ..name = row.name
    ..recurNumber = row.recurNumber
    ..recurUnit = row.recurUnit
    ..recurWait = row.recurWait
    ..recurIteration = row.recurIteration
    ..anchorDate = _anchorDateFromJson(row.anchorDateJson).toBuilder()
    ..lastModified = _utcOrNull(row.lastModified));
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
    lastModified: Value(recurrence.lastModified),
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
    ..dateValue = _utc(DateTime.parse(map['dateValue'] as String))
    ..dateType = dateType);
}

// ── Sprint + SprintAssignment ────────────────────────────────────────────────

m.Sprint sprintFromRow(Sprint row, List<SprintAssignment> assignmentRows) {
  return m.Sprint((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..startDate = _utc(row.startDate)
    ..endDate = _utc(row.endDate)
    ..closeDate = _utcOrNull(row.closeDate)
    ..numUnits = row.numUnits
    ..unitName = row.unitName
    ..personDocId = row.personDocId
    ..sprintNumber = row.sprintNumber
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate)
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
    ..retiredDate = _utcOrNull(row.retiredDate));
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

// ── Blueprint → Companion (for local-first mutations) ────────────────────────

/// Full companion for inserting a brand-new locally-created task.
/// All mutable fields are included; [docId] and [dateAdded] are generated
/// by the caller (from Firestore .doc().id and DateTime.now()).
TasksCompanion taskBlueprintToCompanion({
  required String docId,
  required String personDocId,
  required DateTime dateAdded,
  required TaskItemBlueprint blueprint,
}) {
  return TasksCompanion(
    docId: Value(docId),
    dateAdded: Value(dateAdded),
    personDocId: Value(personDocId),
    familyDocId: Value(blueprint.familyDocId),
    name: Value(blueprint.name ?? ''),
    description: Value(blueprint.description),
    area: Value(blueprint.area),
    taskContexts: Value(serializeTaskContexts(blueprint.contexts)),
    urgency: Value(blueprint.urgency),
    priority: Value(blueprint.priority),
    // New tasks default to the post-TM-358 scale; only legacy rows already
    // in the DB stay at version 1 until they're saved.
    priorityScaleVersion: Value(blueprint.priorityScaleVersion ?? 2),
    duration: Value(blueprint.duration),
    gamePoints: Value(blueprint.gamePoints),
    startDate: Value(blueprint.startDate),
    targetDate: Value(blueprint.targetDate),
    dueDate: Value(blueprint.dueDate),
    urgentDate: Value(blueprint.urgentDate),
    completionDate: Value(blueprint.completionDate),
    recurNumber: Value(blueprint.recurNumber),
    recurUnit: Value(blueprint.recurUnit),
    recurWait: Value(blueprint.recurWait),
    recurrenceDocId: Value(blueprint.recurrenceDocId),
    recurIteration: Value(blueprint.recurIteration),
    retired: Value(blueprint.retired),
    retiredDate: Value(blueprint.retiredDate),
    offCycle: Value(blueprint.offCycle),
  );
}

/// Partial companion for updating an existing task. Mutable blueprint fields
/// are written with Value(...) so the DAO's markUpdatePending/write call
/// overwrites exactly these columns. `name` is left absent when the blueprint
/// doesn't set it so the existing stored value is preserved — the full
/// `taskBlueprintToCompanion` path is responsible for validating that name
/// is non-null on insert.
TasksCompanion taskBlueprintToDiff(TaskItemBlueprint blueprint) {
  return TasksCompanion(
    name:
        blueprint.name != null ? Value(blueprint.name!) : const Value.absent(),
    familyDocId: blueprint.familyDocId != null
        ? Value(blueprint.familyDocId)
        : const Value.absent(),
    description: Value(blueprint.description),
    area: Value(blueprint.area),
    taskContexts: Value(serializeTaskContexts(blueprint.contexts)),
    urgency: Value(blueprint.urgency),
    priority: Value(blueprint.priority),
    // Only write the scale version on update if the blueprint set it
    // (i.e. the screen explicitly migrated this task). Otherwise leave the
    // existing column value alone.
    priorityScaleVersion: blueprint.priorityScaleVersion != null
        ? Value(blueprint.priorityScaleVersion!)
        : const Value.absent(),
    duration: Value(blueprint.duration),
    gamePoints: Value(blueprint.gamePoints),
    startDate: Value(blueprint.startDate),
    targetDate: Value(blueprint.targetDate),
    dueDate: Value(blueprint.dueDate),
    urgentDate: Value(blueprint.urgentDate),
    completionDate: Value(blueprint.completionDate),
    recurNumber: Value(blueprint.recurNumber),
    recurUnit: Value(blueprint.recurUnit),
    recurWait: Value(blueprint.recurWait),
    recurrenceDocId: Value(blueprint.recurrenceDocId),
    recurIteration: Value(blueprint.recurIteration),
    retired: Value(blueprint.retired),
    retiredDate: Value(blueprint.retiredDate),
    offCycle: Value(blueprint.offCycle),
  );
}

/// Full companion for inserting a brand-new locally-created recurrence.
TaskRecurrencesCompanion recurrenceBlueprintToCompanion({
  required String docId,
  required String personDocId,
  required DateTime dateAdded,
  required TaskRecurrenceBlueprint blueprint,
}) {
  final anchorDate = blueprint.anchorDate;
  if (anchorDate == null) {
    throw ArgumentError('TaskRecurrenceBlueprint.anchorDate must not be null when inserting');
  }
  return TaskRecurrencesCompanion(
    docId: Value(docId),
    dateAdded: Value(dateAdded),
    personDocId: Value(personDocId),
    name: Value(blueprint.name ?? ''),
    recurNumber: Value(blueprint.recurNumber ?? 1),
    recurUnit: Value(blueprint.recurUnit ?? ''),
    recurWait: Value(blueprint.recurWait ?? false),
    recurIteration: Value(blueprint.recurIteration ?? 1),
    anchorDateJson: Value(_anchorDateToJson(anchorDate)),
  );
}

// ── Family / FamilyInvitation / Person ──────────────────────────────────────

m.Family familyFromRow(Family row) {
  final List<dynamic> raw = jsonDecode(row.membersJson) as List<dynamic>;
  final members = raw.map((e) => e as String);
  return m.Family((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..ownerPersonDocId = row.ownerPersonDocId
    ..members = ListBuilder<String>(members)
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate));
}

FamiliesCompanion familyToCompanion(m.Family family) {
  return FamiliesCompanion(
    docId: Value(family.docId),
    dateAdded: Value(family.dateAdded),
    ownerPersonDocId: Value(family.ownerPersonDocId),
    membersJson: Value(jsonEncode(family.members.toList())),
    retired: Value(family.retired),
    retiredDate: Value(family.retiredDate),
  );
}

m.FamilyInvitation familyInvitationFromRow(FamilyInvitation row) {
  return m.FamilyInvitation((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..inviterPersonDocId = row.inviterPersonDocId
    ..inviterFamilyDocId = row.inviterFamilyDocId
    ..inviterDisplayName = row.inviterDisplayName
    ..inviteeEmail = row.inviteeEmail
    ..status = row.status);
}

FamilyInvitationsCompanion familyInvitationToCompanion(
    m.FamilyInvitation invitation) {
  return FamilyInvitationsCompanion(
    docId: Value(invitation.docId),
    dateAdded: Value(invitation.dateAdded),
    inviterPersonDocId: Value(invitation.inviterPersonDocId),
    inviterFamilyDocId: Value(invitation.inviterFamilyDocId),
    inviterDisplayName: Value(invitation.inviterDisplayName),
    inviteeEmail: Value(invitation.inviteeEmail),
    status: Value(invitation.status),
  );
}

m.Person personFromRow(Person row) {
  return m.Person((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..email = row.email
    ..displayName = row.displayName
    ..familyDocId = row.familyDocId
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate));
}

PersonsCompanion personToCompanion(m.Person person) {
  return PersonsCompanion(
    docId: Value(person.docId),
    dateAdded: Value(person.dateAdded),
    email: Value(person.email),
    displayName: Value(person.displayName),
    familyDocId: Value(person.familyDocId),
    retired: Value(person.retired),
    retiredDate: Value(person.retiredDate),
  );
}

/// Partial companion for updating an existing recurrence.
TaskRecurrencesCompanion recurrenceBlueprintToDiff(
    TaskRecurrenceBlueprint blueprint) {
  final anchorDate = blueprint.anchorDate;
  return TaskRecurrencesCompanion(
    name: blueprint.name != null ? Value(blueprint.name!) : const Value.absent(),
    recurNumber: blueprint.recurNumber != null
        ? Value(blueprint.recurNumber!)
        : const Value.absent(),
    recurUnit: blueprint.recurUnit != null
        ? Value(blueprint.recurUnit!)
        : const Value.absent(),
    recurWait: blueprint.recurWait != null
        ? Value(blueprint.recurWait!)
        : const Value.absent(),
    recurIteration: blueprint.recurIteration != null
        ? Value(blueprint.recurIteration!)
        : const Value.absent(),
    anchorDateJson: anchorDate != null
        ? Value(_anchorDateToJson(anchorDate))
        : const Value.absent(),
  );
}

// ── Area (TM-345) ────────────────────────────────────────────────────────────

m.Area areaFromRow(Area row) {
  return m.Area((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..name = row.name
    ..sortOrder = row.sortOrder
    ..personDocId = row.personDocId
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate));
}

AreasCompanion areaToCompanion(m.Area area) {
  return AreasCompanion(
    docId: Value(area.docId),
    dateAdded: Value(area.dateAdded),
    name: Value(area.name),
    sortOrder: Value(area.sortOrder),
    personDocId: Value(area.personDocId),
    retired: Value(area.retired),
    retiredDate: Value(area.retiredDate),
  );
}

AreasCompanion areaBlueprintToCompanion({
  required String docId,
  required DateTime dateAdded,
  required AreaBlueprint blueprint,
}) {
  return AreasCompanion(
    docId: Value(docId),
    dateAdded: Value(dateAdded),
    name: Value(blueprint.name),
    sortOrder: Value(blueprint.sortOrder),
    personDocId: Value(blueprint.personDocId),
    retired: blueprint.retired != null
        ? Value(blueprint.retired)
        : const Value.absent(),
    retiredDate: blueprint.retiredDate != null
        ? Value(blueprint.retiredDate)
        : const Value.absent(),
  );
}

// ── Context (TM-181) ─────────────────────────────────────────────────────────

m.Context contextFromRow(Context row) {
  return m.Context((b) => b
    ..docId = row.docId
    ..dateAdded = _utc(row.dateAdded)
    ..name = row.name
    ..sortOrder = row.sortOrder
    ..iconName = row.iconName
    ..color = row.color
    ..personDocId = row.personDocId
    ..retired = row.retired
    ..retiredDate = _utcOrNull(row.retiredDate));
}

ContextsCompanion contextToCompanion(m.Context context) {
  return ContextsCompanion(
    docId: Value(context.docId),
    dateAdded: Value(context.dateAdded),
    name: Value(context.name),
    sortOrder: Value(context.sortOrder),
    iconName: Value(context.iconName),
    color: Value(context.color),
    personDocId: Value(context.personDocId),
    retired: Value(context.retired),
    retiredDate: Value(context.retiredDate),
  );
}

ContextsCompanion contextBlueprintToCompanion({
  required String docId,
  required DateTime dateAdded,
  required ContextBlueprint blueprint,
}) {
  return ContextsCompanion(
    docId: Value(docId),
    dateAdded: Value(dateAdded),
    name: Value(blueprint.name),
    sortOrder: Value(blueprint.sortOrder),
    iconName: Value(blueprint.iconName),
    color: Value(blueprint.color),
    personDocId: Value(blueprint.personDocId),
    retired: blueprint.retired != null
        ? Value(blueprint.retired)
        : const Value.absent(),
    retiredDate: blueprint.retiredDate != null
        ? Value(blueprint.retiredDate)
        : const Value.absent(),
  );
}

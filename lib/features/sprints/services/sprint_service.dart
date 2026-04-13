import 'package:built_collection/built_collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Import Drift database but hide Drift data classes that conflict with domain models.
import '../../../core/database/app_database.dart'
    hide Sprint, SprintAssignment, TaskRecurrence, Task;
import '../../../core/database/converters.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../models/sprint_blueprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/sprint.dart';
import '../../../models/serializers.dart';
import '../../tasks/providers/task_providers.dart';

part 'sprint_service.g.dart';

class SprintService {
  SprintService(this._firestore);

  final dynamic _firestore; // FirebaseFirestore

  /// Create a new sprint with assigned tasks
  Future<Sprint> createSprintWithTasks({
    required SprintBlueprint sprintBlueprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    // TM-325: Use WriteBatch for atomic commits - triggers only ONE snapshot update
    // instead of N updates (one per document), dramatically reducing listener churn

    final now = DateTime.now().toUtc();
    final batch = _firestore.batch();

    // Step 1: Prepare all documents and add to batch
    final List<TaskItem> newTasksFromRecurrences = [];

    for (var preview in taskItemRecurPreviews) {
      final blueprint = preview.toBlueprint();
      var blueprintJson = blueprint.toJson();
      blueprintJson['dateAdded'] = now;

      // Handle recurrence if present
      var recurrenceBlueprint = blueprint.recurrenceBlueprint;
      var existingRecurrenceDocId = blueprint.recurrenceDocId;

      if (recurrenceBlueprint != null && existingRecurrenceDocId == null) {
        // NEW recurrence - create document
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc();
        var recurrenceJson = recurrenceBlueprint.toJson();
        recurrenceJson['dateAdded'] = now;

        // Add to batch instead of immediate write
        batch.set(recurrenceDoc, recurrenceJson);
        blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
        blueprintJson.remove('recurrenceBlueprint');
      } else if (existingRecurrenceDocId != null && recurrenceBlueprint != null) {
        // EXISTING recurrence - update recurIteration on the existing document
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc(existingRecurrenceDocId);
        batch.update(recurrenceDoc, {'recurIteration': recurrenceBlueprint.recurIteration});
        blueprintJson.remove('recurrenceBlueprint');
      }

      // Pre-generate task doc reference
      final taskDoc = _firestore.collection('tasks').doc();
      batch.set(taskDoc, blueprintJson);

      // Construct TaskItem locally
      final json = Map<String, dynamic>.from(blueprintJson);
      json['docId'] = taskDoc.id;
      final newTask = serializers.deserializeWith(TaskItem.serializer, json)!;
      newTasksFromRecurrences.add(newTask);
    }

    // Combine existing tasks with newly created tasks
    final allTasks = [...taskItems, ...newTasksFromRecurrences];

    // Get next sprint number (must be done before batch to know the value)
    final sprintsSnapshot = await _firestore
        .collection('sprints')
        .where('personDocId', isEqualTo: sprintBlueprint.personDocId)
        .get();

    int maxSprintNumber = 0;
    for (var doc in sprintsSnapshot.docs) {
      final sprintNumber = doc.data()['sprintNumber'] as int? ?? 0;
      if (sprintNumber > maxSprintNumber) {
        maxSprintNumber = sprintNumber;
      }
    }

    // Pre-generate sprint doc reference
    final sprintRef = _firestore.collection('sprints').doc();

    // TM-326: Convert dates to UTC to ensure correct timezone handling
    final sprintData = {
      'dateAdded': now,
      'startDate': sprintBlueprint.startDate.toUtc(),
      'endDate': sprintBlueprint.endDate.toUtc(),
      'numUnits': sprintBlueprint.numUnits,
      'unitName': sprintBlueprint.unitName,
      'personDocId': sprintBlueprint.personDocId,
      'sprintNumber': maxSprintNumber + 1,
    };

    // Add sprint to batch
    batch.set(sprintRef, sprintData);

    // TM-325: Add sprint assignments to batch (not parallel futures)
    final List<Map<String, dynamic>> assignmentsData = [];
    for (var task in allTasks) {
      final assignmentDoc = sprintRef.collection('sprintAssignments').doc();
      final assignmentData = {
        'docId': assignmentDoc.id,
        'taskDocId': task.docId,
        'sprintDocId': sprintRef.id,
        'dateAdded': now,
      };
      batch.set(assignmentDoc, assignmentData);
      assignmentsData.add(assignmentData);
    }

    // Commit everything in one atomic operation:
    // recurrences + tasks + sprint + assignments
    await batch.commit();

    // Construct Sprint locally without read-back round trips
    final sprintJson = Map<String, dynamic>.from(sprintData);
    sprintJson['docId'] = sprintRef.id;
    sprintJson['sprintAssignments'] = assignmentsData;

    return serializers.deserializeWith(Sprint.serializer, sprintJson)!;
  }

  /// Add tasks to an existing sprint
  Future<void> addTasksToSprint({
    required Sprint sprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    // TM-325: Use WriteBatch for atomic commits - triggers only ONE snapshot update
    final now = DateTime.now().toUtc();
    final batch = _firestore.batch();

    // Step 1: Prepare all documents and add to batch
    final List<TaskItem> newTasksFromRecurrences = [];

    for (var preview in taskItemRecurPreviews) {
      final blueprint = preview.toBlueprint();
      var blueprintJson = blueprint.toJson();
      blueprintJson['dateAdded'] = now;

      // Handle recurrence if present
      var recurrenceBlueprint = blueprint.recurrenceBlueprint;
      var existingRecurrenceDocId = blueprint.recurrenceDocId;

      if (recurrenceBlueprint != null && existingRecurrenceDocId == null) {
        // NEW recurrence - create document
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc();
        var recurrenceJson = recurrenceBlueprint.toJson();
        recurrenceJson['dateAdded'] = now;

        batch.set(recurrenceDoc, recurrenceJson);
        blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
        blueprintJson.remove('recurrenceBlueprint');
      } else if (existingRecurrenceDocId != null && recurrenceBlueprint != null) {
        // EXISTING recurrence - update recurIteration on the existing document
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc(existingRecurrenceDocId);
        batch.update(recurrenceDoc, {'recurIteration': recurrenceBlueprint.recurIteration});
        blueprintJson.remove('recurrenceBlueprint');
      }

      // Pre-generate task doc reference
      final taskDoc = _firestore.collection('tasks').doc();
      batch.set(taskDoc, blueprintJson);

      // Construct TaskItem locally
      final json = Map<String, dynamic>.from(blueprintJson);
      json['docId'] = taskDoc.id;
      final newTask = serializers.deserializeWith(TaskItem.serializer, json)!;
      newTasksFromRecurrences.add(newTask);
    }

    // Combine existing tasks with newly created tasks
    final allTasks = [...taskItems, ...newTasksFromRecurrences];

    // Add sprint assignments to batch
    final sprintRef = _firestore.collection('sprints').doc(sprint.docId);
    for (var task in allTasks) {
      final assignmentDoc = sprintRef.collection('sprintAssignments').doc();
      final assignmentData = {
        'taskDocId': task.docId,
        'sprintDocId': sprint.docId,
        'dateAdded': now,
      };
      batch.set(assignmentDoc, assignmentData);
    }

    // Commit all documents in one atomic operation
    await batch.commit();
  }
}

@riverpod
SprintService sprintService(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return SprintService(firestore);
}

/// Controller for creating sprints
@riverpod
class CreateSprint extends _$CreateSprint {
  @override
  FutureOr<void> build() {}

  Future<Sprint> call({
    required SprintBlueprint sprintBlueprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    final db = ref.read(databaseProvider);
    final firestore = ref.read(firestoreProvider);
    final now = DateTime.now().toUtc();

    // docIds are generated outside the transaction (Firestore's .doc().id is
    // client-side and doesn't require a round-trip) so the transaction body
    // only contains Drift writes.
    final sprintDocId = firestore.collection('sprints').doc().id;
    late final int sprintNumber;

    // Run all local writes in a single transaction so a failure partway
    // through leaves the local DB consistent instead of with half a sprint
    // queued for sync.
    await db.transaction(() async {
      // Resolve new tasks from recurrence previews and write to Drift.
      // Only docIds are tracked — they're all that the assignment-write loop
      // below needs, and they're safer than deserializing TaskItems from
      // blueprint JSON (which can throw mid-operation).
      final List<String> newTaskDocIds = [];
      for (final preview in taskItemRecurPreviews) {
        final blueprint = preview.toBlueprint();
        final personDocId = sprintBlueprint.personDocId;
        blueprint.personDocId = personDocId;

        // Handle recurrence update or creation.
        final recBp = blueprint.recurrenceBlueprint;
        if (recBp != null && blueprint.recurrenceDocId == null) {
          final recurrenceDocId = firestore.collection('taskRecurrences').doc().id;
          blueprint.recurrenceDocId = recurrenceDocId;
          await db.taskRecurrenceDao.insertPending(
            recurrenceBlueprintToCompanion(
              docId: recurrenceDocId,
              personDocId: personDocId,
              dateAdded: now,
              blueprint: recBp,
            ),
          );
        } else if (recBp != null && blueprint.recurrenceDocId != null) {
          await db.taskRecurrenceDao.markUpdatePending(
            blueprint.recurrenceDocId!,
            recurrenceBlueprintToDiff(recBp),
          );
        }

        final taskDocId = firestore.collection('tasks').doc().id;
        await db.taskDao.insertPending(
          taskBlueprintToCompanion(
            docId: taskDocId,
            personDocId: personDocId,
            dateAdded: now,
            blueprint: blueprint,
          ),
        );
        newTaskDocIds.add(taskDocId);
      }

      // Determine next sprint number from local Drift cache (most recent 3
      // sprints are always synced, so the max is authoritative).
      final allLocalSprints = await (db.select(db.sprints)
            ..where((s) => s.personDocId.equals(sprintBlueprint.personDocId)))
          .get();
      final maxSprintNumber = allLocalSprints.fold<int>(
          0, (max, s) => s.sprintNumber > max ? s.sprintNumber : max);
      sprintNumber = maxSprintNumber + 1;

      // Write sprint to Drift.
      await db.sprintDao.insertSprintPending(SprintsCompanion(
        docId: Value(sprintDocId),
        dateAdded: Value(now),
        startDate: Value(sprintBlueprint.startDate.toUtc()),
        endDate: Value(sprintBlueprint.endDate.toUtc()),
        numUnits: Value(sprintBlueprint.numUnits),
        unitName: Value(sprintBlueprint.unitName),
        personDocId: Value(sprintBlueprint.personDocId),
        sprintNumber: Value(sprintNumber),
      ));

      // Write assignments to Drift for all tasks.
      final allAssignedTaskDocIds = <String>[
        for (final t in taskItems) t.docId,
        ...newTaskDocIds,
      ];
      for (final taskDocId in allAssignedTaskDocIds) {
        final assignmentDocId = firestore
            .collection('sprints')
            .doc(sprintDocId)
            .collection('sprintAssignments')
            .doc()
            .id;
        await db.sprintDao.insertAssignmentPending(SprintAssignmentsCompanion(
          docId: Value(assignmentDocId),
          taskDocId: Value(taskDocId),
          sprintDocId: Value(sprintDocId),
        ));
      }
    });

    ref.read(analyticsServiceProvider)
        .logSprintCreated(taskCount: taskItems.length + taskItemRecurPreviews.length)
        .ignore();
    ref.read(syncServiceProvider).pushPendingWrites(caller: 'CreateSprint').ignore();

    // Return a Sprint model built from the data we just persisted.
    return Sprint((b) => b
      ..docId = sprintDocId
      ..dateAdded = now
      ..startDate = sprintBlueprint.startDate.toUtc()
      ..endDate = sprintBlueprint.endDate.toUtc()
      ..numUnits = sprintBlueprint.numUnits
      ..unitName = sprintBlueprint.unitName
      ..personDocId = sprintBlueprint.personDocId
      ..sprintNumber = sprintNumber
      ..sprintAssignments = ListBuilder());
  }
}

/// Controller for adding tasks to existing sprint
@riverpod
class AddTasksToSprint extends _$AddTasksToSprint {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required Sprint sprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      final firestore = ref.read(firestoreProvider);
      final now = DateTime.now().toUtc();
      final personDocId = sprint.personDocId;

      // Run all local writes in a single transaction so a failure partway
      // through leaves the local DB consistent (no tasks queued without
      // assignments, or vice-versa).
      await db.transaction(() async {
        // Create new tasks from recurrence previews. Only docIds are tracked
        // (see CreateSprint for rationale).
        final List<String> newTaskDocIds = [];
        for (final preview in taskItemRecurPreviews) {
          final blueprint = preview.toBlueprint();
          blueprint.personDocId = personDocId;

          final recBp = blueprint.recurrenceBlueprint;
          if (recBp != null && blueprint.recurrenceDocId == null) {
            final recurrenceDocId =
                firestore.collection('taskRecurrences').doc().id;
            blueprint.recurrenceDocId = recurrenceDocId;
            await db.taskRecurrenceDao.insertPending(
              recurrenceBlueprintToCompanion(
                docId: recurrenceDocId,
                personDocId: personDocId,
                dateAdded: now,
                blueprint: recBp,
              ),
            );
          } else if (recBp != null && blueprint.recurrenceDocId != null) {
            await db.taskRecurrenceDao.markUpdatePending(
              blueprint.recurrenceDocId!,
              recurrenceBlueprintToDiff(recBp),
            );
          }

          final taskDocId = firestore.collection('tasks').doc().id;
          await db.taskDao.insertPending(
            taskBlueprintToCompanion(
              docId: taskDocId,
              personDocId: personDocId,
              dateAdded: now,
              blueprint: blueprint,
            ),
          );
          newTaskDocIds.add(taskDocId);
        }

        // Write assignments for all tasks.
        final sprintRef = firestore.collection('sprints').doc(sprint.docId);
        final allAssignedTaskDocIds = <String>[
          for (final t in taskItems) t.docId,
          ...newTaskDocIds,
        ];
        for (final taskDocId in allAssignedTaskDocIds) {
          final assignmentDocId =
              sprintRef.collection('sprintAssignments').doc().id;
          await db.sprintDao.insertAssignmentPending(SprintAssignmentsCompanion(
            docId: Value(assignmentDocId),
            taskDocId: Value(taskDocId),
            sprintDocId: Value(sprint.docId),
          ));
        }
      });

      ref.read(syncServiceProvider).pushPendingWrites(caller: 'AddTasksToSprint').ignore();
    });
  }
}

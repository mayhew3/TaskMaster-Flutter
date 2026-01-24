import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/sprint_blueprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/sprint.dart';
import '../../../models/serializers.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/sprint_providers.dart';

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
    final service = ref.read(sprintServiceProvider);
    final result = await service.createSprintWithTasks(
      sprintBlueprint: sprintBlueprint,
      taskItems: taskItems,
      taskItemRecurPreviews: taskItemRecurPreviews,
    );

    // TM-325: Invalidate sprints provider to force UI refresh
    // This matches the pattern in AddTasksToSprint (line 225)
    ref.invalidate(sprintsProvider);

    return result;
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
      final service = ref.read(sprintServiceProvider);
      await service.addTasksToSprint(
        sprint: sprint,
        taskItems: taskItems,
        taskItemRecurPreviews: taskItemRecurPreviews,
      );
    });

    // Invalidate sprints provider AFTER state is set to force reload from Firestore
    // This is needed because adding to subcollection doesn't trigger parent snapshot
    if (state.hasValue) {
      print('[TM-306] Invalidating sprints provider');
      ref.invalidate(sprintsProvider);
    }
  }
}

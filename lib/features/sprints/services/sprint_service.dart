import 'package:built_collection/built_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/sprint_blueprint.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/sprint_assignment.dart';
import '../../../models/sprint.dart';
import '../../../models/serializers.dart';
import '../../../helpers/recurrence_helper.dart';

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
    // Create tasks from recurrence previews
    List<TaskItem> newTasksFromRecurrences = [];
    for (var preview in taskItemRecurPreviews) {
      final blueprint = preview.toBlueprint();
      var blueprintJson = blueprint.toJson();

      // Handle recurrence if present
      var recurrenceBlueprint = blueprint.recurrenceBlueprint;
      if (recurrenceBlueprint != null) {
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc();
        var recurrenceJson = recurrenceBlueprint.toJson();
        recurrenceJson['dateAdded'] = DateTime.now().toUtc();
        await recurrenceDoc.set(recurrenceJson);
        blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
        blueprintJson.remove('recurrenceBlueprint');
      }

      blueprintJson['dateAdded'] = DateTime.now().toUtc();

      final taskRef = await _firestore.collection('tasks').add(blueprintJson);

      // Wait for the task to be created and read it back
      final taskDoc = await taskRef.get();
      final json = taskDoc.data();
      json['docId'] = taskDoc.id;
      final newTask = serializers.deserializeWith(
        TaskItem.serializer,
        json,
      )!;
      newTasksFromRecurrences.add(newTask);
    }

    // Combine existing tasks with newly created tasks
    final allTasks = [...taskItems, ...newTasksFromRecurrences];

    // Get next sprint number
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

    // Create sprint
    final sprintData = {
      'dateAdded': DateTime.timestamp(),
      'startDate': sprintBlueprint.startDate,
      'endDate': sprintBlueprint.endDate,
      'numUnits': sprintBlueprint.numUnits,
      'unitName': sprintBlueprint.unitName,
      'personDocId': sprintBlueprint.personDocId,
      'sprintNumber': maxSprintNumber + 1,
    };

    final sprintRef = await _firestore.collection('sprints').add(sprintData);

    // Create sprint assignments
    for (var task in allTasks) {
      final assignmentData = {
        'taskDocId': task.docId,
        'dateAdded': DateTime.timestamp(),
      };
      await sprintRef.collection('sprintAssignments').add(assignmentData);
    }

    // Read back the created sprint with assignments
    final sprintDoc = await sprintRef.get();
    final sprintJson = sprintDoc.data();
    sprintJson['docId'] = sprintDoc.id;

    // Load sprint assignments
    final assignmentsSnapshot = await sprintRef
        .collection('sprintAssignments')
        .get();

    final assignments = assignmentsSnapshot.docs.map((assignDoc) {
      final assignJson = assignDoc.data();
      assignJson['docId'] = assignDoc.id;
      return serializers.deserializeWith(
        SprintAssignment.serializer,
        assignJson,
      )!;
    }).toList();

    sprintJson['sprintAssignments'] = assignments;

    return serializers.deserializeWith(Sprint.serializer, sprintJson)!;
  }

  /// Add tasks to an existing sprint
  Future<void> addTasksToSprint({
    required Sprint sprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    // Create tasks from recurrence previews
    List<TaskItem> newTasksFromRecurrences = [];
    for (var preview in taskItemRecurPreviews) {
      final blueprint = preview.toBlueprint();
      var blueprintJson = blueprint.toJson();

      // Handle recurrence if present
      var recurrenceBlueprint = blueprint.recurrenceBlueprint;
      if (recurrenceBlueprint != null) {
        var recurrenceDoc = _firestore.collection('taskRecurrences').doc();
        var recurrenceJson = recurrenceBlueprint.toJson();
        recurrenceJson['dateAdded'] = DateTime.now().toUtc();
        await recurrenceDoc.set(recurrenceJson);
        blueprintJson['recurrenceDocId'] = recurrenceDoc.id;
        blueprintJson.remove('recurrenceBlueprint');
      }

      blueprintJson['dateAdded'] = DateTime.now().toUtc();

      final taskRef = await _firestore.collection('tasks').add(blueprintJson);

      final taskDoc = await taskRef.get();
      final json = taskDoc.data();
      json['docId'] = taskDoc.id;
      final newTask = serializers.deserializeWith(
        TaskItem.serializer,
        json,
      )!;
      newTasksFromRecurrences.add(newTask);
    }

    // Combine existing tasks with newly created tasks
    final allTasks = [...taskItems, ...newTasksFromRecurrences];

    // Add sprint assignments
    final sprintRef = _firestore.collection('sprints').doc(sprint.docId);
    for (var task in allTasks) {
      final assignmentData = {
        'taskDocId': task.docId,
        'dateAdded': DateTime.timestamp(),
      };
      await sprintRef.collection('sprintAssignments').add(assignmentData);
    }
  }
}

@riverpod
SprintService sprintService(SprintServiceRef ref) {
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
    state = const AsyncLoading();

    final sprint = await AsyncValue.guard(() async {
      final service = ref.read(sprintServiceProvider);
      return await service.createSprintWithTasks(
        sprintBlueprint: sprintBlueprint,
        taskItems: taskItems,
        taskItemRecurPreviews: taskItemRecurPreviews,
      );
    });

    state = sprint.hasError ? sprint : const AsyncData(null);
    return sprint.value!;
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(sprintServiceProvider);
      await service.addTasksToSprint(
        sprint: sprint,
        taskItems: taskItems,
        taskItemRecurPreviews: taskItemRecurPreviews,
      );
    });
  }
}

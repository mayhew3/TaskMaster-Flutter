import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_blueprint.dart';
import '../../../models/task_recurrence.dart';
import '../domain/task_repository.dart';
import '../../../task_repository.dart' as legacy;

part 'firestore_task_repository.g.dart';

/// Adapter: wraps existing TaskRepository for now
/// During migration, this allows Riverpod code to use the same data layer as Redux
class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._legacyRepo);

  final legacy.TaskRepository _legacyRepo;

  @override
  Future<void> addTask(TaskItemBlueprint blueprint) async {
    return _legacyRepo.addTask(blueprint);
  }

  @override
  Future<({TaskItem taskItem, TaskRecurrence? recurrence})>
      updateTaskAndRecurrence(
    String taskItemDocId,
    TaskItemBlueprint blueprint,
  ) {
    return _legacyRepo.updateTaskAndRecurrence(taskItemDocId, blueprint);
  }

  @override
  Future<void> deleteTask(TaskItem taskItem) async {
    return _legacyRepo.deleteTask(taskItem);
  }

  @override
  Future<TaskItem> toggleTaskCompletion(
    TaskItem task, {
    required bool complete,
  }) async {
    final completionDate = complete ? DateTime.now() : null;
    final blueprint = task.createBlueprint()..completionDate = completionDate;

    final result = await _legacyRepo.updateTaskAndRecurrence(
      task.docId,
      blueprint,
    );

    return result.taskItem;
  }
}

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  final legacyRepo = legacy.TaskRepository(firestore: firestore);
  return FirestoreTaskRepository(legacyRepo);
}

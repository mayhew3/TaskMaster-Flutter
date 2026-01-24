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
  FirestoreTaskRepository(this._legacyRepo, this._firestore);

  final legacy.TaskRepository _legacyRepo;
  final FirebaseFirestore _firestore;

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

    // Fire-and-forget with error logging
    // Firestore writes to local cache immediately, syncs to server in background
    // Stream listener picks up the change from local cache
    _firestore.collection('tasks').doc(task.docId).update({
      'completionDate': completionDate?.toUtc(),
    }).catchError((error) {
      // Log error but don't block - Firestore will retry for network issues
      // For permission/validation errors, the stream will eventually show correct state
      print('⚠️ [toggleTaskCompletion] Firestore update error: $error');
      // Note: Could emit an error event here for UI to show a toast/snackbar
    });

    // Return updated task immediately (don't wait for server confirmation)
    final updatedTask = task.rebuild((b) => b..completionDate = completionDate);
    return updatedTask;
  }
}

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  final legacyRepo = legacy.TaskRepository(firestore: firestore);
  return FirestoreTaskRepository(legacyRepo, firestore);
}

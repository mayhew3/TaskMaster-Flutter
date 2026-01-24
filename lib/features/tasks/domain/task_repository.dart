import '../../../models/task_item.dart';
import '../../../models/task_item_blueprint.dart';
import '../../../models/task_recurrence.dart';

/// Abstract repository interface for task operations
/// Can be implemented by Firestore, mock, or other data sources
abstract class TaskRepository {
  /// Add a new task
  Future<void> addTask(TaskItemBlueprint blueprint);

  /// Update existing task and optionally its recurrence
  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTaskAndRecurrence(
    String taskItemDocId,
    TaskItemBlueprint blueprint,
  );

  /// Soft delete a task (sets retired field)
  Future<void> deleteTask(TaskItem taskItem);

  /// Complete or uncomplete a task
  Future<TaskItem> toggleTaskCompletion(
    TaskItem task, {
    required bool complete,
  });
}

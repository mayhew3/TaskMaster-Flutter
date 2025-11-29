import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';
import '../../../models/serializers.dart';

part 'task_providers.g.dart';

/// Stream of all tasks for the current user
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) {
  // Get dependencies synchronously
  final firestore = ref.watch(firestoreProvider);
  final personDocId = ref.watch(personDocIdProvider);

  // If not authenticated, return empty stream
  if (personDocId == null) {
    return Stream.value([]);
  }

  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final json = doc.data();
              json['docId'] = doc.id;
              final task = serializers.deserializeWith(TaskItem.serializer, json);

              // Filter out old completed tasks (older than 7 days)
              if (task != null) {
                final completionDate = task.completionDate;
                if (completionDate != null && completionDate.isBefore(sevenDaysAgo)) {
                  return null;
                }
                return task;
              }
              return null;
            })
            .whereType<TaskItem>() // Remove nulls
            .toList();
      });
}

/// Stream of task recurrences for the current user
@riverpod
Stream<List<TaskRecurrence>> taskRecurrences(TaskRecurrencesRef ref) {
  // Get dependencies synchronously
  final firestore = ref.watch(firestoreProvider);
  final personDocId = ref.watch(personDocIdProvider);

  // If not authenticated, return empty stream
  if (personDocId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('taskRecurrences')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final json = doc.data();
              json['docId'] = doc.id;
              return serializers.deserializeWith(
                TaskRecurrence.serializer,
                json,
              );
            })
            .whereType<TaskRecurrence>() // Remove nulls
            .toList();
      });
}

/// Stream of tasks with their recurrences populated
/// This is the primary provider that UI should use - it ensures task.recurrence
/// is always populated for recurring tasks, matching the Redux pattern
@Riverpod(keepAlive: true)
Stream<List<TaskItem>> tasksWithRecurrences(TasksWithRecurrencesRef ref) async* {
  // Watch both streams
  await for (final tasks in ref.watch(tasksProvider.stream)) {
    final recurrences = await ref.read(taskRecurrencesProvider.future);

    // Link tasks with their recurrences (matching Redux onTaskItemsAdded pattern)
    final linked = tasks.map((task) {
      if (task.recurrenceDocId != null) {
        final recurrence = recurrences
            .where((r) => r.docId == task.recurrenceDocId)
            .firstOrNull;
        if (recurrence != null) {
          return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
        }
      }
      return task;
    }).toList();

    yield linked;
  }
}

/// Get a specific task by ID
@riverpod
TaskItem? task(TaskRef ref, String taskId) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );
}

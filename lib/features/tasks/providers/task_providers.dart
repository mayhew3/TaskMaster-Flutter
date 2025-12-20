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

  print('📋 tasksProvider: personDocId = $personDocId');

  // If not authenticated, return empty stream
  if (personDocId == null) {
    print('📋 tasksProvider: No personDocId, returning empty stream');
    return Stream.value([]);
  }

  print('📋 tasksProvider: Loading tasks for personDocId: $personDocId');

  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .snapshots()
      .map((snapshot) {
        print('📋 tasksProvider: Received ${snapshot.docs.length} task documents from Firestore');
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
@riverpod
Future<List<TaskItem>> tasksWithRecurrences(TasksWithRecurrencesRef ref) async {
  // Wait for both providers to have data
  final tasks = await ref.watch(tasksProvider.future);
  final recurrences = await ref.watch(taskRecurrencesProvider.future);

  print('📋 tasksWithRecurrencesProvider: Linking ${tasks.length} tasks with ${recurrences.length} recurrences');

  // Link tasks with their recurrences (matching Redux onTaskItemsAdded pattern)
  return tasks.map((task) {
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
}

/// Get a specific task by ID with recurrence populated
@riverpod
TaskItem? task(TaskRef ref, String taskId) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );
}

/// Tracks recently completed tasks to keep them visible temporarily
/// This matches Redux's recentlyCompleted state which prevents completed
/// tasks from immediately disappearing when filters are applied
@Riverpod(keepAlive: true)
class RecentlyCompletedTasks extends _$RecentlyCompletedTasks {
  @override
  List<TaskItem> build() => [];

  void add(TaskItem task) {
    if (!state.any((t) => t.docId == task.docId)) {
      state = [...state, task];
    }
  }

  void remove(TaskItem task) {
    state = state.where((t) => t.docId != task.docId).toList();
  }

  void clear() {
    state = [];
  }
}

/// Tracks tasks currently being completed (optimistic UI)
/// This enables immediate visual feedback (pending state) before Firestore confirms
@Riverpod(keepAlive: true)
class PendingTasks extends _$PendingTasks {
  @override
  Map<String, TaskItem> build() => {};

  void markPending(TaskItem task) {
    final pendingTask = task.rebuild((b) => b..pendingCompletion = true);
    state = {...state, task.docId: pendingTask};
  }

  void clearPending(String taskDocId) {
    state = Map.from(state)..remove(taskDocId);
  }
}

/// Tasks with pending completion state merged in (optimistic UI overlay)
/// This provider overlays optimistic pending state on top of Firestore data
@riverpod
Future<List<TaskItem>> tasksWithPendingState(TasksWithPendingStateRef ref) async {
  final tasks = await ref.watch(tasksWithRecurrencesProvider.future);
  final pendingTasks = ref.watch(pendingTasksProvider);

  if (pendingTasks.isEmpty) return tasks;

  return tasks.map((task) => pendingTasks[task.docId] ?? task).toList();
}

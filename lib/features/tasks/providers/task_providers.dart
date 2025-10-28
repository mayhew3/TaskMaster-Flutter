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
  // Get dependencies first (before async*)
  final firestore = ref.watch(firestoreProvider);
  final personDocIdAsync = ref.watch(personDocIdProvider);

  return personDocIdAsync.when(
    data: (personDocId) {
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
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

/// Stream of task recurrences for the current user
@riverpod
Stream<List<TaskRecurrence>> taskRecurrences(TaskRecurrencesRef ref) {
  // Get dependencies first (before async*)
  final firestore = ref.watch(firestoreProvider);
  final personDocIdAsync = ref.watch(personDocIdProvider);

  return personDocIdAsync.when(
    data: (personDocId) {
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
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';
import '../../../models/serializers.dart';

part 'task_providers.g.dart';

/// Stream of all tasks for the current user
@riverpod
Stream<List<TaskItem>> tasks(Ref ref) {
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

  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  return firestore
      .collection('tasks')
      .where(
        Filter.and(
          Filter('personDocId', isEqualTo: personDocId),
          Filter('retired', isNull: true),
          Filter.or(
            Filter('completionDate', isNull: true),
            Filter('completionDate', isGreaterThan: thirtyDaysAgo.toUtc()),
          ),
        ),
      )
      .snapshots()
      .map((snapshot) {
        print('📋 tasksProvider: Received ${snapshot.docs.length} task documents from Firestore');
        return snapshot.docs
            .map((doc) {
              final json = doc.data();
              json['docId'] = doc.id;
              return serializers.deserializeWith(TaskItem.serializer, json);
            })
            .whereType<TaskItem>() // Remove nulls
            .toList();
      });
}

/// Stream of task recurrences for the current user
@riverpod
Stream<List<TaskRecurrence>> taskRecurrences(Ref ref) {
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
/// Uses rxdart combineLatest2 for PARALLEL loading of tasks and recurrences
/// This is the primary provider that UI should use - it ensures task.recurrence
/// is always populated for recurring tasks, matching the Redux pattern
@Riverpod(keepAlive: true)
Stream<List<TaskItem>> tasksWithRecurrences(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  final personDocId = ref.watch(personDocIdProvider);

  if (personDocId == null) {
    return Stream.value([]);
  }

  final stopwatch = Stopwatch()..start();
  print('⏱️ tasksWithRecurrencesProvider: Starting parallel queries');

  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

  // Create tasks stream - server-side filter: incomplete + completed within 30 days
  final tasksStream = firestore
      .collection('tasks')
      .where(
        Filter.and(
          Filter('personDocId', isEqualTo: personDocId),
          Filter('retired', isNull: true),
          Filter.or(
            Filter('completionDate', isNull: true),
            Filter('completionDate', isGreaterThan: thirtyDaysAgo.toUtc()),
          ),
        ),
      )
      .snapshots()
      .map((snapshot) {
        print('⏱️ tasksWithRecurrences: Got ${snapshot.docs.length} task docs at ${stopwatch.elapsedMilliseconds}ms');
        return snapshot.docs
            .map((doc) {
              final json = doc.data();
              json['docId'] = doc.id;
              return serializers.deserializeWith(TaskItem.serializer, json);
            })
            .whereType<TaskItem>()
            .toList();
      });

  // Create recurrences stream
  final recurrencesStream = firestore
      .collection('taskRecurrences')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .snapshots()
      .map((snapshot) {
        print('⏱️ tasksWithRecurrences: Got ${snapshot.docs.length} recurrence docs at ${stopwatch.elapsedMilliseconds}ms');
        return snapshot.docs
            .map((doc) {
              final json = doc.data();
              json['docId'] = doc.id;
              return serializers.deserializeWith(TaskRecurrence.serializer, json);
            })
            .whereType<TaskRecurrence>()
            .toList();
      });

  // PARALLEL: Combine both streams - fires when EITHER emits, using latest from both
  return Rx.combineLatest2<List<TaskItem>, List<TaskRecurrence>, List<TaskItem>>(
    tasksStream,
    recurrencesStream,
    (tasks, recurrences) {
      print('⏱️ tasksWithRecurrences: Combining ${tasks.length} tasks with ${recurrences.length} recurrences at ${stopwatch.elapsedMilliseconds}ms');

      // O(1) lookup map instead of O(n) search for each task
      final recurrenceMap = {for (var r in recurrences) r.docId: r};

      // Link tasks with their recurrences
      final linkedTasks = tasks.map((task) {
        if (task.recurrenceDocId != null) {
          final recurrence = recurrenceMap[task.recurrenceDocId];
          if (recurrence != null) {
            return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
          }
        }
        return task;
      }).toList();

      print('⏱️ tasksWithRecurrences: Completed in ${stopwatch.elapsedMilliseconds}ms');
      return linkedTasks;
    },
  );
}

/// Get a specific task by ID with recurrence populated.
/// Falls back to older completed tasks if not found in the base query.
@riverpod
TaskItem? task(Ref ref, String taskId) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

  final baseResult = tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );

  if (baseResult != null) return baseResult;

  // Fall back to older completed tasks batch
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);
  return olderState.loadedTasks.where((t) => t.docId == taskId).firstOrNull;
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
Future<List<TaskItem>> tasksWithPendingState(Ref ref) async {
  final tasks = await ref.watch(tasksWithRecurrencesProvider.future);
  final pendingTasks = ref.watch(pendingTasksProvider);

  if (pendingTasks.isEmpty) return tasks;

  return tasks.map((task) => pendingTasks[task.docId] ?? task).toList();
}

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).
@riverpod
Stream<List<TaskItem>> tasksForRecurrence(Ref ref, String recurrenceDocId) {
  final firestore = ref.watch(firestoreProvider);
  final personDocId = ref.watch(personDocIdProvider);

  if (personDocId == null) return Stream.value([]);

  return firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('recurrenceDocId', isEqualTo: recurrenceDocId)
      .orderBy('recurIteration', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) {
            final json = doc.data();
            json['docId'] = doc.id;
            return serializers.deserializeWith(TaskItem.serializer, json);
          })
          .whereType<TaskItem>()
          .toList());
}

/// State for progressively loaded older completed tasks
class OlderCompletedState {
  final List<TaskItem> loadedTasks;
  final DateTime oldestLoadedDate;
  final bool isLoading;
  final bool hasMore;

  const OlderCompletedState({
    required this.loadedTasks,
    required this.oldestLoadedDate,
    required this.isLoading,
    required this.hasMore,
  });

  OlderCompletedState copyWith({
    List<TaskItem>? loadedTasks,
    DateTime? oldestLoadedDate,
    bool? isLoading,
    bool? hasMore,
  }) {
    return OlderCompletedState(
      loadedTasks: loadedTasks ?? this.loadedTasks,
      oldestLoadedDate: oldestLoadedDate ?? this.oldestLoadedDate,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Progressively loads older completed tasks in 30-day batches.
/// Triggered when the user enables "Show Completed" and taps "Load More".
/// Uses one-time fetches (not real-time listeners) since old completed tasks rarely change.
@Riverpod(keepAlive: true)
class OlderCompletedTasksBatches extends _$OlderCompletedTasksBatches {
  @override
  OlderCompletedState build() => OlderCompletedState(
    loadedTasks: [],
    oldestLoadedDate: DateTime.now().subtract(const Duration(days: 30)),
    isLoading: false,
    hasMore: true,
  );

  Future<void> loadNextBatch() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    final firestore = ref.read(firestoreProvider);
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      state = state.copyWith(isLoading: false, hasMore: false);
      return;
    }

    final batchEnd = state.oldestLoadedDate;
    final batchStart = batchEnd.subtract(const Duration(days: 30));

    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('personDocId', isEqualTo: personDocId)
          .where('retired', isNull: true)
          .where('completionDate', isLessThanOrEqualTo: batchEnd.toUtc())
          .where('completionDate', isGreaterThan: batchStart.toUtc())
          .orderBy('completionDate', descending: true)
          .get(); // One-time fetch, not a listener

      final newTasks = snapshot.docs
          .map((doc) {
            final json = doc.data();
            json['docId'] = doc.id;
            return serializers.deserializeWith(TaskItem.serializer, json);
          })
          .whereType<TaskItem>()
          .toList();

      state = state.copyWith(
        loadedTasks: [...state.loadedTasks, ...newTasks],
        oldestLoadedDate: batchStart,
        isLoading: false,
        hasMore: newTasks.isNotEmpty,
      );
    } catch (e) {
      print('[OlderCompletedTasksBatches] Error loading batch: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    state = OlderCompletedState(
      loadedTasks: [],
      oldestLoadedDate: DateTime.now().subtract(const Duration(days: 30)),
      isLoading: false,
      hasMore: true,
    );
  }
}

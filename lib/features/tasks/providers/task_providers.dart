import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/bad_schema_task.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';
import '../../../models/serializers.dart';

part 'task_providers.g.dart';

/// Tracks tasks that failed Firestore deserialization.
/// Displayed in the UI with warning styling so the user knows something is wrong.
@Riverpod(keepAlive: true)
class BadSchemaTasks extends _$BadSchemaTasks {
  @override
  List<BadSchemaTask> build() {
    // Reset on user change to prevent cross-user leakage
    ref.watch(personDocIdProvider);
    return [];
  }

  /// Replace the entire bad-schema list (called per snapshot to reflect current state)
  void replace(List<BadSchemaTask> tasks) {
    state = tasks;
  }

  void clear() {
    state = [];
  }
}

/// Stream of incomplete tasks for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
/// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].
@riverpod
Stream<List<TaskItem>> tasks(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value([]);

  final badSchemaNotifier = ref.read(badSchemaTasksProvider.notifier);

  return db.taskDao.watchIncompleteTasks(personDocId).map((rows) {
    final tasks = <TaskItem>[];
    final badTasks = <BadSchemaTask>[];
    for (final row in rows) {
      try {
        tasks.add(taskItemFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [tasksProvider] Failed to convert row ${row.docId}: $e');
        badTasks.add(BadSchemaTask(
          docId: row.docId,
          rawName: row.name,
          errorMessage: e.toString(),
        ));
      }
    }
    badSchemaNotifier.replace(badTasks);
    return tasks;
  });
}

/// Stream of task recurrences for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
@riverpod
Stream<List<TaskRecurrence>> taskRecurrences(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value([]);

  return db.taskRecurrenceDao.watchActive(personDocId).map((rows) {
    final recurrences = <TaskRecurrence>[];
    for (final row in rows) {
      try {
        recurrences.add(taskRecurrenceFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [taskRecurrencesProvider] Failed to convert row ${row.docId}: $e');
      }
    }
    return recurrences;
  });
}

/// Stream of tasks with their recurrences populated.
/// Combines the two Drift streams so recurrences are always linked on each emit.
@Riverpod(keepAlive: true)
Stream<List<TaskItem>> tasksWithRecurrences(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value([]);

  final badSchemaNotifier = ref.read(badSchemaTasksProvider.notifier);

  final tasksStream = db.taskDao.watchIncompleteTasks(personDocId).map((rows) {
    final tasks = <TaskItem>[];
    final badTasks = <BadSchemaTask>[];
    for (final row in rows) {
      try {
        tasks.add(taskItemFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [tasksWithRecurrences] Failed to convert task ${row.docId}: $e');
        badTasks.add(BadSchemaTask(
          docId: row.docId,
          rawName: row.name,
          errorMessage: e.toString(),
        ));
      }
    }
    badSchemaNotifier.replace(badTasks);
    return tasks;
  });

  final recurrencesStream =
      db.taskRecurrenceDao.watchActive(personDocId).map((rows) {
    final recurrences = <TaskRecurrence>[];
    for (final row in rows) {
      try {
        recurrences.add(taskRecurrenceFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [tasksWithRecurrences] Failed to convert recurrence ${row.docId}: $e');
      }
    }
    return recurrences;
  });

  return Rx.combineLatest2<List<TaskItem>, List<TaskRecurrence>, List<TaskItem>>(
    tasksStream,
    recurrencesStream,
    (tasks, recurrences) {
      final recurrenceMap = {for (final r in recurrences) r.docId: r};
      return tasks.map((task) {
        if (task.recurrenceDocId != null) {
          final recurrence = recurrenceMap[task.recurrenceDocId];
          if (recurrence != null) {
            return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
          }
        }
        return task;
      }).toList();
    },
  );
}

/// Get a specific task by ID with recurrence populated.
/// Searches four sources in priority order:
///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)
@riverpod
TaskItem? task(Ref ref, String taskId) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

  final baseResult = tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );
  if (baseResult != null) return baseResult;

  // Check recently completed tasks (task was just completed this session and
  // is no longer in the incomplete query but hasn't moved to batches yet).
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final recentResult = recentlyCompleted.where((t) => t.docId == taskId).firstOrNull;
  if (recentResult != null) return recentResult;

  // Check older completed batches (loaded when user enables "Show Completed").
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);
  final olderResult = olderState.loadedTasks.where((t) => t.docId == taskId).firstOrNull;
  if (olderResult != null) return olderResult;

  // Last resort: query Drift directly by docId (covers force-quit + restart when
  // the task is in the local DB but absent from all in-memory providers — TM-341).
  final taskFromDbAsync = ref.watch(taskFromDbProvider(taskId));
  return taskFromDbAsync.valueOrNull;
}

/// Stream of a single task directly from Drift by docId, with recurrence populated.
/// Has NO completionDate filter — returns completed tasks too.
/// Used as the ultimate fallback in [taskProvider] for cases where the task
/// exists in the local DB but is absent from all in-memory providers
/// (e.g., completed task after a force-quit + restart before any batches load).
@riverpod
Stream<TaskItem?> taskFromDb(Ref ref, String taskId) {
  final db = ref.watch(databaseProvider);
  final personDocId = ref.watch(personDocIdProvider);

  if (personDocId == null) return Stream.value(null);

  final taskStream = db.taskDao.watchTaskById(taskId).map((row) {
    if (row == null) return null;
    // Guard against stale rows from another user (e.g. after sign-out/sign-in).
    if (row.personDocId != personDocId) return null;
    try {
      return taskItemFromRow(row);
    } catch (e) {
      debugPrint('⚠️ [taskFromDbProvider] Failed to convert task $taskId: $e');
      return null;
    }
  });

  final recurrencesStream =
      db.taskRecurrenceDao.watchActive(personDocId).map((rows) {
    final recurrences = <TaskRecurrence>[];
    for (final row in rows) {
      try {
        recurrences.add(taskRecurrenceFromRow(row));
      } catch (e) {
        debugPrint('⚠️ [taskFromDbProvider] Failed to convert recurrence ${row.docId}: $e');
      }
    }
    return recurrences;
  });

  return Rx.combineLatest2<TaskItem?, List<TaskRecurrence>, TaskItem?>(
    taskStream,
    recurrencesStream,
    (task, recurrences) {
      if (task == null) return null;
      if (task.recurrenceDocId == null) return task;
      final recurrenceMap = {for (final r in recurrences) r.docId: r};
      final recurrence = recurrenceMap[task.recurrenceDocId];
      if (recurrence == null) return task;
      return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
    },
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

/// Side table mapping recently-completed task docId → its index in the
/// Tasks tab base list (tasksProvider) at the moment of completion.
///
/// Used by filteredTasksProvider to re-insert just-completed tasks at their
/// original position instead of appending them to the end — otherwise a
/// completed task visibly jumps to the bottom of its group (TM-339 Tasks
/// tab follow-up). The Sprint screen has its own ordering mechanism based
/// on sprint.sprintAssignments and does not use this.
@Riverpod(keepAlive: true)
class RecentlyCompletedIndices extends _$RecentlyCompletedIndices {
  @override
  Map<String, int> build() => const {};

  void set(String docId, int index) {
    state = {...state, docId: index};
  }

  void remove(String docId) {
    if (!state.containsKey(docId)) return;
    state = Map.of(state)..remove(docId);
  }

  void clear() {
    if (state.isEmpty) return;
    state = const {};
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
  /// Firestore document snapshot cursor for deterministic pagination.
  final DocumentSnapshot? lastDocument;
  final bool isLoading;
  final bool hasMore;

  const OlderCompletedState({
    required this.loadedTasks,
    this.lastDocument,
    required this.isLoading,
    required this.hasMore,
  });

  OlderCompletedState copyWith({
    List<TaskItem>? loadedTasks,
    DocumentSnapshot? Function()? lastDocument,
    bool? isLoading,
    bool? hasMore,
  }) {
    return OlderCompletedState(
      loadedTasks: loadedTasks ?? this.loadedTasks,
      lastDocument: lastDocument != null
          ? lastDocument()
          : this.lastDocument,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Progressively loads completed tasks using cursor-based pagination.
/// Triggered when the user enables "Show Completed".
/// Uses one-time fetches (not real-time listeners) in fixed-size batches.
@Riverpod(keepAlive: true)
class OlderCompletedTasksBatches extends _$OlderCompletedTasksBatches {
  static const _batchSize = 50;

  @override
  OlderCompletedState build() {
    // Watch personDocId so state resets on sign-out/sign-in (prevents cross-user leakage)
    ref.watch(personDocIdProvider);
    return const OlderCompletedState(
      loadedTasks: [],
      isLoading: false,
      hasMore: true,
    );
  }

  Future<void> loadNextBatch() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    final firestore = ref.read(firestoreProvider);
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      state = state.copyWith(isLoading: false, hasMore: false);
      return;
    }

    try {
      // Query all completed tasks, paginated.
      // The base query only returns incomplete tasks, so all completed
      // tasks come through this provider.
      var query = firestore
          .collection('tasks')
          .where('personDocId', isEqualTo: personDocId)
          .where('retired', isNull: true)
          .where('completionDate', isNull: false)
          .orderBy('completionDate', descending: true)
          .limit(_batchSize);

      if (state.lastDocument != null) {
        // Continue from last document of previous batch
        query = query.startAfterDocument(state.lastDocument!);
      }

      final snapshot = await query.get();

      final rawTasks = snapshot.docs
          .map((doc) {
            final json = doc.data();
            json['docId'] = doc.id;
            return serializers.deserializeWith(TaskItem.serializer, json);
          })
          .whereType<TaskItem>()
          .toList();

      // Link recurrences — fetch only the needed ones using whereIn (max 30 per query)
      final recurrenceDocIds = rawTasks
          .where((t) => t.recurrenceDocId != null)
          .map((t) => t.recurrenceDocId!)
          .toSet()
          .toList();
      final recurrenceMap = <String, TaskRecurrence>{};
      if (recurrenceDocIds.isNotEmpty) {
        // Firestore whereIn supports max 30 values per query
        for (var i = 0; i < recurrenceDocIds.length; i += 30) {
          final chunk = recurrenceDocIds.sublist(
            i, i + 30 > recurrenceDocIds.length ? recurrenceDocIds.length : i + 30,
          );
          final recurrenceSnapshot = await firestore
              .collection('taskRecurrences')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final doc in recurrenceSnapshot.docs) {
            final json = doc.data();
            json['docId'] = doc.id;
            final recurrence = serializers.deserializeWith(TaskRecurrence.serializer, json);
            if (recurrence != null) {
              recurrenceMap[doc.id] = recurrence;
            }
          }
        }
      }
      final newTasks = rawTasks.map((task) {
        if (task.recurrenceDocId != null) {
          final recurrence = recurrenceMap[task.recurrenceDocId];
          if (recurrence != null) {
            return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
          }
        }
        return task;
      }).toList();

      state = state.copyWith(
        loadedTasks: [...state.loadedTasks, ...newTasks],
        lastDocument: () => snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDocument,
        isLoading: false,
        hasMore: snapshot.docs.length == _batchSize,
      );
    } catch (e) {
      print('[OlderCompletedTasksBatches] Error loading batch: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() {
    state = const OlderCompletedState(
      loadedTasks: [],
      lastDocument: null,
      isLoading: false,
      hasMore: true,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/providers/auth_providers.dart';
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
/// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].
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

  final badSchemaNotifier = ref.read(badSchemaTasksProvider.notifier);

  return firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .where('completionDate', isNull: true)
      .snapshots()
      .map((snapshot) {
        print('📋 tasksProvider: Received ${snapshot.docs.length} incomplete tasks from Firestore');
        final result = _deserializeTasks(snapshot.docs);
        badSchemaNotifier.replace(result.badTasks);
        return result.tasks;
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

  // Create tasks stream - only incomplete tasks
  final tasksStream = firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where('retired', isNull: true)
      .where('completionDate', isNull: true)
      .snapshots()
      .map((snapshot) {
        print('⏱️ tasksWithRecurrences: Got ${snapshot.docs.length} incomplete task docs at ${stopwatch.elapsedMilliseconds}ms');
        final result = _deserializeTasks(snapshot.docs);
        ref.read(badSchemaTasksProvider.notifier).replace(result.badTasks);
        return result.tasks;
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
/// Falls back to already-loaded older completed task batches if not found
/// in the base query. Does not fetch from Firestore by ID.
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

/// Result of deserializing Firestore task documents.
class _DeserializeResult {
  final List<TaskItem> tasks;
  final List<BadSchemaTask> badTasks;
  _DeserializeResult(this.tasks, this.badTasks);
}

/// Deserialize Firestore task documents with error handling.
/// Returns both successfully deserialized tasks and bad-schema entries.
_DeserializeResult _deserializeTasks(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final tasks = <TaskItem>[];
  final badTasks = <BadSchemaTask>[];
  for (final doc in docs) {
    final json = doc.data();
    json['docId'] = doc.id;
    try {
      final task = serializers.deserializeWith(TaskItem.serializer, json);
      if (task != null) {
        tasks.add(task);
      } else {
        badTasks.add(BadSchemaTask(
          docId: doc.id,
          rawName: json['name']?.toString(),
          errorMessage: 'Deserialization returned null',
        ));
      }
    } catch (e) {
      debugPrint('⚠️ [TaskDeserialization] Error for doc ${doc.id} "${json['name']}": $e');
      badTasks.add(BadSchemaTask(
        docId: doc.id,
        rawName: json['name']?.toString(),
        errorMessage: e.toString(),
      ));
    }
  }
  return _DeserializeResult(tasks, badTasks);
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

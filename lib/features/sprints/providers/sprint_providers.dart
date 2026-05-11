import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../tasks/providers/task_filter_providers.dart';
import '../../tasks/providers/task_providers.dart';

part 'sprint_providers.g.dart';

/// Stream of the N most recent sprints for the current user, with assignments.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
@Riverpod(keepAlive: true)
Stream<List<Sprint>> sprints(Ref ref) {
  final personDocId = ref.watch(personDocIdProvider);
  final db = ref.watch(databaseProvider);

  if (personDocId == null) return Stream.value([]);

  return db.sprintDao
      .watchRecentSprints(personDocId: personDocId, limit: 3)
      .map((rows) {
    if (kDebugMode) {
      debugPrint('[sprintsProvider] Drift emitted ${rows.length} sprint row(s)');
      for (final row in rows) {
        debugPrint(
            '  sprint ${row.sprint.docId}: sprintNumber=${row.sprint.sprintNumber}, '
            'start=${row.sprint.startDate}, end=${row.sprint.endDate}, '
            'syncState=${row.sprint.syncState}, assignments=${row.assignments.length}');
      }
    }
    final result = <Sprint>[];
    for (final row in rows) {
      try {
        result.add(sprintFromRow(row.sprint, row.assignments));
      } catch (e) {
        // Error-path logging kept unconditionally so schema issues surface.
        debugPrint('⚠️ [sprintsProvider] Failed to convert sprint ${row.sprint.docId}: $e');
      }
    }
    return result;
  });
}

/// Get active sprint (currently in progress)
@Riverpod(keepAlive: true)
Sprint? activeSprint(Ref ref) {
  final sprintsAsync = ref.watch(sprintsProvider);

  return sprintsAsync.maybeWhen(
    data: (sprints) {
      final now = DateTime.now().toUtc();
      final matching = sprints.where((sprint) =>
          sprint.startDate.isBefore(now) &&
          sprint.endDate.isAfter(now) &&
          sprint.closeDate == null);
      return matching.isEmpty ? null : matching.last;
    },
    orElse: () => null,
  );
}

/// Get last completed sprint
@Riverpod(keepAlive: true)
Sprint? lastCompletedSprint(Ref ref) {
  final sprintsAsync = ref.watch(sprintsProvider);

  return sprintsAsync.maybeWhen(
    data: (sprints) {
      final matching = sprints.where((sprint) {
        return DateTime.now().isAfter(sprint.endDate);
      }).toList();
      matching.sort((a, b) => a.endDate.compareTo(b.endDate));
      return matching.isEmpty ? null : matching.last;
    },
    orElse: () => null,
  );
}

/// Get sprints for a specific task
@Riverpod(keepAlive: true)
List<Sprint> sprintsForTask(Ref ref, TaskItem task) {
  final sprintsAsync = ref.watch(sprintsProvider);

  return sprintsAsync.maybeWhen(
    data: (sprints) {
      return sprints.where((s) =>
        s.sprintAssignments.any((sa) => sa.taskDocId == task.docId)
      ).toList();
    },
    orElse: () => [],
  );
}

class SprintCounts {
  final int completed;
  final int total;
  const SprintCounts({required this.completed, required this.total});

  static const empty = SprintCounts(completed: 0, total: 0);
}

/// One-shot Firestore fetch of the sprint's full task roster — every task
/// referenced by a non-retired sprint assignment, regardless of completion
/// state. Backfills the cases the personal-tasks Drift listener misses:
/// the listener filters `completionDate isNull`, so a task completed in a
/// prior session on another device never lands in Drift. Without this
/// fetch the Sprint UI would silently hide such tasks even with
/// "Finished" toggled on (TM-361 manual-test #18 follow-up).
///
/// Bounded and cheap: one whereIn query per 30 docIds, results cached for
/// the session. Re-fetches when [sprint] changes (a new sprint instance
/// arrives from the assignments stream).
@Riverpod(keepAlive: true)
Future<List<TaskItem>> sprintRosterFirestore(Ref ref, Sprint sprint) async {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) return const [];
  final firestore = ref.watch(firestoreProvider);
  final docIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toList(growable: false);
  if (docIds.isEmpty) return const [];

  final results = <TaskItem>[];
  // Firestore whereIn supports max 30 values per query — chunk so big sprints
  // still round-trip in one provider build.
  for (var i = 0; i < docIds.length; i += 30) {
    final end = i + 30 > docIds.length ? docIds.length : i + 30;
    final chunk = docIds.sublist(i, end);
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        final json = doc.data();
        json['docId'] = doc.id;
        final task = TaskItem.fromFirestoreJson(json);
        if (task != null && task.retired == null) results.add(task);
      }
    } catch (e, st) {
      debugPrint('⚠️ [sprintRosterFirestore] chunk fetch failed: $e\n$st');
      // Fall through with whatever we have — partial roster beats hanging
      // the sprint screen on a transient Firestore error.
    }
  }
  return results;
}

/// (completed, total) counts for the active-sprint banner. Merges the
/// Firestore roster (full sprint membership, includes cold completions)
/// with Drift state (live, reflects this session's completions). Drift
/// wins on docId conflicts so a just-completed task is counted correctly
/// even before the next Firestore round-trip.
///
/// Streams from the Drift watch on the sprint's task docIds so toggling
/// completion (or any other change to those rows) re-emits a fresh count
/// to the banner. Using `.first` here instead — as an earlier revision did
/// — pinned the count to the very first emission and the banner stayed
/// stale through subsequent toggles.
@Riverpod(keepAlive: true)
Stream<SprintCounts> sprintCompletionCounts(Ref ref, Sprint sprint) async* {
  final personDocId = ref.watch(personDocIdProvider);
  if (personDocId == null) {
    yield SprintCounts.empty;
    return;
  }
  final docIds = sprint.sprintAssignments
      .where((sa) => sa.retired == null)
      .map((sa) => sa.taskDocId)
      .toList(growable: false);
  if (docIds.isEmpty) {
    yield SprintCounts.empty;
    return;
  }

  final firestoreRoster =
      await ref.watch(sprintRosterFirestoreProvider(sprint).future);
  final firestoreCompleted = <String, bool>{
    for (final t in firestoreRoster) t.docId: t.completionDate != null,
  };

  final db = ref.watch(databaseProvider);
  await for (final driftRows
      in db.taskDao.watchTasksByDocIds(personDocId, docIds)) {
    final driftCompleted = <String, bool>{
      for (final r in driftRows) r.docId: r.completionDate != null,
    };
    var completed = 0;
    for (final docId in docIds) {
      final live = driftCompleted[docId];
      if (live != null) {
        if (live) completed++;
      } else if (firestoreCompleted[docId] == true) {
        completed++;
      }
    }
    yield SprintCounts(completed: completed, total: docIds.length);
  }
}

/// Get tasks for a specific sprint.
/// Includes incomplete tasks from the base stream, recently completed tasks
/// (visible immediately after completion), and older completed tasks from the
/// on-demand batch when "Show Completed" is active (TM-341).
@Riverpod(keepAlive: true)
List<TaskItem> tasksForSprint(Ref ref, Sprint sprint) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);

  return tasksAsync.maybeWhen(
    data: (incompleteTasks) {
      final sprintDocIds = sprint.sprintAssignments.map((sa) => sa.taskDocId).toSet();
      // Map-based merge so higher-priority sources overwrite lower-priority ones.
      final tasksByDocId = <String, TaskItem>{};

      // 1. Older completed sprint tasks (lowest priority — base layer).
      if (showCompleted) {
        for (final task in olderState.loadedTasks) {
          if (sprintDocIds.contains(task.docId)) {
            tasksByDocId[task.docId] = task;
          }
        }
      }

      // 2. Incomplete sprint tasks override older completed tasks for the same docId.
      for (final task in incompleteTasks) {
        if (sprintDocIds.contains(task.docId)) {
          tasksByDocId[task.docId] = task;
        }
      }

      // 3. Recently completed tasks always win — they carry the freshest state
      //    and ensure accurate banner stats while Drift catches up.
      for (final task in recentlyCompleted) {
        if (sprintDocIds.contains(task.docId)) {
          tasksByDocId[task.docId] = task;
        }
      }

      return tasksByDocId.values.toList();
    },
    orElse: () => [],
  );
}

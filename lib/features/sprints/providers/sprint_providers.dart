import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
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
@riverpod
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
@riverpod
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
@riverpod
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

/// Get tasks for a specific sprint.
/// Includes incomplete tasks from the base stream, recently completed tasks
/// (visible immediately after completion), and older completed tasks from the
/// on-demand batch when "Show Completed" is active (TM-341).
@riverpod
List<TaskItem> tasksForSprint(Ref ref, Sprint sprint) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final olderState = ref.watch(olderCompletedTasksBatchesProvider);

  return tasksAsync.maybeWhen(
    data: (incompleteTasks) {
      final sprintDocIds = sprint.sprintAssignments.map((sa) => sa.taskDocId).toSet();
      final seen = <String>{};
      final result = <TaskItem>[];

      // 1. Incomplete sprint tasks
      for (final task in incompleteTasks) {
        if (sprintDocIds.contains(task.docId) && seen.add(task.docId)) {
          result.add(task);
        }
      }

      // 2. Recently completed sprint tasks (always — for accurate banner stats
      //    and immediate visibility after completion).
      for (final task in recentlyCompleted) {
        if (sprintDocIds.contains(task.docId) && seen.add(task.docId)) {
          result.add(task);
        }
      }

      // 3. Older completed sprint tasks (only when "Show Completed" is active).
      if (showCompleted) {
        for (final task in olderState.loadedTasks) {
          if (sprintDocIds.contains(task.docId) && seen.add(task.docId)) {
            result.add(task);
          }
        }
      }

      return result;
    },
    orElse: () => [],
  );
}

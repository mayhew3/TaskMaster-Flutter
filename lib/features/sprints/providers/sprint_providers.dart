import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/converters.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/database_provider.dart';
import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
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

/// Get tasks for a specific sprint
@riverpod
List<TaskItem> tasksForSprint(Ref ref, Sprint sprint) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      return tasks.where((t) =>
        sprint.sprintAssignments.any((sa) => sa.taskDocId == t.docId)
      ).toList();
    },
    orElse: () => [],
  );
}

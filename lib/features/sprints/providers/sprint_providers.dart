import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/sprint.dart';
import '../../../models/serializers.dart';
import '../../../models/task_item.dart';
import '../../tasks/providers/task_providers.dart';

part 'sprint_providers.g.dart';

/// Stream of all sprints for the current user
@Riverpod(keepAlive: true)
Stream<List<Sprint>> sprints(Ref ref) {
  // Get dependencies synchronously
  final firestore = ref.watch(firestoreProvider);
  final personDocId = ref.watch(personDocIdProvider);

  // If not authenticated, return empty stream
  if (personDocId == null) {
    return Stream.value([]);
  }

  final stopwatch = Stopwatch()..start();
  print('⏱️ sprintsProvider: Starting query');

  return firestore
      .collection('sprints')
      .where('personDocId', isEqualTo: personDocId)
      .orderBy('sprintNumber', descending: true)
      .limit(3)  // Only fetch recent sprints for performance
      .snapshots()
      .asyncMap((snapshot) async {
    print('⏱️ sprintsProvider: Got ${snapshot.docs.length} sprints in ${stopwatch.elapsedMilliseconds}ms');

    // PARALLEL: Fetch all sprint assignments simultaneously using Future.wait
    final sprintFutures = snapshot.docs.map((doc) async {
      final json = doc.data();
      json['docId'] = doc.id;

      // Fetch sprint assignments subcollection
      final assignmentsSnapshot = await doc.reference
          .collection('sprintAssignments')
          .get();

      final assignmentsJson = assignmentsSnapshot.docs.map((assignDoc) {
        final assignJson = assignDoc.data();
        assignJson['docId'] = assignDoc.id;
        return assignJson;
      }).toList();

      json['sprintAssignments'] = assignmentsJson;

      return serializers.deserializeWith(Sprint.serializer, json)!;
    });

    // Execute ALL assignment fetches in parallel
    final sprints = await Future.wait(sprintFutures);

    print('⏱️ sprintsProvider: Completed in ${stopwatch.elapsedMilliseconds}ms');
    return sprints;
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

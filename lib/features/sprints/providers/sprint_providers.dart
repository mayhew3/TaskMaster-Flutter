import 'package:built_collection/built_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/sprint.dart';
import '../../../models/serializers.dart';
import '../../../models/task_item.dart';
import '../../../models/sprint_assignment.dart';
import '../../tasks/providers/task_providers.dart';

part 'sprint_providers.g.dart';

/// Stream of all sprints for the current user
@Riverpod(keepAlive: true)
Stream<List<Sprint>> sprints(SprintsRef ref) async* {
  final personDocId = await ref.watch(personDocIdProvider.future);
  if (personDocId == null) {
    yield [];
    return;
  }

  final firestore = ref.watch(firestoreProvider);

  yield* firestore
      .collection('sprints')
      .where('personDocId', isEqualTo: personDocId)
      .snapshots()
      .asyncMap((snapshot) async {
    // Load sprints with their assignments
    List<Sprint> sprints = [];

    for (var doc in snapshot.docs) {
      final json = doc.data();
      json['docId'] = doc.id;

      // Fetch sprint assignments subcollection
      final assignmentsSnapshot = await doc.reference
          .collection('sprintAssignments')
          .get();

      final assignments = assignmentsSnapshot.docs.map((assignDoc) {
        final assignJson = assignDoc.data();
        assignJson['docId'] = assignDoc.id;
        return serializers.deserializeWith(
          SprintAssignment.serializer,
          assignJson,
        )!;
      }).toList();

      json['sprintAssignments'] = assignments;

      final sprint = serializers.deserializeWith(Sprint.serializer, json)!;
      sprints.add(sprint);
    }

    return sprints;
  });
}

/// Get active sprint (currently in progress)
@riverpod
Sprint? activeSprint(ActiveSprintRef ref) {
  final sprintsAsync = ref.watch(sprintsProvider);

  return sprintsAsync.maybeWhen(
    data: (sprints) {
      final now = DateTime.timestamp();
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
Sprint? lastCompletedSprint(LastCompletedSprintRef ref) {
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
List<Sprint> sprintsForTask(SprintsForTaskRef ref, TaskItem task) {
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
List<TaskItem> tasksForSprint(TasksForSprintRef ref, Sprint sprint) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      return tasks.where((t) =>
        sprint.sprintAssignments.any((sa) => sa.taskDocId == t.docId)
      ).toList();
    },
    orElse: () => [],
  );
}

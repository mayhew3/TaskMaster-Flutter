import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:riverpod_annotation/riverpod_annotation.dart' hide Family;

import '../../../models/task_item.dart';
import '../../tasks/providers/task_filter_providers.dart' show TaskGroup;
import '../../tasks/providers/task_providers.dart';

part 'family_task_filter_providers.g.dart';

/// Filter state for the Family tab. Kept separate from the Tasks tab's filter
/// providers so toggling on one tab doesn't affect the other (TM-335).
@Riverpod(keepAlive: true)
class FamilyShowCompleted extends _$FamilyShowCompleted {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class FamilyShowScheduled extends _$FamilyShowScheduled {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class FamilySearchQuery extends _$FamilySearchQuery {
  @override
  String build() => '';
  void set(String value) => state = value;
  void clear() => state = '';
}

/// Optional per-member filter chip — null means "all members".
@Riverpod(keepAlive: true)
class FamilyMemberFilter extends _$FamilyMemberFilter {
  @override
  String? build() => null;
  void set(String? personDocId) => state = personDocId;
  void clear() => state = null;
}

/// Family tasks after applying the Family-tab filter toggles. Tasks completed
/// in the current session (tracked by [recentlyCompletedTasksProvider]) are
/// always included so the just-completed task stays visible — the grouping
/// step keeps it in its original section until the user navigates away.
@riverpod
List<TaskItem> familyFilteredTasks(Ref ref) {
  final showCompleted = ref.watch(familyShowCompletedProvider);
  final showScheduled = ref.watch(familyShowScheduledProvider);
  final searchQuery = ref.watch(familySearchQueryProvider).toLowerCase();
  final memberFilter = ref.watch(familyMemberFilterProvider);
  final tasksAsync = ref.watch(familyTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final recentlyCompletedIds = recentlyCompleted.map((t) => t.docId).toSet();

  final tasks = tasksAsync.valueOrNull ?? const <TaskItem>[];

  return tasks.where((task) {
    if (task.retired != null) return false;

    if (memberFilter != null && task.personDocId != memberFilter) return false;

    if (searchQuery.isNotEmpty &&
        !task.name.toLowerCase().contains(searchQuery)) {
      return false;
    }

    if (task.completionDate != null) {
      // Recently-completed tasks always stay visible (they're shown in their
      // original group via the grouper). All other completed tasks are gated
      // by the Show Completed toggle.
      if (recentlyCompletedIds.contains(task.docId)) return true;
      return showCompleted;
    }

    final scheduledPredicate = task.startDate == null ||
        task.startDate!.isBefore(DateTime.now()) ||
        showScheduled;
    return scheduledPredicate;
  }).toList();
}

/// Family tasks grouped into Past Due / Urgent / Target / Tasks / Scheduled /
/// Completed buckets. Mirrors the Tasks-tab grouping shape, including the
/// TM-323 "recently completed stays in its original group" behavior so the
/// just-completed task doesn't visibly jump to the Completed section until
/// after the user navigates away and back.
@riverpod
List<TaskGroup> familyGroupedTasks(Ref ref) {
  final filtered = ref.watch(familyFilteredTasksProvider);
  final recentlyCompleted = ref.watch(recentlyCompletedTasksProvider);
  final recentlyCompletedIds = recentlyCompleted.map((t) => t.docId).toSet();

  final groups = <String, List<TaskItem>>{
    'Past Due': [],
    'Urgent': [],
    'Target': [],
    'Tasks': [],
    'Scheduled': [],
    'Completed': [],
  };

  for (final task in filtered) {
    final isRecentlyCompleted = recentlyCompletedIds.contains(task.docId);
    if (task.completionDate != null && !isRecentlyCompleted) {
      groups['Completed']!.add(task);
    } else if (task.isPastDue()) {
      groups['Past Due']!.add(task);
    } else if (task.isUrgent()) {
      groups['Urgent']!.add(task);
    } else if (task.isTarget()) {
      groups['Target']!.add(task);
    } else if (task.isScheduled()) {
      groups['Scheduled']!.add(task);
    } else {
      groups['Tasks']!.add(task);
    }
  }

  if (groups['Scheduled']!.isNotEmpty) {
    groups['Scheduled']!.sort((a, b) => a.startDate!.compareTo(b.startDate!));
  }
  if (groups['Completed']!.isNotEmpty) {
    groups['Completed']!
        .sort((a, b) => b.completionDate!.compareTo(a.completionDate!));
  }

  const displayOrder = {
    'Past Due': 1,
    'Urgent': 2,
    'Target': 3,
    'Tasks': 4,
    'Scheduled': 5,
    'Completed': 6,
  };

  return groups.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => TaskGroup(
            name: entry.key,
            displayOrder: displayOrder[entry.key]!,
            tasks: entry.value,
          ))
      .toList()
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
}

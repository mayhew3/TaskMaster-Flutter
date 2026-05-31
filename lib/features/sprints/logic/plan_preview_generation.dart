import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';

import '../../../helpers/recurrence_helper.dart';
import '../../../helpers/task_selectors.dart';
import '../../../models/sprint.dart';
import '../../../models/sprint_display_task.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_recur_preview.dart';
import '../../../models/task_recurrence.dart';

/// Pure recurrence-preview generation for the create-sprint picker
/// (TM-388). Both [PlanTaskList]'s `createTemporaryIterations` (for
/// display + initial queue preselection) and `planRecurrencePreviewsProvider`
/// (for sidebar facet counts) call this helper, so the previews shown in
/// the picker and the previews tallied in the sidebar can't drift.
///
/// Walks each eligible recurring source task forward one iteration at a
/// time until the candidate falls outside the planning window (no
/// target/due/start before [endDate]); returns the full flat list of
/// in-window previews. No filtering by user TaskFilters is applied here —
/// callers narrow further as needed.
List<TaskItemRecurPreview> generatePlanPreviews({
  required BuiltList<TaskItem> allTasks,
  required Sprint? activeSprint,
  required DateTime endDate,
  required List<TaskRecurrence> allRecurrences,
  required DateTime now,
}) {
  final eligibleItems = eligibleItemsForPlanningPicker(
    allTaskItems: allTasks,
    activeSprint: activeSprint,
    endDate: endDate,
  );
  final recurIDs = <String>{
    for (final t in eligibleItems)
      if (t.recurrenceDocId != null) t.recurrenceDocId!,
  };
  final all = <TaskItemRecurPreview>[];
  for (final recurID in recurIDs) {
    final recurItems = eligibleItems
        .where((t) => t.recurrenceDocId == recurID)
        .sorted((a, b) => a.recurIteration!.compareTo(b.recurIteration!));
    if (recurItems.isEmpty) continue;
    var newest = recurItems.last;
    // Populate the recurrence definition if the source's `.recurrence`
    // wasn't already populated (matches the picker's pre-existing
    // fallback).
    if (newest.recurrence == null && newest.recurrenceDocId != null) {
      final recurrence = allRecurrences
          .firstWhereOrNull((r) => r.docId == newest.recurrenceDocId);
      if (recurrence == null) continue;
      newest = newest.rebuild((b) => b..recurrence = recurrence.toBuilder());
    }
    // recurWait=true means "don't generate the next iteration until the
    // current one is completed" — no previews to project.
    if (newest.recurWait != false) continue;
    all.addAll(_previewsForSource(newest, endDate, now));
  }
  return all;
}

List<TaskItemRecurPreview> _previewsForSource(
  SprintDisplayTask source,
  DateTime endDate,
  DateTime now, [
  int depth = 0,
]) {
  if (depth >= 365) return const [];
  final next = RecurrenceHelper.createNextIteration(source, now);
  final inWindow = next.isDueBefore(endDate) ||
      next.isUrgentBefore(endDate) ||
      next.isTargetBefore(endDate) ||
      next.isScheduledBefore(endDate);
  if (!inWindow) return const [];
  return [next, ..._previewsForSource(next, endDate, now, depth + 1)];
}

/// True for previews the picker auto-selects on first mount (matches the
/// pre-TM-388 `addNextIterations` rule). Used by `PlanTaskList` to seed
/// its `taskItemRecurPreviewQueue` / `sprintDisplayTaskQueue`.
bool previewShouldPreselect(TaskItemRecurPreview preview, DateTime endDate) {
  return preview.isDueBefore(endDate) || preview.isUrgentBefore(endDate);
}

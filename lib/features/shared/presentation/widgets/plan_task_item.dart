import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/models/check_state.dart';
import 'package:taskmaestro/models/sprint_display_task.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'delayed_checkbox.dart';

/// Sprint-planning task row — a thin adapter on top of
/// [EditableTaskItemWidget].
///
/// Plan-mode and the main task list render the same card visual; the
/// only meaningful differences are:
///   - the trailing widget is an *assignment*-toggle checkbox rather
///     than a completion-toggle,
///   - the date pill / left stripe colour reflect the task's projected
///     state at the **end of the sprint being assembled** (`endDate`)
///     instead of the wall-clock now, and
///   - swipe-to-dismiss is disabled (the gesture would conflict with
///     the assignment-add affordance).
///
/// All of those are exposed as parameters on `EditableTaskItemWidget`,
/// so this widget's job is reduced to:
///   1. Synthesise a `TaskItem` from the source `SprintDisplayTask` —
///      `TaskItemRecurPreview`s become an in-memory TaskItem so the
///      shared chrome can speak a single type. Real `TaskItem` sources
///      pass through unchanged.
///   2. Compute the projection-aware pill / stripe overrides.
///   3. Build the assignment-toggle `DelayedCheckbox`.
///   4. Hand it all to `EditableTaskItemWidget`.
///
/// The card chrome (Card, Stack, AreaStripe, Padding, summary row,
/// MetaCell wrappers, AnimatedSize, ExpandedPanel, expand-into-view
/// scroll, title-truncation detection, etc.) lives in
/// `editable_task_item.dart` and is shared verbatim between this widget
/// and the main task list.
class PlanTaskItemWidget extends ConsumerWidget {
  final SprintDisplayTask sprintDisplayTask;
  final CheckCycleWaiter? onTaskAssignmentToggle;
  final DateTime? endDate;
  final CheckState? initialCheckState;
  final bool highlightSprint;

  const PlanTaskItemWidget({
    super.key,
    required this.sprintDisplayTask,
    this.endDate,
    required this.highlightSprint,
    this.onTaskAssignmentToggle,
    this.initialCheckState,
  });

  /// Returns the source as a `TaskItem` directly when possible, or a
  /// synthesised TaskItem mirroring the preview's user-visible fields.
  /// The synthesised TaskItem isn't persisted — it lives only for the
  /// duration of this build pass, feeding the shared chrome which
  /// already speaks TaskItem.
  TaskItem _displayTask() {
    final task = sprintDisplayTask;
    if (task is TaskItem) return task;
    if (task is TaskItemRecurPreview) {
      return TaskItem((b) => b
        ..docId = task.key
        ..dateAdded = DateTime.now().toUtc()
        ..personDocId = task.personDocId
        ..familyDocId = task.familyDocId
        ..name = task.name
        ..description = null
        ..area = task.area
        ..context = null
        ..urgency = task.urgency
        ..priority = task.priority
        ..priorityScaleVersion = task.priorityScaleVersion ?? 2
        ..duration = task.duration
        ..gamePoints = task.gamePoints
        ..startDate = task.startDate
        ..targetDate = task.targetDate
        ..urgentDate = task.urgentDate
        ..dueDate = task.dueDate
        ..completionDate = null
        ..recurNumber = task.recurNumber
        ..recurUnit = task.recurUnit
        ..recurWait = task.recurWait
        // No recurrenceDocId on previews — keeps the REPEAT row from
        // rendering as a (broken) link to a non-existent history page.
        ..recurrenceDocId = null
        ..recurIteration = task.recurIteration
        ..retired = null
        ..offCycle = task.offCycle
        ..skipped = false
        ..pendingCompletion = false);
    }
    throw StateError(
        'PlanTaskItemWidget: unsupported SprintDisplayTask runtime type ${task.runtimeType}');
  }

  /// Reference timestamp for "would-be state" projection. The plan
  /// screen previews how a task's state will read at the END of the
  /// sprint being assembled (`endDate` if set, else now).
  DateTime _projectionRef() => endDate ?? DateTime.now();

  /// Date type [task] would be in at [_projectionRef] (sprint horizon
  /// or wall-clock now). Returns the highest-priority crossed
  /// threshold — Due > Urgent > Target — or `start` for tasks scheduled
  /// to begin in the future. Returns `null` for tasks with no relevant
  /// date state.
  ///
  /// Reads dates from the [TaskItem] argument (the chrome-resolved
  /// display task) so the contract matches the override-callback
  /// signature; for plan-mode forecast previews the synthesised
  /// TaskItem already carries the same date fields as the underlying
  /// `SprintDisplayTask`.
  TaskDateType? _projectedStateType(TaskItem task) {
    final ref = _projectionRef();
    if (task.dueDate != null && task.dueDate!.isBefore(ref)) {
      return TaskDateTypes.due;
    }
    if (task.urgentDate != null && task.urgentDate!.isBefore(ref)) {
      return TaskDateTypes.urgent;
    }
    if (task.targetDate != null && task.targetDate!.isBefore(ref)) {
      return TaskDateTypes.target;
    }
    if (task.isScheduled()) return TaskDateTypes.start;
    return null;
  }

  /// Tone triple for the projected state. Anchors the "now" reference
  /// to the sprint horizon ([_projectionRef]) rather than wall-clock
  /// now, otherwise mirrors `toneForCurrentState` in
  /// editable_task_item.dart.
  ToneTriple? _projectedStateTone(TaskItem task) {
    final type = _projectedStateType(task);
    return type == null ? null : toneFor(type);
  }

  Color? _stripeOverride(TaskItem task) {
    final type = _projectedStateType(task);
    if (type == null) return null;
    if (type == TaskDateTypes.due) return TaskColors.dueStripe;
    if (type == TaskDateTypes.urgent) return TaskColors.urgentStripe;
    if (type == TaskDateTypes.target) return TaskColors.targetStripe;
    return TaskColors.startStripe;
  }

  /// Highest-priority date type whose date sits between wall-clock now
  /// and the sprint horizon — i.e. the latest milestone the task will
  /// cross during the sprint. Returns `null` for tasks not crossing any
  /// threshold during this sprint (already-overdue or no future dates),
  /// in which case the pill falls back to the standard `pillContentFor`
  /// semantics on the shared widget.
  ///
  /// Reads from the [TaskItem] parameter (display task) for the same
  /// reasons as [_projectedStateType] — matches the override-callback
  /// contract.
  TaskDateType? _planDisplayType(TaskItem task) {
    final ref = _projectionRef();
    final now = DateTime.now();
    final priorityOrder = [
      TaskDateTypes.due,
      TaskDateTypes.urgent,
      TaskDateTypes.target,
      TaskDateTypes.start,
    ];
    for (final type in priorityOrder) {
      final d = type.dateFieldGetter(task);
      if (d == null) continue;
      if (d.isBefore(ref) && d.isAfter(now)) return type;
    }
    return null;
  }

  String _formatRelative(DateTime dateTime) {
    final raw = timeago.format(
      dateTime,
      locale: 'en_short',
      allowFromNow: true,
    );
    final cleaned = raw.replaceAll(' ', '').replaceAll('~', '');
    if (cleaned == 'now') return 'just now';
    return dateTime.isBefore(DateTime.now())
        ? '$cleaned ago'
        : 'in $cleaned';
  }

  PillContent? _pillOverride(TaskItem displayTask) {
    final planType = _planDisplayType(displayTask);
    final stateTone = _projectedStateTone(displayTask);
    if (planType != null) {
      final dateValue = planType.dateFieldGetter(displayTask);
      if (dateValue != null) {
        final displayTone = toneFor(planType);
        return PillContent(
          label: planType.label.toUpperCase(),
          value: _formatRelative(dateValue),
          bg: stateTone?.bg ?? Colors.transparent,
          border: stateTone?.border ?? TaskColors.hairline,
          fg: displayTone.fg,
          borderWidth: 2,
        );
      }
    }
    // Fallback: task isn't crossing any threshold during this sprint —
    // let the standard `pillContentFor` pick the label, but keep the
    // bg / border tinted by the projected state tone for visual
    // continuity with the rest of the planning row.
    final base = pillContentFor(displayTask);
    if (base == null) return null;
    if (stateTone == null) return base;
    // COMPLETED / SKIPPED pills carry their own intentional styling
    // (magenta family); re-tinting them with a date-state tone would
    // make a finished task look like an active one. Skip the override
    // for done-state pills and pass the base through unchanged.
    if (displayTask.completionDate != null || displayTask.skipped) return base;
    return PillContent(
      label: base.label,
      value: base.value,
      bg: stateTone.bg,
      border: stateTone.border,
      fg: base.fg,
      borderWidth: base.borderWidth,
    );
  }

  Widget _trailingCheckbox() {
    if (onTaskAssignmentToggle == null || initialCheckState == null) {
      return const SizedBox.shrink();
    }
    return DelayedCheckbox(
      taskName: sprintDisplayTask.name,
      initialState: initialCheckState!,
      checkCycleWaiter: onTaskAssignmentToggle!,
      checkedColor: Colors.green,
      // The "+" affordance signals "add to sprint." Always rendered in
      // the default colour (full white) — recurring vs one-off doesn't
      // change the sprint-assignment cue.
      inactiveIcon: Icons.add,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayTask = _displayTask();
    return EditableTaskItemWidget(
      taskItem: displayTask,
      highlightSprint: highlightSprint,
      pillContentOverride: _pillOverride,
      stripeColorOverride: _stripeOverride,
      trailingBuilder: _trailingCheckbox,
      // Plan-mode rows shouldn't be swipe-deletable — the screen's
      // primary gesture is "tap to add to sprint", not "delete task".
      enableDismissible: false,
    );
  }
}

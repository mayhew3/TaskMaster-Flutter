import 'package:flutter/material.dart';
import 'package:taskmaestro/features/shared/presentation/editable_task_item.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/check_state.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_display_task.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'delayed_checkbox.dart';

/// Sprint-planning task row. Visually mirrors the redesigned task list
/// card from `EditableTaskItemWidget` (left stripe in date-state colour,
/// summary row with name + date pill, area badge in the meta row), but
/// the trailing widget is an *assignment* checkbox — toggling adds /
/// removes the task from the user's pending sprint queue rather than
/// completing it.
///
/// Two source types feed in via the `SprintDisplayTask` interface:
///   - `TaskItem` — a real task (already in storage). The full visual
///     elements apply.
///   - `TaskItemRecurPreview` — a forecast iteration (not yet persisted).
///     Same visual chrome, but fields like `displayPriority` aren't
///     available; we render the subset that the interface exposes.
///
/// The chrome helpers (`AreaStripe`, `PillView`, `pillContentFor*`,
/// `toneForCurrentState`, `displayDateType`, `pillLabelStyle`,
/// `pillValueStyle`) are imported from `editable_task_item.dart` so both
/// widgets stay visually synchronized as the design evolves.
class PlanTaskItemWidget extends StatelessWidget {
  final SprintDisplayTask sprintDisplayTask;
  final CheckCycleWaiter? onTaskCompleteToggle;
  final CheckCycleWaiter? onTaskAssignmentToggle;
  final DateTime? endDate;
  final CheckState? initialCheckState;
  final Sprint? sprint;
  final bool highlightSprint;

  const PlanTaskItemWidget({
    super.key,
    required this.sprintDisplayTask,
    this.endDate,
    this.sprint,
    required this.highlightSprint,
    this.onTaskCompleteToggle,
    this.onTaskAssignmentToggle,
    this.initialCheckState,
  });

  String _docId() => sprintDisplayTask.getSprintDisplayTaskKey();

  bool _isScheduled() => sprintDisplayTask.isScheduled();
  bool _isCompleted() => sprintDisplayTask.isCompleted();

  Color _cardSurfaceColor() {
    if (_isCompleted()) return TaskColors.cardCompletedTint;
    if (_isScheduled()) {
      return TaskColors.cardColor.withValues(alpha: 0.15);
    }
    return TaskColors.cardColor;
  }

  ShapeBorder _cardShape() {
    final radius = BorderRadius.circular(6.0);
    if (highlightSprint) {
      return RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: TaskColors.sprintColor, width: 1.0),
      );
    }
    if (_isScheduled()) {
      return RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: TaskColors.scheduledOutline, width: 1.0),
      );
    }
    return RoundedRectangleBorder(borderRadius: radius);
  }

  Color _stripeAreaColor() {
    // Plan rows don't go through the area-color provider (they may render
    // forecast previews that haven't been persisted yet); fall back to
    // a neutral hairline so the stripe still draws.
    return TaskColors.hairline;
  }

  /// Builds a `PillContent` for the date pill on the right of the title
  /// row. Reuses the same display-type / state-tone semantics as the main
  /// task card so a sprint-planning row reads identically to a list-row
  /// for the same task.
  PillContent? _pillContent() {
    final completed = sprintDisplayTask.isCompleted();
    if (completed) {
      final completionDate = sprintDisplayTask.completionDate;
      final relative = completionDate == null
          ? 'just now'
          : _shortRelativeFromNow(completionDate);
      return PillContent(
        label: 'COMPLETED',
        value: relative,
        bg: TaskColors.completedColor,
        border: TaskColors.completedBorder,
        fg: TaskColors.completedText,
      );
    }
    // For non-TaskItem display types (TaskItemRecurPreview), the
    // `displayDateType` helper takes a TaskItem; cast and fall through to
    // a simpler date-anchor lookup for previews.
    final task = sprintDisplayTask;
    TaskDateType? displayType;
    if (task is TaskItem) {
      displayType = displayDateType(task);
    } else {
      // Pick the highest-priority active date for the forecast.
      for (final t in TaskDateTypes.allTypes.reversed) {
        if (t.dateFieldGetter(task) != null) {
          displayType = t;
          break;
        }
      }
    }
    if (displayType == null) return null;
    final dateValue = displayType.dateFieldGetter(task);
    if (dateValue == null) return null;
    final relative = _formatRelative(dateValue);
    final displayTone = toneFor(displayType);
    final stateTone = task is TaskItem ? toneForCurrentState(task) : null;
    return PillContent(
      label: displayType.label.toUpperCase(),
      value: relative,
      bg: stateTone?.bg ?? Colors.transparent,
      border: stateTone?.border ?? TaskColors.hairline,
      fg: displayTone.fg,
      borderWidth: 2,
    );
  }

  String _formatRelative(DateTime dateTime) {
    final isPast = dateTime.isBefore(DateTime.now());
    final formatted = _shortRelativeFromNow(dateTime);
    if (formatted == 'just now') return formatted;
    return isPast ? '$formatted ago' : 'in $formatted';
  }

  String _shortRelativeFromNow(DateTime dateTime) {
    final raw =
        timeago.format(dateTime, locale: 'en_short', allowFromNow: true);
    final cleaned = raw.replaceAll(' ', '').replaceAll('~', '');
    return cleaned == 'now' ? 'just now' : cleaned;
  }

  Widget _checkbox() {
    if (onTaskAssignmentToggle == null || initialCheckState == null) {
      return const SizedBox.shrink();
    }
    final isRecurring = sprintDisplayTask.recurrence != null;
    return DelayedCheckbox(
      taskName: sprintDisplayTask.name,
      initialState: initialCheckState!,
      checkCycleWaiter: onTaskAssignmentToggle!,
      checkedColor: Colors.green,
      inactiveIcon: Icons.add,
      inactiveIconColor: isRecurring ? TaskColors.textFaint : null,
    );
  }

  Color? _stripeStateColor() {
    final task = sprintDisplayTask;
    if (task is TaskItem) {
      return toneForCurrentState(task)?.fg;
    }
    // Forecast previews don't have the full predicate set; fall back to
    // the highest-priority active date's fg colour.
    for (final t in TaskDateTypes.allTypes.reversed) {
      if (t == TaskDateTypes.start) continue;
      if (t.dateFieldGetter(task) != null) return t.textColor;
    }
    return null;
  }

  Widget _summaryRow(BuildContext context) {
    final pillContent = _pillContent();
    final pill = pillContent == null
        ? const SizedBox.shrink()
        : PillView(content: pillContent, docId: _docId());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      sprintDisplayTask.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: _isCompleted()
                            ? TaskColors.textFaint
                            : TaskColors.textPrimary,
                        decoration: _isCompleted()
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  pill,
                ],
              ),
              const SizedBox(height: 6),
              _metaRow(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: _checkbox(),
        ),
      ],
    );
  }

  Widget _metaRow() {
    final area = sprintDisplayTask.area;
    if ((area == null || area.isEmpty) && !highlightSprint) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (area != null && area.isNotEmpty) ...[
          Flexible(
            child: Text(
              area,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: TaskColors.textDim),
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (highlightSprint)
          Icon(
            Icons.assignment,
            color: TaskColors.sprintColor,
            size: 14,
            key: TaskMaestroKeys.editableTaskItemCardSprintIcon(_docId()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: TaskMaestroKeys.editableTaskItemCard(_docId()),
      color: _cardSurfaceColor(),
      shape: _cardShape(),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: Stack(
        children: [
          AreaStripe(
            areaColor: _stripeAreaColor(),
            stateColor: _stripeStateColor(),
            completed: _isCompleted(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
            child: _summaryRow(context),
          ),
        ],
      ),
    );
  }
}

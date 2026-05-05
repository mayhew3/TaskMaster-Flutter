import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Hide intl's `TextDirection` so the dart:ui enum (with .ltr/.rtl) wins
// for TextPainter measurements below.
import 'package:intl/intl.dart' hide TextDirection;
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/helpers/area_color_helper.dart';
import 'package:taskmaestro/helpers/recurrence_formatter.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/sprint.dart';
import '../../../models/task_item.dart';
import '../../../models/check_state.dart';
import 'delayed_checkbox.dart';

/// Pure presentational task card with an inline expand-for-detail panel.
///
/// Tapping the card body toggles the global `expandedTaskProvider` so only
/// one card is expanded at a time. The expanded panel surfaces the four
/// dates, recurrence, notes, and a single context — and a magenta Edit
/// button which the parent wires via [onEdit].
class EditableTaskItemWidget extends ConsumerWidget {
  final TaskItem taskItem;
  final CheckCycleWaiter? onTaskCompleteToggle;
  final ConfirmDismissCallback? onDismissed;
  final GestureLongPressCallback? onLongPress;
  final GestureForcePressStartCallback? onForcePress;
  final CheckState? initialCheckState;
  final Sprint? sprint;
  final bool highlightSprint;

  /// Pushed by the expanded panel's Edit button. When null, the Edit button
  /// is hidden.
  final VoidCallback? onEdit;

  const EditableTaskItemWidget({
    super.key,
    required this.taskItem,
    this.sprint,
    required this.highlightSprint,
    this.onTaskCompleteToggle,
    this.initialCheckState,
    this.onDismissed,
    this.onLongPress,
    this.onForcePress,
    this.onEdit,
  });

  String _docId() => taskItem.docId;

  bool get _isDone => taskItem.completionDate != null || taskItem.skipped;

  /// Scheduled = startDate is in the future and the task hasn't been
  /// finished yet. Mirrors the "hollow card" treatment from the
  /// pre-redesign widget so future-scheduled tasks read as not-yet-active.
  bool get _isScheduled => !_isDone && taskItem.isScheduled();

  Color _cardSurfaceColor() {
    if (_isDone) return TaskColors.cardCompletedTint;
    if (_isScheduled) {
      // Hollow effect: a touch of card tint over the screen background so
      // the card still has shape but reads as inactive.
      return TaskColors.cardColor.withValues(alpha: 0.15);
    }
    return TaskColors.cardColor;
  }

  Color _resolveAreaColor(WidgetRef ref) {
    final area = taskItem.area;
    if (area == null || area.isEmpty) {
      return AreaColorHelper.colorForArea(area);
    }
    final mapped = ref.watch(areaColorsProvider)[area.trim().toLowerCase()];
    return mapped ?? AreaColorHelper.colorForArea(area);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedDocId = ref.watch(expandedTaskProvider);
    final isExpanded = expandedDocId == _docId();
    final areaColor = _resolveAreaColor(ref);

    return Dismissible(
      key: TaskMaestroKeys.taskItem(_docId()),
      confirmDismiss: onDismissed,
      child: GestureDetector(
        onLongPress: onLongPress,
        onForcePressStart: onForcePress,
        child: Card(
          key: TaskMaestroKeys.editableTaskItemCard(_docId()),
          color: _cardSurfaceColor(),
          shape: _cardShape(),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: Stack(
            children: [
              _AreaStripe(areaColor: areaColor, completed: _isDone),
              Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow(context, ref, isExpanded, areaColor),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: isExpanded
                          ? _ExpandedPanel(
                              taskItem: taskItem,
                              onEdit: onEdit,
                              onCollapse: () => ref
                                  .read(expandedTaskProvider.notifier)
                                  .toggle(_docId()),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ShapeBorder _cardShape() {
    final radius = BorderRadius.circular(6.0);
    if (highlightSprint) {
      return RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: TaskColors.sprintColor, width: 1.0),
      );
    }
    if (_isScheduled) {
      return RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: TaskColors.scheduledOutline, width: 1.0),
      );
    }
    return RoundedRectangleBorder(borderRadius: radius);
  }

  Widget _summaryRow(
    BuildContext context,
    WidgetRef ref,
    bool isExpanded,
    Color areaColor,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          ref.read(expandedTaskProvider.notifier).toggle(_docId()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(context, isExpanded),
                const SizedBox(height: 6),
                _metaRow(areaColor),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (highlightSprint)
            Padding(
              padding: const EdgeInsets.only(top: 2.0, right: 4.0),
              child: Icon(
                Icons.assignment,
                color: TaskColors.sprintColor,
                size: 18,
                key: TaskMaestroKeys.editableTaskItemCardSprintIcon(_docId()),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: _checkbox(),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle() => TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: _isDone ? TaskColors.textFaint : TaskColors.textPrimary,
        decoration: _isDone ? TextDecoration.lineThrough : null,
        decorationColor: TaskColors.textFaint,
      );

  Widget _titleRow(BuildContext context, bool isExpanded) {
    final pillContent = _pillContentFor(taskItem);
    final pill = pillContent == null
        ? const SizedBox.shrink()
        : _PillView(content: pillContent, docId: _docId());
    final titleStyle = _titleStyle();

    // Collapsed mode: keep the original compact single-row layout — title
    // ellipsis + pill on the right.
    if (!isExpanded) {
      return _singleRowTitle(titleStyle, pill);
    }

    // Expanded mode: only break to a second row when the title actually
    // would have ellipsised. Pill stays right-aligned in either case.
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : double.infinity;
        if (pillContent == null || maxWidth.isInfinite) {
          return _singleRowTitle(titleStyle, pill);
        }

        final pillWidth = _measurePillWidth(pillContent, scaler);
        final titlePainter = TextPainter(
          text: TextSpan(text: taskItem.name, style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: 1,
        )..layout();

        final fitsOneRow = titlePainter.width <= maxWidth - pillWidth - spacing;
        if (fitsOneRow) {
          return _singleRowTitle(titleStyle, pill);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              taskItem.name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            const SizedBox(height: 5),
            Align(alignment: Alignment.centerRight, child: pill),
          ],
        );
      },
    );
  }

  Widget _singleRowTitle(TextStyle titleStyle, Widget pill) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            taskItem.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
        const SizedBox(width: 8),
        pill,
      ],
    );
  }

  Widget _metaRow(Color areaColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Expanded soaks up all remaining width so the right cluster sits
        // flush against the checkbox column. When area is null the inner
        // SizedBox.shrink leaves the space empty without disrupting alignment.
        Expanded(child: _areaLabel(areaColor)),
        _TimeBlock(durationMinutes: taskItem.duration),
        const SizedBox(width: 8),
        _PriorityBar(priority: taskItem.priority),
        const SizedBox(width: 8),
        _PointsCircle(points: taskItem.gamePoints),
      ],
    );
  }

  Widget _areaLabel(Color areaColor) {
    final area = taskItem.area;
    if (area == null || area.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      key: TaskMaestroKeys.editableTaskItemCardAreaField(_docId()),
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: areaColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            area,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: TaskColors.textDim),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _checkbox() {
    if (onTaskCompleteToggle == null) {
      return const SizedBox.shrink();
    }
    final completed = taskItem.completionDate != null;
    final pending = taskItem.pendingCompletion;
    final skipped = taskItem.skipped;
    final isRecurring = taskItem.recurrenceDocId != null;
    return DelayedCheckbox(
      taskName: taskItem.name,
      initialState: skipped
          ? CheckState.skipped
          : completed
              ? CheckState.checked
              : pending
                  ? CheckState.pending
                  : CheckState.inactive,
      checkCycleWaiter: onTaskCompleteToggle!,
      inactiveIcon: isRecurring ? Icons.autorenew : null,
      inactiveIconColor: isRecurring ? TaskColors.textFaint : null,
    );
  }
}

class _AreaStripe extends StatelessWidget {
  final Color areaColor;
  final bool completed;
  const _AreaStripe({required this.areaColor, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 3,
      child: Container(
        color: completed ? TaskColors.highlight : areaColor,
      ),
    );
  }
}

/// Tone triple for date pills; mirrors `DATE_TONES` in cards.jsx.
class _ToneTriple {
  final Color fg;
  final Color bg;
  final Color border;
  const _ToneTriple({required this.fg, required this.bg, required this.border});
}

_ToneTriple _toneFor(TaskDateType type) {
  if (type == TaskDateTypes.due) {
    return _ToneTriple(
        fg: TaskColors.dueText,
        bg: TaskColors.dueColor,
        border: TaskColors.dueBorder);
  }
  if (type == TaskDateTypes.urgent) {
    return _ToneTriple(
        fg: TaskColors.urgentText,
        bg: TaskColors.urgentColor,
        border: TaskColors.urgentBorder);
  }
  if (type == TaskDateTypes.target) {
    return _ToneTriple(
        fg: TaskColors.targetText,
        bg: TaskColors.targetColor,
        border: TaskColors.targetBorder);
  }
  return _ToneTriple(
      fg: TaskColors.startText,
      bg: TaskColors.scheduledColor,
      border: TaskColors.startBorder);
}

/// Pre-computed content for a date pill — built once so the title row can
/// both render it and measure its width without doing the work twice.
class _PillContent {
  final String label;
  final String value;
  final Color bg;
  final Color border;
  final Color fg;
  const _PillContent({
    required this.label,
    required this.value,
    required this.bg,
    required this.border,
    required this.fg,
  });
}

_PillContent? _pillContentFor(TaskItem taskItem) {
  final completed = taskItem.completionDate != null;
  final skipped = taskItem.skipped;
  if (completed || skipped) {
    final completionDate = taskItem.completionDate;
    final relative =
        completionDate == null ? 'just now' : _relativeFromNow(completionDate);
    return _PillContent(
      label: skipped ? 'SKIPPED' : 'COMPLETED',
      value: relative,
      bg: TaskColors.completedColor,
      border: TaskColors.completedBorder,
      fg: TaskColors.completedText,
    );
  }
  final displayType = _displayDateType(taskItem);
  if (displayType == null) return null;
  final relative = _relativeForAnchor(taskItem, displayType);
  if (relative == null) return null;
  // Text colour reflects the date type the pill names (the milestone the
  // user is reading); background colour reflects the task's current
  // state — i.e. the most recently crossed threshold. Matches the old
  // card-background semantics from the pre-redesign widget.
  final displayTone = _toneFor(displayType);
  final stateTone = _toneForCurrentState(taskItem);
  return _PillContent(
    label: displayType.label.toUpperCase(),
    value: relative,
    bg: stateTone?.bg ?? Colors.transparent,
    border: stateTone?.border ?? TaskColors.hairline,
    fg: displayTone.fg,
  );
}

/// Picks the date type to put in the pill label — the next upcoming
/// threshold within its display window, or, if none upcoming, the most
/// recently crossed threshold (excluding `start`, which doesn't carry
/// urgency once it's passed).
///
/// This is *not* the same as `DateHolder.getAnchorDateType()`: that returns
/// the highest-priority non-null date for recurrence anchoring, which is
/// the wrong choice for display when an earlier-priority date is the next
/// thing the user actually needs to act on. Mirrors the iteration order
/// from the pre-redesign widget's `_getDateWarnings()`.
TaskDateType? _displayDateType(TaskItem task) {
  for (final type in TaskDateTypes.allTypes) {
    if (type.inListBeforeDisplayThreshold(task)) return type;
  }
  for (final type in TaskDateTypes.allTypes.reversed) {
    if (type == TaskDateTypes.start) continue;
    if (type.inListAfterDisplayThreshold(task)) return type;
  }
  return null;
}

/// Returns the tone for the task's current state — i.e. the highest crossed
/// threshold. Mirrors the pre-redesign `getBackgroundColor()` semantics by
/// reusing `DateHolder`'s existing predicates so this stays a single
/// source of truth as the date model evolves.
_ToneTriple? _toneForCurrentState(TaskItem task) {
  if (task.isPastDue()) return _toneFor(TaskDateTypes.due);
  if (task.isUrgent()) return _toneFor(TaskDateTypes.urgent);
  if (task.isTarget()) return _toneFor(TaskDateTypes.target);
  if (task.isScheduled()) return _toneFor(TaskDateTypes.start);
  return null;
}

const TextStyle _pillLabelStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.4,
);
const TextStyle _pillValueStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
);

double _measurePillWidth(_PillContent content, TextScaler scaler) {
  final labelPainter = TextPainter(
    text: TextSpan(text: content.label, style: _pillLabelStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  final valuePainter = TextPainter(
    text: TextSpan(text: content.value, style: _pillValueStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  // 9px h padding × 2 + 5px gap + 1px border × 2.
  return labelPainter.width + valuePainter.width + 18 + 5 + 2;
}

class _PillView extends StatelessWidget {
  final _PillContent content;
  final String docId;
  const _PillView({required this.content, required this.docId});

  @override
  Widget build(BuildContext context) {
    final fadedLabelColor = content.fg.withValues(
      alpha: (content.fg.a * 0.85).clamp(0.0, 1.0),
    );
    return Container(
      key: TaskMaestroKeys.editableTaskItemDatePill(docId),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: content.bg,
        border: Border.all(color: content.border, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content.label,
            style: _pillLabelStyle.copyWith(color: fadedLabelColor),
          ),
          const SizedBox(width: 5),
          Text(
            content.value,
            style: _pillValueStyle.copyWith(color: content.fg),
          ),
        ],
      ),
    );
  }
}

String? _relativeForAnchor(TaskItem task, TaskDateType type) {
  final value = type.dateFieldGetter(task);
  if (value == null) return null;
  final isPast = value.isBefore(DateTime.now());
  final formatted = _shortRelative(value);
  if (formatted == 'now') return 'just now';
  return isPast ? '$formatted ago' : 'in $formatted';
}

String _relativeFromNow(DateTime dateTime) {
  final formatted = _shortRelative(dateTime);
  if (formatted == 'now') return 'just now';
  return dateTime.isBefore(DateTime.now())
      ? '$formatted ago'
      : 'in $formatted';
}

String _shortRelative(DateTime dateTime) {
  final raw = timeago.format(
    dateTime,
    locale: 'en_short',
    allowFromNow: true,
  );
  return raw.replaceAll(' ', '').replaceAll('~', '');
}

class _TimeBlock extends StatelessWidget {
  final int? durationMinutes;
  const _TimeBlock({required this.durationMinutes});

  @override
  Widget build(BuildContext context) {
    if (durationMinutes == null || durationMinutes! <= 0) {
      return const SizedBox.shrink();
    }
    final formatted = _formatTime(durationMinutes!);
    final fraction = _logTimeFraction(durationMinutes!);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatted,
          style: TextStyle(
            fontSize: 11.5,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: TaskColors.textDim,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 40,
          height: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.10)),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(color: TaskColors.startText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    if (minutes < 60 * 24) {
      final h = minutes / 60;
      return h == h.roundToDouble()
          ? '${h.round()}h'
          : '${h.toStringAsFixed(1)}h';
    }
    final d = minutes / (60 * 24);
    return d == d.roundToDouble()
        ? '${d.round()}d'
        : '${d.toStringAsFixed(1)}d';
  }

  /// Log scale: 5m≈0.05, 30m≈0.3, 1h≈0.4, 4h≈0.65, 1d≈0.85, 1w=1.0.
  double _logTimeFraction(int minutes) {
    final n = math.log(1 + minutes) / math.log(1 + 10080);
    if (n.isNaN || n.isInfinite) return 0.04;
    return n.clamp(0.04, 1.0);
  }
}

class _PriorityBar extends StatelessWidget {
  final int? priority;
  const _PriorityBar({required this.priority});

  @override
  Widget build(BuildContext context) {
    final filled = priority == null ? 0 : (priority! / 2).clamp(0, 5).round();
    Color barColor;
    if (filled >= 4) {
      barColor = const Color(0xFFFFA08C); // warm coral
    } else if (filled >= 3) {
      barColor = const Color(0xFFFFCE80); // warm yellow
    } else {
      barColor = TaskColors.startText; // neutral lavender
    }
    final isNull = priority == null;
    final outline = Colors.white.withValues(alpha: 0.32);
    final emptyFill = Colors.white.withValues(alpha: 0.14);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final on = i < filled;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
          child: Container(
            width: 5,
            height: 8,
            decoration: BoxDecoration(
              color: on
                  ? barColor
                  : (isNull ? Colors.transparent : emptyFill),
              border: (!on && isNull)
                  ? Border.all(color: outline, width: 0.8)
                  : null,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}

class _PointsCircle extends StatelessWidget {
  final int? points;
  const _PointsCircle({required this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 22,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.32),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          points?.toString() ?? '—',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: points == null ? TaskColors.textFaint : TaskColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  final TaskItem taskItem;
  final VoidCallback? onEdit;
  final VoidCallback onCollapse;
  const _ExpandedPanel({
    required this.taskItem,
    required this.onCollapse,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateRows = _dateRows();
    final repeat = RecurrenceFormatter.format(
      recurNumber: taskItem.recurNumber,
      recurUnit: taskItem.recurUnit,
      recurWait: taskItem.recurWait,
    );
    final notes = taskItem.description;
    final ctx = taskItem.context;

    final hasContent = dateRows.isNotEmpty ||
        (repeat != null) ||
        (notes != null && notes.isNotEmpty) ||
        (ctx != null && ctx.isNotEmpty);

    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return Container(
      key: TaskMaestroKeys.editableTaskItemExpandedPanel(taskItem.docId),
      margin: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dateRows.isNotEmpty) _dateGrid(dateRows),
          if (ctx != null && ctx.isNotEmpty)
            _ExpandedRow(label: 'CONTEXT', value: ctx),
          if (repeat != null) _ExpandedRow(label: 'REPEAT', value: repeat),
          if (notes != null && notes.isNotEmpty)
            _ExpandedRow(label: 'NOTES', value: notes),
          if (onEdit != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_editButton()],
            ),
          ],
        ],
      ),
    );
  }

  List<_DateCell> _dateRows() {
    final rows = <_DateCell>[];
    void add(TaskDateType type) {
      final v = type.dateFieldGetter(taskItem);
      if (v == null) return;
      rows.add(_DateCell(
        label: type.label.toUpperCase(),
        absolute: DateFormat.MMMMd().format(v.toLocal()),
        relative: _relativeFromNow(v),
        color: _toneFor(type).fg,
      ));
    }

    add(TaskDateTypes.start);
    add(TaskDateTypes.target);
    add(TaskDateTypes.urgent);
    add(TaskDateTypes.due);
    return rows;
  }

  Widget _dateGrid(List<_DateCell> cells) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 2) {
      final left = cells[i];
      final right = i + 1 < cells.length ? cells[i + 1] : null;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _dateCellWidget(left)),
          const SizedBox(width: 16),
          Expanded(
            child: right != null
                ? _dateCellWidget(right)
                : const SizedBox.shrink(),
          ),
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _dateCellWidget(_DateCell cell) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TaskColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                cell.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: TaskColors.textFaint,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cell.absolute,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: cell.color,
                    height: 1.35,
                  ),
                ),
                Text(
                  cell.relative,
                  style: TextStyle(
                    fontSize: 11,
                    color: TaskColors.textFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editButton() {
    return ElevatedButton.icon(
      key: TaskMaestroKeys.editableTaskItemEditButton(taskItem.docId),
      onPressed: onEdit,
      icon: const Icon(Icons.edit, size: 14, color: Colors.white),
      label: const Text('Edit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: TaskColors.highlight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 2,
      ),
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  final String label;
  final String value;
  const _ExpandedRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: TaskColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: TaskColors.textFaint,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                color: TaskColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCell {
  final String label;
  final String absolute;
  final String relative;
  final Color color;
  const _DateCell({
    required this.label,
    required this.absolute,
    required this.relative,
    required this.color,
  });
}

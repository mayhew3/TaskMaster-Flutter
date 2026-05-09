import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaestro/date_util.dart';
import 'package:taskmaestro/features/areas/providers/area_color_providers.dart';
import 'package:taskmaestro/features/tasks/providers/expanded_task_provider.dart';
import 'package:taskmaestro/helpers/area_color_helper.dart';
import 'package:taskmaestro/helpers/recurrence_formatter.dart';
import 'package:taskmaestro/keys.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/task_item.dart';
import '../../../models/check_state.dart';
import '../../tasks/presentation/recurrence_detail_screen.dart';
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
  final ConfirmDismissCallback? confirmDismiss;
  final GestureLongPressCallback? onLongPress;
  final GestureForcePressStartCallback? onForcePress;
  final bool highlightSprint;

  /// Pushed by the expanded panel's Edit button. When null, the Edit button
  /// is hidden.
  final VoidCallback? onEdit;

  /// When non-null, called instead of the standard `pillContentFor` to
  /// resolve the date pill's content. Lets callers override the pill's
  /// label / value / colours — e.g. `PlanTaskItemWidget` projects the
  /// pill against its sprint's `endDate` so it reads "DUE in 5d" rather
  /// than "TARGET in 4d" when both dates fall inside the sprint horizon.
  /// Returning `null` from the override hides the pill (same as the
  /// default path returning `null`).
  final PillContent? Function(TaskItem)? pillContentOverride;

  /// When non-null, called instead of the standard `stripeColorForTask`
  /// to resolve the left stripe colour. Lets callers project the stripe
  /// against an alternative time horizon (e.g. sprint planning's
  /// `endDate`). Returning `null` falls through to the area colour.
  final Color? Function(TaskItem)? stripeColorOverride;

  /// When non-null, replaces the default trailing widget (the
  /// completion-toggle checkbox bound to [onTaskCompleteToggle]).
  /// `PlanTaskItemWidget` uses this to render an *assignment*-toggle
  /// checkbox instead.
  final Widget Function()? trailingBuilder;

  /// `false` removes the outer `Dismissible` wrapper. Plan-mode rows
  /// shouldn't be swipe-deletable since the gesture there is "add to
  /// sprint", not "delete task".
  final bool enableDismissible;

  const EditableTaskItemWidget({
    super.key,
    required this.taskItem,
    required this.highlightSprint,
    this.onTaskCompleteToggle,
    this.confirmDismiss,
    this.onLongPress,
    this.onForcePress,
    this.onEdit,
    this.pillContentOverride,
    this.stripeColorOverride,
    this.trailingBuilder,
    this.enableDismissible = true,
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

    // Scroll the card fully into view when it expands, but ONLY if the
    // expanded bottom would otherwise be off-screen. AnimatedSize plays
    // for 100ms (see below); we wait ~80ms past that so the render
    // object reliably reflects the post-expand bounds when ensureVisible
    // measures (a tighter window made the scroll fire mid-animation
    // ~75% of the time, against pre-expand bounds, and silently no-op).
    // `keepVisibleAtEnd` means we only scroll down enough to bring the
    // bottom into view; cards already fully visible aren't disturbed.
    ref.listen<String?>(expandedTaskProvider, (prev, next) {
      if (next == _docId() && prev != _docId()) {
        Future.delayed(const Duration(milliseconds: 180), () {
          if (!context.mounted) return;
          // Re-validate inside the delayed callback: within the 180ms
          // window the user might have collapsed this card or expanded
          // a different one, in which case the scroll-into-view here
          // would be a surprise. Bail unless this card is still the
          // active one when the timer fires.
          if (ref.read(expandedTaskProvider) != _docId()) return;
          final ro = context.findRenderObject();
          if (ro == null) return;
          Scrollable.maybeOf(context)?.position.ensureVisible(
                ro,
                alignmentPolicy:
                    ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeInOut,
              );
        });
      }
    });

    final card = GestureDetector(
      onLongPress: onLongPress,
      onForcePressStart: onForcePress,
      child: Card(
        key: TaskMaestroKeys.editableTaskItemCard(_docId()),
        color: _cardSurfaceColor(),
        shape: _cardShape(),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        child: Stack(
          children: [
            AreaStripe(
              areaColor: areaColor,
              stateColor:
                  stripeColorOverride?.call(taskItem) ??
                      stripeColorForTask(taskItem),
              completed: _isDone,
            ),
            Padding(
              // Card-internal padding tuned for visual balance between
              // the title row and the meta row:
              //   - top 8: the title row's `ConstrainedBox(minHeight:22)`
              //     plus this padding gives the title text ~11-12px of
              //     space above its glyphs (8 padding + 3-4 row-internal
              //     space above the bottom-aligned text).
              //   - bottom 6: tightened from 10 so the meta row doesn't
              //     leave a noticeable empty band at the card's bottom.
              padding: const EdgeInsets.fromLTRB(14.0, 8.0, 10.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(context, ref, isExpanded, areaColor),
                  AnimatedSize(
                    // Tighter expand/collapse cadence — the original
                    // 200ms felt sluggish once we started chaining a
                    // post-animation scroll-into-view on top of it.
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: isExpanded
                        ? ExpandedPanel(
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
    );

    if (!enableDismissible) return card;
    return Dismissible(
      key: TaskMaestroKeys.taskItem(_docId()),
      confirmDismiss: confirmDismiss,
      child: card,
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
    // Avoid making a card tappable when expanding it would render nothing —
    // tapping such a card would silently collapse another open card without
    // any visible affordance, which feels broken.
    final canExpand = hasExpandableContent(taskItem, hasOnEdit: onEdit != null);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canExpand
          ? () => ref.read(expandedTaskProvider.notifier).toggle(_docId())
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(context, isExpanded),
                // Tight gap (was 6) so the title + meta read as a
                // single content block rather than two separated rows.
                const SizedBox(height: 4),
                _metaRow(areaColor, isExpanded),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            // `trailingBuilder` lets plan-mode rows substitute an
            // assignment-toggle checkbox for the default
            // completion-toggle. Falls through to the standard
            // `_checkbox()` when no override is supplied.
            child: trailingBuilder?.call() ?? _checkbox(),
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
    final pillContent =
        pillContentOverride?.call(taskItem) ?? pillContentFor(taskItem);
    final pill = pillContent == null
        ? const SizedBox.shrink()
        : PillView(content: pillContent, docId: _docId());
    final titleStyle = _titleStyle();

    // Collapsed mode: keep the original compact single-row layout — title
    // ellipsis + pill on the right.
    if (!isExpanded) {
      return _singleRowTitle(titleStyle, pill, pillContent != null);
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
          return _singleRowTitle(titleStyle, pill, pillContent != null);
        }

        final pillWidth = _measurePillWidth(pillContent, scaler);
        final titlePainter = TextPainter(
          text: TextSpan(text: taskItem.name, style: titleStyle),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: 1,
        )..layout();

        // Subtract a small epsilon so titles whose measured width lands
        // within ~1px of the available space still wrap. TextPainter's
        // `width` and the rendered Text widget's available space disagree
        // by sub-pixel rounding in practice, which previously left near-
        // edge titles ellipsised on a single row when wrapping would have
        // shown the whole title (TM-357 truncation-detection bug).
        const epsilon = 2.0;
        final fitsOneRow =
            titlePainter.width <= maxWidth - pillWidth - spacing - epsilon;
        if (fitsOneRow) {
          // Inside this branch pillContent is guaranteed non-null
          // (the `pillContent == null` case returned early above).
          return _singleRowTitle(titleStyle, pill, true);
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

  Widget _singleRowTitle(
      TextStyle titleStyle, Widget pill, bool hasPill) {
    // Minimum row height = pill's natural height (22px) when a pill is
    // rendered; +2px (24px) when there isn't one, to give pill-less
    // cards an extra sliver of breathing room above the title since
    // the pill normally provides that visual lead-in itself.
    final minHeight = hasPill ? 22.0 : 24.0;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        // The title's glyph baseline + descender space sit *above* the
        // text widget's layout-box bottom by ~3-4px; without the
        // `TextHeightBehavior` override below, `CrossAxisAlignment.end`
        // would line up the layout boxes but the visible text would
        // still float higher than the visible pill bottom. Disabling the
        // last-descent height makes the layout box hug the glyphs, so
        // "bottom of text box" == "bottom of visible text" == "bottom
        // of pill" once they're all `end`-aligned.
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              taskItem.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToLastDescent: false,
              ),
            ),
          ),
          const SizedBox(width: 8),
          pill,
        ],
      ),
    );
  }

  Widget _metaRow(Color areaColor, bool isExpanded) {
    return Row(
      // `center` keeps each meta-cell vertically centered against the
      // others — the indicators (priority bar, points circle, time block)
      // have slightly different intrinsic heights, so anchoring at top
      // would visually push the priority bar above the time text.
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Expanded soaks up all remaining width so the right cluster sits
        // flush against the checkbox column. When area is null the inner
        // SizedBox.shrink leaves the space empty without disrupting alignment.
        Expanded(child: _areaLabel(areaColor)),
        MetaCell(
          isExpanded: isExpanded,
          subtitle: 'Length',
          child: TimeBlock(durationMinutes: taskItem.duration),
        ),
        const SizedBox(width: 8),
        // Use the scale-aware getter so legacy 1-10 rows still render the
        // same number of fills they did before TM-358, while migrated 1-5
        // rows render their value directly. See TaskItem.displayPriority.
        MetaCell(
          isExpanded: isExpanded,
          subtitle: 'Priority',
          child: PriorityBar(filled: taskItem.displayPriority ?? 0),
        ),
        const SizedBox(width: 8),
        MetaCell(
          isExpanded: isExpanded,
          subtitle: 'Pts',
          child: PointsCircle(points: taskItem.gamePoints),
        ),
      ],
    );
  }

  Widget _areaLabel(Color areaColor) {
    final area = taskItem.area;
    final showSprintIcon = highlightSprint;
    if ((area == null || area.isEmpty) && !showSprintIcon) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      key: TaskMaestroKeys.editableTaskItemCardAreaField(_docId()),
      children: [
        if (area != null && area.isNotEmpty) ...[
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
          const SizedBox(width: 6),
        ],
        // Sprint badge moved here from `_summaryRow` (TM-357 #4): the row's
        // dedicated icon column was removed so the indicator now lives
        // alongside the area label, where it reads as part of the task's
        // categorical metadata rather than a separate column.
        if (showSprintIcon)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              Icons.assignment,
              color: TaskColors.sprintColor,
              size: 14,
              key: TaskMaestroKeys.editableTaskItemCardSprintIcon(_docId()),
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

class AreaStripe extends StatelessWidget {
  final Color areaColor;
  final Color? stateColor;
  final bool completed;
  const AreaStripe({
    required this.areaColor,
    required this.stateColor,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    // Stripe priority: completed → highlight; otherwise the most-recently-
    // crossed-threshold colour (Target / Urgent / Due) when one applies,
    // falling through to the area colour for tasks with no relevant date
    // state. The state-derived colour matches the date pill foreground so
    // the stripe and pill read as a single visual cue.
    final Color color;
    if (completed) {
      color = TaskColors.highlight;
    } else if (stateColor != null) {
      color = stateColor!;
    } else {
      color = areaColor;
    }
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 3,
      child: Container(color: color),
    );
  }
}

/// Wraps a meta-row cell ([TimeBlock] / [PriorityBar] / [PointsCircle])
/// with an optional small text subtitle ("Length" / "Priority" / "Pts")
/// rendered beneath it when the card is expanded.
///
/// In *expanded* mode the indicator portion is held to the height of the
/// tallest indicator (the points circle, 22px) — every cell gets the
/// same height, so all three sit on a common baseline and the subtitles
/// underneath align consistently. The indicator itself is never resized;
/// shorter indicators just float vertically inside a taller box.
///
/// In *collapsed* mode the cell is just the indicator at its intrinsic
/// height; the row's centre alignment then balances the three different
/// natural heights around a shared centreline (the original behaviour
/// from before the subtitle feature was added).
class MetaCell extends StatelessWidget {
  final Widget child;
  final String subtitle;
  final bool isExpanded;
  const MetaCell({
    required this.child,
    required this.subtitle,
    required this.isExpanded,
  });

  /// Matches the tallest indicator in the meta row (the 22px-tall
  /// [PointsCircle]) so no indicator gets visually clipped or shrunk.
  static const double _expandedIndicatorHeight = 22;

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: _expandedIndicatorHeight,
          child: Center(child: child),
        ),
        Text(
          subtitle,
          // `height: 1.0` collapses the default 1.2× line-box so the
          // subtitle text doesn't carry a few pixels of empty space
          // above/below its glyphs — without it, the row reads as if
          // a second invisible line were hiding beneath each subtitle.
          style: TextStyle(
            fontSize: 9,
            height: 1.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: TaskColors.textFaint,
          ),
        ),
      ],
    );
  }
}

/// Tone triple for date pills; mirrors `DATE_TONES` in cards.jsx.
class ToneTriple {
  final Color fg;
  final Color bg;
  final Color border;
  const ToneTriple({required this.fg, required this.bg, required this.border});
}

ToneTriple toneFor(TaskDateType type) {
  if (type == TaskDateTypes.due) {
    return ToneTriple(
        fg: TaskColors.dueText,
        bg: TaskColors.dueColor,
        border: TaskColors.dueBorder);
  }
  if (type == TaskDateTypes.urgent) {
    return ToneTriple(
        fg: TaskColors.urgentText,
        bg: TaskColors.urgentColor,
        border: TaskColors.urgentBorder);
  }
  if (type == TaskDateTypes.target) {
    return ToneTriple(
        fg: TaskColors.targetText,
        bg: TaskColors.targetColor,
        border: TaskColors.targetBorder);
  }
  return ToneTriple(
      fg: TaskColors.startText,
      bg: TaskColors.scheduledColor,
      border: TaskColors.startBorder);
}

/// Pre-computed content for a date pill — built once so the title row can
/// both render it and measure its width without doing the work twice.
class PillContent {
  final String label;
  final String value;
  final Color bg;
  final Color border;
  final Color fg;
  final double borderWidth;
  const PillContent({
    required this.label,
    required this.value,
    required this.bg,
    required this.border,
    required this.fg,
    this.borderWidth = 1,
  });
}

PillContent? pillContentFor(TaskItem taskItem) {
  final completed = taskItem.completionDate != null;
  final skipped = taskItem.skipped;
  if (completed || skipped) {
    final completionDate = taskItem.completionDate;
    final relative =
        completionDate == null ? 'just now' : _relativeFromNow(completionDate);
    return PillContent(
      label: skipped ? 'SKIPPED' : 'COMPLETED',
      value: relative,
      bg: TaskColors.completedColor,
      border: TaskColors.completedBorder,
      fg: TaskColors.completedText,
    );
  }
  final displayType = displayDateType(taskItem);
  if (displayType == null) return null;
  final relative = _relativeForAnchor(taskItem, displayType);
  if (relative == null) return null;
  // Text colour reflects the date type the pill names (the milestone the
  // user is reading); background colour reflects the task's current
  // state — i.e. the most recently crossed threshold. Matches the old
  // card-background semantics from the pre-redesign widget.
  final displayTone = toneFor(displayType);
  final stateTone = toneForCurrentState(taskItem);
  return PillContent(
    label: displayType.label.toUpperCase(),
    value: relative,
    bg: stateTone?.bg ?? Colors.transparent,
    border: stateTone?.border ?? TaskColors.hairline,
    fg: displayTone.fg,
    // Date pills (TARGET / URGENT / DUE / START) carry a thicker border
    // than the COMPLETED / SKIPPED variants so the active deadline reads
    // as a louder visual cue at a glance.
    borderWidth: 2,
  );
}

/// True when expanding [task] would render something — used by the
/// summary-row tap handler to gate the expand toggle so empty cards
/// without an Edit button don't become invisible tap targets that
/// collapse other open cards.
bool hasExpandableContent(TaskItem task, {required bool hasOnEdit}) {
  if (hasOnEdit) return true;
  if (task.startDate != null) return true;
  if (task.targetDate != null) return true;
  if (task.urgentDate != null) return true;
  if (task.dueDate != null) return true;
  if (RecurrenceFormatter.format(
        recurNumber: task.recurNumber ?? task.recurrence?.recurNumber,
        recurUnit: task.recurUnit ?? task.recurrence?.recurUnit,
        recurWait: task.recurWait ?? task.recurrence?.recurWait,
      ) !=
      null) {
    return true;
  }
  final notes = task.description;
  if (notes != null && notes.isNotEmpty) return true;
  final ctx = task.context;
  if (ctx != null && ctx.isNotEmpty) return true;
  return false;
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
TaskDateType? displayDateType(TaskItem task) {
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
ToneTriple? toneForCurrentState(TaskItem task) {
  if (task.isPastDue()) return toneFor(TaskDateTypes.due);
  if (task.isUrgent()) return toneFor(TaskDateTypes.urgent);
  if (task.isTarget()) return toneFor(TaskDateTypes.target);
  if (task.isScheduled()) return toneFor(TaskDateTypes.start);
  return null;
}

/// Saturated stripe colour for [task] based on its highest crossed
/// threshold. Distinct from the pill's pale `*Text` foreground colours,
/// which were tuned to read as a soft accent inside a coloured pill on
/// the dark card; the 3px stripe needs more saturation to stay visually
/// distinct between adjacent date types (Target vs Urgent vs Due).
/// Returns `null` when no relevant threshold is crossed, so the caller
/// can fall through to the area colour.
Color? stripeColorForTask(TaskItem task) {
  if (task.isPastDue()) return TaskColors.dueStripe;
  if (task.isUrgent()) return TaskColors.urgentStripe;
  if (task.isTarget()) return TaskColors.targetStripe;
  if (task.isScheduled()) return TaskColors.startStripe;
  return null;
}

const TextStyle pillLabelStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.4,
);
const TextStyle pillValueStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
);

double _measurePillWidth(PillContent content, TextScaler scaler) {
  final labelPainter = TextPainter(
    text: TextSpan(text: content.label, style: pillLabelStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  final valuePainter = TextPainter(
    text: TextSpan(text: content.value, style: pillValueStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  // 9px h padding × 2 + 5px gap + borderWidth × 2.
  return labelPainter.width +
      valuePainter.width +
      18 +
      5 +
      content.borderWidth * 2;
}

class PillView extends StatelessWidget {
  final PillContent content;
  final String docId;
  const PillView({required this.content, required this.docId});

  @override
  Widget build(BuildContext context) {
    final fadedLabelColor = content.fg.withValues(
      alpha: (content.fg.a * 0.85).clamp(0.0, 1.0),
    );
    return Container(
      key: TaskMaestroKeys.editableTaskItemDatePill(docId),
      // Vertical padding intentionally tighter than horizontal: the
      // thicker (2px) border on date pills already adds ~2px to the
      // overall height, so nudging the inner padding down keeps the pill
      // visually aligned with the title text on the same row instead of
      // pushing the meta row a couple pixels lower.
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: content.bg,
        border: Border.all(color: content.border, width: content.borderWidth),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content.label,
            style: pillLabelStyle.copyWith(color: fadedLabelColor),
          ),
          const SizedBox(width: 5),
          Text(
            content.value,
            style: pillValueStyle.copyWith(color: content.fg),
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

/// Long-form relative time for the expanded detail panel (e.g. "In 23 hours",
/// "a month ago"). The pill in the summary row uses `_shortRelative` instead;
/// we have more horizontal room when expanded so the readable form fits.
String _relativeLong(DateTime dateTime) {
  final raw = timeago.format(dateTime, allowFromNow: true);
  if (raw.isEmpty) return raw;
  return raw[0].toUpperCase() + raw.substring(1);
}

class TimeBlock extends StatelessWidget {
  final int? durationMinutes;
  const TimeBlock({required this.durationMinutes});

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

class PriorityBar extends StatelessWidget {
  /// Number of bars to fill (0–5). Caller is responsible for normalizing
  /// raw priority values via `TaskItem.displayPriority` so this widget
  /// stays scale-agnostic.
  final int filled;
  const PriorityBar({required this.filled});

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (filled >= 4) {
      barColor = const Color(0xFFFFA08C); // warm coral
    } else if (filled >= 3) {
      barColor = const Color(0xFFFFCE80); // warm yellow
    } else {
      barColor = TaskColors.startText; // neutral lavender
    }
    final isNull = filled == 0;
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

class PointsCircle extends StatelessWidget {
  final int? points;
  const PointsCircle({required this.points});

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

class ExpandedPanel extends StatelessWidget {
  final TaskItem taskItem;
  final VoidCallback? onEdit;
  final VoidCallback onCollapse;
  const ExpandedPanel({
    required this.taskItem,
    required this.onCollapse,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateRows = _dateRows();
    // Recurrence rule fields can live on the TaskItem itself or on the
    // linked TaskRecurrence — fall back the same way the rest of the
    // codebase does (see task_completion_service.dart) so recurring tasks
    // whose rule lives on the recurrence doc still surface a REPEAT row.
    final repeat = RecurrenceFormatter.format(
      recurNumber: taskItem.recurNumber ?? taskItem.recurrence?.recurNumber,
      recurUnit: taskItem.recurUnit ?? taskItem.recurrence?.recurUnit,
      recurWait: taskItem.recurWait ?? taskItem.recurrence?.recurWait,
    );
    final notes = taskItem.description;
    final ctx = taskItem.context;

    final bool hasDetailContent = dateRows.isNotEmpty ||
        (repeat != null) ||
        (notes != null && notes.isNotEmpty) ||
        (ctx != null && ctx.isNotEmpty);

    // Render the panel when there's either detail content OR an edit
    // affordance. A sparse task (no dates / notes / context / recurrence)
    // owned by the user still expands so they can reach the Edit button.
    if (!hasDetailContent && onEdit == null) {
      return const SizedBox.shrink();
    }

    // Tap anywhere on the expanded panel (other than the Edit button,
    // which has its own onPressed and swallows the tap) to collapse —
    // matches the design's onClick-to-dismiss affordance.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCollapse,
      child: Container(
        key: TaskMaestroKeys.editableTaskItemExpandedPanel(taskItem.docId),
        margin: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dateRows.isNotEmpty) _dateGrid(dateRows),
            if (ctx != null && ctx.isNotEmpty)
              _ExpandedRow(label: 'CONTEXT', value: ctx),
            if (repeat != null)
              _ExpandedRow(
                label: 'REPEAT',
                value: repeat,
                // Only wire the link when we have a recurrenceDocId to push
                // — non-recurring rules with inline recurNumber/recurUnit
                // don't have a history page to land on.
                onTap: taskItem.recurrenceDocId != null
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecurrenceDetailScreen(
                              recurrenceDocId: taskItem.recurrenceDocId!,
                              recurrenceName: taskItem.name,
                            ),
                          ),
                        )
                    : null,
              ),
            if (notes != null && notes.isNotEmpty)
              _ExpandedRow(label: 'NOTES', value: notes),
            if (onEdit != null) ...[
              SizedBox(height: hasDetailContent ? 8 : 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_editButton()],
              ),
            ],
          ],
        ),
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
        // Use the year-eliding helper so dates in other years surface
        // their year ("April 18, 2025") while same-year dates stay
        // compact ("April 18").
        absolute: DateUtil.formatMonthDayMaybeYearLong(v),
        // Long form (e.g. "In 23 hours", "a month ago") for the
        // expanded panel — the summary pill uses _shortRelative.
        relative: _relativeLong(v),
        color: toneFor(type).fg,
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

  /// When set, an icon button (history list) appears at the right end of
  /// the row that fires this callback. Used by the REPEAT row to navigate
  /// to the recurrence-history screen. The value text itself stays
  /// readable in the standard primary colour — the icon is the affordance,
  /// not the text.
  final VoidCallback? onTap;

  const _ExpandedRow({
    required this.label,
    required this.value,
    this.onTap,
  });

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
          if (onTap != null)
            // Tooltip-wrapped InkWell instead of IconButton: IconButton's
            // built-in 28px min-height pushed the icon visibly below the
            // row's top hairline. A tight 2px padding keeps the icon
            // close to the label baseline so it reads as part of the
            // REPEAT row rather than floating beneath it.
            Tooltip(
              message: 'Recurrence history',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.format_list_bulleted,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
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

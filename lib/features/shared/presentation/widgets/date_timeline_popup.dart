import 'package:flutter/material.dart';
import 'package:taskmaestro/date_util.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';

/// Default date for a newly-added date type in the timeline popup, computed
/// so it lands inside the chronologically-allowed range:
///   - **both bounds set** → midpoint (in whole days, truncated toward
///     `lower`) between the latest earlier date and the earliest later
///     date
///   - **only lower bound** (earlier types set) → `lower + 5 days`
///   - **only upper bound** (later types set) → `upper − 5 days`
///   - **neither** → [todayProvider] called for "today" (defaults to
///     `DateTime.now`, overridable for tests)
///
/// The result is always normalized to 9:00 AM. This replaces an earlier
/// heuristic that added a fixed offset per type position; that broke when
/// types were added out of order (e.g. adding Start last when Target,
/// Urgent, and Due already existed placed Start AFTER all of them).
DateTime defaultDateForNewType({
  required TaskDateType type,
  required Map<TaskDateType, DateTime?> dates,
  DateTime Function()? todayProvider,
}) {
  final allTypes = TaskDateTypes.allTypes;
  final selfIdx = allTypes.indexOf(type);

  DateTime? lower; // latest of earlier types
  for (var i = 0; i < selfIdx; i++) {
    final d = dates[allTypes[i]];
    if (d != null && (lower == null || d.isAfter(lower))) lower = d;
  }
  DateTime? upper; // earliest of later types
  for (var i = selfIdx + 1; i < allTypes.length; i++) {
    final d = dates[allTypes[i]];
    if (d != null && (upper == null || d.isBefore(upper))) upper = d;
  }

  DateTime base;
  if (lower != null && upper != null) {
    final lowerDay = DateTime(lower.year, lower.month, lower.day);
    final upperDay = DateTime(upper.year, upper.month, upper.day);
    final daysDiff = upperDay.difference(lowerDay).inDays;
    if (daysDiff < 0) {
      // Inconsistent legacy data: an "earlier" type is set after a "later"
      // type (e.g. Start after Due). Midpoint math would produce a date
      // below `lower` and outside any sensible interval. Fall through to
      // the today-based default so the popup is still usable for the user
      // to repair the inconsistency by editing one of the offending dates.
      final now = (todayProvider ?? DateTime.now)();
      base = DateTime(now.year, now.month, now.day);
    } else {
      base = lowerDay.add(Duration(days: daysDiff ~/ 2));
    }
  } else if (lower != null) {
    base = DateTime(lower.year, lower.month, lower.day)
        .add(const Duration(days: 5));
  } else if (upper != null) {
    base = DateTime(upper.year, upper.month, upper.day)
        .subtract(const Duration(days: 5));
  } else {
    final now = (todayProvider ?? DateTime.now)();
    base = DateTime(now.year, now.month, now.day);
  }
  return DateTime(base.year, base.month, base.day, 9);
}

/// Greedy lane assignment for timeline markers, with optional priority.
///
/// Returns one lane index per input marker (parallel list). Lane 0 is
/// rendered closest to the track in [_Timeline]; higher lane numbers stack
/// upward with longer connector lines.
///
/// When [priorities] is supplied, markers are placed in priority-DESCENDING
/// order so higher-priority markers land in lower lanes. This is what makes
/// the timeline display top-down by date type (Start = priority 0 → top,
/// Due = priority 3 → bottom near the track) when markers collide. When
/// [priorities] is null, markers are placed in input order (which the
/// caller is expected to have sorted by x).
///
/// Two markers collide when `(x_a - x_b).abs() < markerWidth + minGap`.
List<int> assignTimelineLanes(
  List<double> xs, {
  List<int>? priorities,
  required double markerWidth,
  required double minGap,
}) {
  final n = xs.length;
  if (n == 0) return const [];
  assert(priorities == null || priorities.length == n,
      'priorities length must match xs');
  final result = List<int>.filled(n, 0);

  // Iteration order: by priority descending, with input order as the
  // tie-breaker. With null priorities (or all-equal), input order wins.
  final order = List.generate(n, (i) => i);
  if (priorities != null) {
    order.sort((a, b) {
      final cmp = priorities[b].compareTo(priorities[a]);
      if (cmp != 0) return cmp;
      return a.compareTo(b);
    });
  }

  // Per-lane list of indices already placed there. O(n²) check per insert,
  // fine for n ≤ a handful of markers.
  final lanes = <List<int>>[];
  final threshold = markerWidth + minGap;
  for (final idx in order) {
    final x = xs[idx];
    var laneIdx = -1;
    for (var i = 0; i < lanes.length; i++) {
      var fits = true;
      for (final existingIdx in lanes[i]) {
        if ((x - xs[existingIdx]).abs() < threshold) {
          fits = false;
          break;
        }
      }
      if (fits) {
        laneIdx = i;
        break;
      }
    }
    if (laneIdx == -1) {
      laneIdx = lanes.length;
      lanes.add([idx]);
    } else {
      lanes[laneIdx].add(idx);
    }
    result[idx] = laneIdx;
  }
  return result;
}

/// Modal bottom-sheet popup for editing the start/target/urgent/due dates of
/// a task. Renders:
///   1. A horizontal timeline with a marker per set date (snaps with the
///      date-type accent color).
///   2. A row of `+ Add` pills for unset dates (creates a default date for
///      that type).
///   3. When a marker is selected, an inline calendar + time-bucket picker +
///      Remove button so the user can edit or clear that single date.
///
/// **Deferred-commit model.** Edits update a local working copy only; the
/// parent's [onChanged] is NOT called until the user taps **Save** in the
/// header, at which point the popup diffs against the snapshot taken at
/// open and emits one `onChanged(type, value)` per changed type. Tapping
/// **Cancel**, the system back gesture, or swiping the sheet down all
/// discard pending edits without invoking [onChanged]. Save is auto-
/// disabled when the working copy matches the snapshot.
class DateTimelinePopup extends StatefulWidget {
  final Map<TaskDateType, DateTime?> dates;
  final void Function(TaskDateType type, DateTime? value) onChanged;

  /// Whether the popup and its nested pickers target the root navigator.
  /// `true` (default) preserves the full-screen editor behavior. The
  /// docked editor pane (TM-384) passes `false` so the popup, its
  /// month/year sub-sheet, and the "Other…" time picker all render
  /// scoped to the pane's nested navigator instead of the whole window.
  final bool useRootNavigator;

  const DateTimelinePopup({
    required this.dates,
    required this.onChanged,
    this.useRootNavigator = true,
    super.key,
  });

  /// Convenience: show the popup as a Material modal bottom sheet rooted at
  /// [context]. The sheet is dismissed when the user taps **Cancel** or
  /// **Save** in the header (or via system back / swipe-down). [onChanged]
  /// is only invoked from the Save path; see the class doc for the deferred-
  /// commit model.
  static Future<void> show({
    required BuildContext context,
    required Map<TaskDateType, DateTime?> dates,
    required void Function(TaskDateType type, DateTime? value) onChanged,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      // Lets the sheet take more than the default 50% of the screen for
      // tall stacks of markers + the inline calendar. The sheet sizes
      // itself to content via the popup's outer `mainAxisSize: min` and
      // its inner `Flexible(SingleChildScrollView)` for the body, so we
      // don't need a `DraggableScrollableSheet` wrapper (and the previous
      // wrapper's `scrollController` was never wired to the inner scroll
      // view, which Copilot correctly flagged).
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DateTimelinePopup(
        dates: dates,
        onChanged: onChanged,
        useRootNavigator: useRootNavigator,
      ),
    );
  }

  @override
  State<DateTimelinePopup> createState() => _DateTimelinePopupState();
}

class _DateTimelinePopupState extends State<DateTimelinePopup> {
  /// Working copy of the dates map. Edits update this; the parent's
  /// blueprint is only mutated when the user taps Save (see [_save]).
  late Map<TaskDateType, DateTime?> _dates;

  /// Snapshot of the dates as they were when the popup opened, so [_save]
  /// can diff and emit `onChanged` only for the types that changed.
  late Map<TaskDateType, DateTime?> _initialDates;

  /// Currently-selected date type for inline editing. Null = nothing
  /// selected (just the timeline shown).
  TaskDateType? _selected;

  @override
  void initState() {
    super.initState();
    _dates = Map.of(widget.dates);
    _initialDates = Map.of(widget.dates);
    _selected = TaskDateTypes.allTypes
        .firstWhere((t) => _dates[t] != null, orElse: () => TaskDateTypes.start);
    if (_dates[_selected] == null) _selected = null;
  }

  void _setDate(TaskDateType type, DateTime? value) {
    setState(() {
      _dates[type] = value;
      if (value == null && _selected == type) {
        _selected = TaskDateTypes.allTypes
            .firstWhere((t) => _dates[t] != null, orElse: () => type);
        if (_dates[_selected] == null) _selected = null;
      }
    });
    // No widget.onChanged here — the parent only learns about edits when
    // the user taps Save. Cancel/back/swipe-to-dismiss discards the diff.
  }

  /// Commits any changed dates to the parent and dismisses the sheet.
  void _save() {
    for (final t in TaskDateTypes.allTypes) {
      if (_dates[t] != _initialDates[t]) {
        widget.onChanged(t, _dates[t]);
      }
    }
    Navigator.of(context).pop();
  }

  /// Dismisses the sheet without committing any edits.
  void _cancel() {
    Navigator.of(context).pop();
  }

  /// Whether the working copy diverges from the snapshot taken at popup-
  /// open. Drives the Save button's enabled state.
  bool get _hasPendingChanges {
    for (final t in TaskDateTypes.allTypes) {
      if (_dates[t] != _initialDates[t]) return true;
    }
    return false;
  }

  /// Thin wrapper for the file-scope [defaultDateForNewType], which holds
  /// the actual algorithm so it's unit-testable without a widget pump.
  DateTime _defaultFor(TaskDateType type) =>
      defaultDateForNewType(type: type, dates: _dates);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TaskColors.popupBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(),
          _Header(
            onCancel: _cancel,
            onSave: _hasPendingChanges ? _save : null,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Timeline(
                    dates: _dates,
                    initialDates: _initialDates,
                    selected: _selected,
                    onSelect: (t) => setState(() => _selected = t),
                  ),
                  const SizedBox(height: 12),
                  _UnsetDateAddRow(
                    dates: _dates,
                    onAdd: (t) {
                      _setDate(t, _defaultFor(t));
                      setState(() => _selected = t);
                    },
                  ),
                  if (_selected != null && _dates[_selected] != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    const SizedBox(height: 14),
                    _SelectedDateDetail(
                      type: _selected!,
                      date: _dates[_selected]!,
                      dates: _dates,
                      onChange: (v) => _setDate(_selected!, v),
                      onRemove: () => _setDate(_selected!, null),
                      useRootNavigator: widget.useRootNavigator,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCancel;

  /// `null` disables the Save button (no pending edits to commit).
  final VoidCallback? onSave;
  const _Header({required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          // Left: Cancel — discards uncommitted edits.
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Center: title.
          const Expanded(
            child: Center(
              child: Text(
                'Dates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Right: Save — primary action, filled magenta to read as a CTA.
          // Disabled (null onPressed) when there are no pending edits;
          // FilledButton renders a faded variant in that case.
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: TaskColors.brandMagenta,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  TaskColors.brandMagenta.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.55),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal timeline with markers at each set date. Markers that would
/// overlap horizontally are stacked into vertical lanes (greedy first-fit
/// by x position). Lane 0 sits closest to the track; higher lanes have
/// proportionally longer connector lines so their labels clear the labels
/// in lower lanes. Tap targets stay distinct because each lane occupies
/// its own vertical region.
class _Timeline extends StatelessWidget {
  final Map<TaskDateType, DateTime?> dates;

  /// Snapshot of `dates` as of when the popup opened. Markers whose
  /// current value differs from the snapshot get a green ring around the
  /// label flag, mirroring the changed-field indicator on the parent
  /// edit-task screen.
  final Map<TaskDateType, DateTime?> initialDates;
  final TaskDateType? selected;
  final ValueChanged<TaskDateType> onSelect;

  /// Light green that matches `_ChangedFieldHighlight._accent` on the
  /// parent screen.
  static const Color _changedAccent = Color(0xFF8FE5A1);

  const _Timeline({
    required this.dates,
    required this.initialDates,
    required this.selected,
    required this.onSelect,
  });

  // Layout constants — tuned for the popup sheet width on a typical phone.
  static const double _markerWidth = 96;
  static const double _minGap = 6;
  static const double _laneSpacing = 28;
  static const double _baseConnectorHeight = 28;
  static const double _dotSize = 12;
  static const double _selectedDotSize = 16;
  // Outer flag wrapper height = inner pill (~22) + 4 px (2-px ring on
  // each side, transparent when not changed). Stays a constant so the
  // ring's presence doesn't shift layout.
  static const double _labelHeight = 26;
  static const double _dateHeight = 14;
  static const double _spacer = 3;
  static const double _insetPx = 30;

  /// Total marker column height (label + spacers + connector + dot) for the
  /// given lane index. Lane 0 is the shortest (closest to the track); each
  /// subsequent lane adds [_laneSpacing] to the connector.
  static double _markerHeight(int lane) {
    return _labelHeight +
        _spacer +
        _dateHeight +
        _spacer +
        (_baseConnectorHeight + lane * _laneSpacing) +
        _dotSize;
  }

  static List<int> _assignLanes(
    List<double> xs,
    List<int> priorities,
  ) =>
      assignTimelineLanes(
        xs,
        priorities: priorities,
        markerWidth: _markerWidth,
        minGap: _minGap,
      );

  @override
  Widget build(BuildContext context) {
    final setTypes = TaskDateTypes.allTypes
        .where((t) => dates[t] != null)
        .toList(growable: false);
    if (setTypes.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: Text(
          'Tap a date type below to add it.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 13,
          ),
        ),
      );
    }

    // Normalize all timeline math to day precision. The marker x is
    // proportional to the calendar-day offset; using full DateTimes with
    // `inDays` would floor sub-24h gaps to 0 (e.g. May 1 17:00 → May 2
    // 09:00 = 16h = 0 inDays) and collapse adjacent-day markers to the
    // same x. Keeping the full DateTime around for display is fine; only
    // the position math runs at day precision.
    DateTime _atDay(DateTime d) => DateTime(d.year, d.month, d.day);
    final dayValues =
        setTypes.map((t) => _atDay(dates[t]!)).toList(growable: false);
    final minDay = dayValues.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDay = dayValues.reduce((a, b) => a.isAfter(b) ? a : b);
    // Lower bound of 1 keeps `spanDays` away from zero (single-day spans
    // would otherwise divide-by-zero in `pct`). No upper bound: dates more
    // than a year apart should still render with their relative offsets
    // intact rather than saturating to the far edge of the timeline.
    final rawSpan = maxDay.difference(minDay).inDays;
    final spanDays = (rawSpan < 1 ? 1 : rawSpan).toDouble();

    double pct(DateTime d) {
      if (spanDays == 0) return 0.5;
      final delta = _atDay(d).difference(minDay).inDays.toDouble();
      return (delta / spanDays).clamp(0.0, 1.0);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final usable = (width - _insetPx * 2).clamp(0.0, double.infinity);

        // Compute each marker's x in pixel space and its priority in
        // TaskDateTypes ordering (Start = 0, Target = 1, Urgent = 2,
        // Due = 3). The lane algorithm uses priority to enforce the
        // top-down stack order (Start at the top, Due closest to the track)
        // when markers collide horizontally.
        final xs = setTypes
            .map((t) => _insetPx + usable * pct(dates[t]!))
            .toList(growable: false);
        final priorities = setTypes
            .map((t) => TaskDateTypes.allTypes.indexOf(t))
            .toList(growable: false);
        final laneByOriginalIndex = _assignLanes(xs, priorities);
        final maxLane = laneByOriginalIndex.isEmpty
            ? 0
            : laneByOriginalIndex.reduce((a, b) => a > b ? a : b);

        // Stack height accommodates the tallest column plus a small bottom
        // buffer so the dot's outer ring isn't clipped.
        final stackHeight = _markerHeight(maxLane) + 4;

        return SizedBox(
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Track sits one pixel above the dot center so the dot ring
              // overlaps the line cleanly.
              Positioned(
                left: 0,
                right: 0,
                bottom: _dotSize / 2 + 3,
                child: Container(
                  height: 2,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              for (var i = 0; i < setTypes.length; i++)
                _buildMarker(
                  setTypes[i],
                  dates[setTypes[i]]!,
                  _insetPx + usable * pct(dates[setTypes[i]]!),
                  laneByOriginalIndex[i],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMarker(
    TaskDateType t,
    DateTime d,
    double x,
    int lane,
  ) {
    final isSelected = selected == t;
    final isChanged = dates[t] != initialDates[t];
    final connectorHeight = _baseConnectorHeight + lane * _laneSpacing;
    final dotSize = isSelected ? _selectedDotSize : _dotSize;
    final flag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? t.textColor
            : t.textColor.withValues(alpha: 0.14),
        border: Border.all(
          color: t.textColor.withValues(alpha: 0.40),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        t.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: isSelected
              ? const Color.fromRGBO(20, 30, 60, 0.95)
              : t.textColor,
        ),
      ),
    );
    // Same green ring as `_ChangedFieldHighlight` on the parent screen,
    // around the label flag of any marker whose date differs from the
    // snapshot at popup-open. Layout-stable: transparent border when not
    // changed.
    final labelFlag = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isChanged ? _changedAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: flag,
    );
    final dateText = Text(
      _shortDate(d),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.80),
        fontSize: 11,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Positioned(
      left: x - _markerWidth / 2,
      bottom: 0,
      width: _markerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only the label+date region is interactive. Wrapping the whole
          // column (which spans label → connector → dot) caused higher-lane
          // markers to occlude lower-lane markers since their tap targets
          // covered the same x-range and grew taller per lane.
          GestureDetector(
            onTap: () => onSelect(t),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                labelFlag,
                const SizedBox(height: _spacer),
                dateText,
              ],
            ),
          ),
          const SizedBox(height: _spacer),
          // Decorative connector — no GestureDetector, hits pass through
          // to neighboring markers if there are any at this y region.
          Container(
            width: 1.5,
            height: connectorHeight,
            color: t.textColor,
          ),
          // Dot — independently tappable so users can hit it directly.
          GestureDetector(
            onTap: () => onSelect(t),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: t.textColor,
                shape: BoxShape.circle,
                border: Border.all(color: TaskColors.popupBg, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Year-eliding short date (e.g. "Apr 18", or "Apr 18 2025" when the
  /// year differs from the current calendar year). Local-time-converted.
  String _shortDate(DateTime d) =>
      DateUtil.formatMonthDayMaybeYearShort(d);
}

/// Row of dashed "+ Add Start" pills for date types that aren't currently
/// set. Tapping creates a default date and selects it.
class _UnsetDateAddRow extends StatelessWidget {
  final Map<TaskDateType, DateTime?> dates;
  final ValueChanged<TaskDateType> onAdd;

  const _UnsetDateAddRow({required this.dates, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final unset = TaskDateTypes.allTypes
        .where((t) => dates[t] == null)
        .toList(growable: false);
    if (unset.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'ADD A DATE',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: unset
              .map((t) => _AddDatePill(type: t, onTap: () => onAdd(t)))
              .toList(),
        ),
      ],
    );
  }
}

class _AddDatePill extends StatelessWidget {
  final TaskDateType type;
  final VoidCallback onTap;

  const _AddDatePill({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: type.textColor.withValues(alpha: 0.06),
            border: Border.all(
              color: type.textColor.withValues(alpha: 0.40),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 11, color: type.textColor),
              const SizedBox(width: 5),
              Text(
                type.label,
                style: TextStyle(
                  color: type.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline calendar + time bucket picker + Remove button for the currently-
/// selected date type. The calendar is custom so it can:
///   - render the selected day as bold colored text in the type's accent
///   - render OTHER set dates (e.g. Target while editing Urgent) as faded
///     coloured numbers in their own accent
///   - fade and disable days outside the chronologically-allowed range
///     (e.g. Target between Start and Due)
class _SelectedDateDetail extends StatelessWidget {
  final TaskDateType type;
  final DateTime date;
  final Map<TaskDateType, DateTime?> dates;
  final ValueChanged<DateTime> onChange;
  final VoidCallback onRemove;

  /// Threaded through to [_TimeBucketPicker] so the "Other…" time picker
  /// stays scoped to the docked editor pane (TM-384). See
  /// [DateTimelinePopup.useRootNavigator].
  final bool useRootNavigator;

  const _SelectedDateDetail({
    required this.type,
    required this.date,
    required this.dates,
    required this.onChange,
    required this.onRemove,
    this.useRootNavigator = true,
  });

  /// Lower bound for the selected date (inclusive). Computed as the latest
  /// of any chronologically-earlier set dates. `null` when no earlier date
  /// is set.
  DateTime? get _firstDate {
    final selfIdx = TaskDateTypes.allTypes.indexOf(type);
    DateTime? best;
    for (var i = 0; i < selfIdx; i++) {
      final d = dates[TaskDateTypes.allTypes[i]];
      if (d == null) continue;
      if (best == null || d.isAfter(best)) best = d;
    }
    return best;
  }

  /// Upper bound for the selected date (inclusive). Computed as the earliest
  /// of any chronologically-later set dates. `null` when no later date
  /// is set.
  DateTime? get _lastDate {
    final selfIdx = TaskDateTypes.allTypes.indexOf(type);
    DateTime? best;
    for (var i = selfIdx + 1; i < TaskDateTypes.allTypes.length; i++) {
      final d = dates[TaskDateTypes.allTypes[i]];
      if (d == null) continue;
      if (best == null || d.isBefore(best)) best = d;
    }
    return best;
  }

  /// Other set dates with their accent colors, for the calendar to render
  /// as non-bold coloured numbers in addition to the selected day.
  Map<DateTime, Color> get _markedDates {
    final m = <DateTime, Color>{};
    for (final t in TaskDateTypes.allTypes) {
      if (t == type) continue;
      final d = dates[t];
      if (d == null) continue;
      m[DateTime(d.year, d.month, d.day)] = t.textColor;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final accent = type.textColor;
    var firstDate = _firstDate;
    var lastDate = _lastDate;
    // Inverted-bounds guard: if the existing dates are inconsistent (e.g.
    // Start set later than Due on a legacy row), `firstDate.isAfter(lastDate)`
    // and the calendar would reject every day as out-of-range, locking the
    // user out of editing this field. Drop both constraints so the popup
    // can still be used to repair the bad data.
    if (firstDate != null &&
        lastDate != null &&
        firstDate.isAfter(lastDate)) {
      firstDate = null;
      lastDate = null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${type.label} date',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _longDate(date),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _RemoveButton(onPressed: onRemove),
          ],
        ),
        const SizedBox(height: 12),
        // Key on the type so that switching markers (e.g. Target → Urgent)
        // forces a fresh _MiniCalendar with the new month displayed.
        // Within one type, navigation arrow state is preserved.
        _MiniCalendar(
          key: ValueKey('mini-cal-${type.label}'),
          selectedDate: date,
          accent: accent,
          markedDates: _markedDates,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: (newDate) {
            // Preserve the previous time-of-day, but if the new date
            // lands on a boundary day where the existing time would
            // violate the chronological order (e.g. switching Target
            // onto Start's day while keeping a time before Start), clamp
            // into the valid range so the resulting DateTime stays
            // ordered.
            var hour = date.hour;
            var minute = date.minute;
            final mins = hour * 60 + minute;
            if (firstDate != null && _isSameDay(firstDate, newDate)) {
              final minMins = firstDate.hour * 60 + firstDate.minute;
              if (mins < minMins) {
                hour = firstDate.hour;
                minute = firstDate.minute;
              }
            }
            if (lastDate != null && _isSameDay(lastDate, newDate)) {
              final maxMins = lastDate.hour * 60 + lastDate.minute;
              final curMins = hour * 60 + minute;
              if (curMins > maxMins) {
                hour = lastDate.hour;
                minute = lastDate.minute;
              }
            }
            onChange(DateTime(
              newDate.year, newDate.month, newDate.day, hour, minute,
            ));
          },
        ),
        const SizedBox(height: 12),
        _TimeBucketPicker(
          date: date,
          useRootNavigator: useRootNavigator,
          // Time restriction only applies on the boundary day itself.
          // Past the boundary day, the date constraint already covers
          // the chronological order. Full hour+minute precision so a
          // boundary date with non-zero minutes (e.g. via Other...) is
          // honored.
          minTime: (firstDate != null && _isSameDay(firstDate, date))
              ? TimeOfDay(hour: firstDate.hour, minute: firstDate.minute)
              : null,
          maxTime: (lastDate != null && _isSameDay(lastDate, date))
              ? TimeOfDay(hour: lastDate.hour, minute: lastDate.minute)
              : null,
          onChange: (t) {
            onChange(DateTime(
              date.year, date.month, date.day, t.hour, t.minute,
            ));
          },
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Year-eliding long date (e.g. "April 18", or "April 18, 2025" when
  /// the year differs from the current calendar year). Local-time-
  /// converted; same year-eliding contract as the timeline pill labels.
  String _longDate(DateTime d) =>
      DateUtil.formatMonthDayMaybeYearLong(d);
}

/// Compact month-grid calendar used by the dates popup. Custom (instead of
/// Flutter's `CalendarDatePicker`) because we need:
///   - selected day rendered as bold colored text in the accent (no filled
///     background circle that fights with the popup surface)
///   - OTHER set dates (the [markedDates] map) rendered as non-bold coloured
///     text in their own accent color, even when the user has navigated to
///     a different month
///   - days outside [firstDate]..[lastDate] faded and non-tappable
class _MiniCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Color accent;
  final Map<DateTime, Color> markedDates;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateChanged;

  const _MiniCalendar({
    super.key,
    required this.selectedDate,
    required this.accent,
    required this.markedDates,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<_MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<_MiniCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void didUpdateWidget(covariant _MiniCalendar old) {
    super.didUpdateWidget(old);
    // If the parent updates the selectedDate to a different month/year
    // (e.g. user picked a day in a different month from the timeline
    // marker, OR the same month in a different year), follow it. The
    // earlier extra `month` guard against `old.selectedDate.month`
    // missed year-only changes (Jan 2026 → Jan 2027).
    final selMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
    if (selMonth != _displayedMonth) {
      _displayedMonth = selMonth;
    }
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  /// Snap the displayed month to "today" so the user can see/tap today's
  /// cell. Does NOT change the selected date — the user still has to tap
  /// the day cell themselves to commit it. This keeps the affordance
  /// purely navigational, matching the convention in iOS/Android stock
  /// calendar apps.
  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month);
    });
  }

  /// Open a modal bottom sheet for picking a month AND year to navigate
  /// to. The visible year list is always `currentYear ± 100` regardless
  /// of the firstDate/lastDate bounds — the picker is purely
  /// navigational, like Today. Years/months that fall entirely outside
  /// the bounds are rendered faded and non-tappable in the sheet so the
  /// user can see at a glance which jumps would land on a valid day.
  /// Returns a `(year, month)` pair as a `DateTime`; the selected date
  /// itself is unchanged.
  Future<void> _openMonthYearPicker() async {
    final now = DateTime.now();
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MonthYearPickerSheet(
        firstYear: now.year - 100,
        lastYear: now.year + 100,
        initial: _displayedMonth,
        accent: widget.accent,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
      ),
    );
    if (picked == null) return;
    setState(() {
      _displayedMonth = DateTime(picked.year, picked.month);
    });
  }

  bool _isInRange(DateTime d) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    final dayStart = DateTime(d.year, d.month, d.day);
    if (first != null) {
      final firstDay = DateTime(first.year, first.month, first.day);
      if (dayStart.isBefore(firstDay)) return false;
    }
    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      if (dayStart.isAfter(lastDay)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final month = _displayedMonth;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Sun = 7 in DateTime.weekday; we treat Sunday as the first column to
    // match the prototype.
    final leadingBlanks = firstOfMonth.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Tappable month/year label opens the year-picker sheet so the
            // user can jump multiple years at a time without spamming the
            // chevrons. The InkWell + Material wrap gives us a hover/press
            // affordance without changing the visual rest state.
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openMonthYearPicker,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_monthName(month.month)} ${month.year}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // "Today" affordance — small text button that navigates the
            // calendar's displayed month to today's month. Always visible:
            // it doesn't change the selection, so even when today itself
            // is out of the firstDate/lastDate range the user can still
            // use it to scroll the calendar somewhere recognisable.
            TextButton(
              onPressed: _jumpToToday,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: widget.accent,
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  color: widget.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            _ChevronButton(direction: _ChevronDir.left, onPressed: _prevMonth),
            _ChevronButton(direction: _ChevronDir.right, onPressed: _nextMonth),
          ],
        ),
        const SizedBox(height: 8),
        // Weekday header
        Row(
          children: [
            for (final wd in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    wd,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Day grid — always render exactly 6 rows so the calendar height
        // stays constant regardless of which month is shown. Months that
        // only need 4 or 5 weeks fill the trailing rows with fixed-height
        // (32px) placeholders — `_buildDayCell` returns a
        // `SizedBox(height: 32)` for out-of-range day numbers, matching
        // the height of a real day cell so the grid keeps the same
        // total footprint. Without this, the chevron arrows would shift
        // vertically as the user navigated month-to-month.
        for (var row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _buildDayCell(
                        row * 7 + col + 1 - leadingBlanks, month),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDayCell(int day, DateTime month) {
    if (day < 1 || day > DateTime(month.year, month.month + 1, 0).day) {
      return const SizedBox(height: 32);
    }
    final cellDate = DateTime(month.year, month.month, day);
    final isSelected = cellDate.year == widget.selectedDate.year &&
        cellDate.month == widget.selectedDate.month &&
        cellDate.day == widget.selectedDate.day;
    final today = DateTime.now();
    final isToday = cellDate.year == today.year &&
        cellDate.month == today.month &&
        cellDate.day == today.day;
    final markColor = widget.markedDates[cellDate];
    final inRange = _isInRange(cellDate);

    Color textColor;
    Color? backgroundColor;
    Color? borderColor;
    FontWeight weight;
    if (!inRange) {
      textColor = Colors.white.withValues(alpha: 0.20);
      weight = FontWeight.w400;
      backgroundColor = null;
      if (isToday) {
        // Out-of-range today still gets a ring — outline only — so the
        // user can locate today at a glance without being misled into
        // thinking the cell is tappable. Same white family as the
        // in-range today fill, just stronger alpha because an outline
        // alone needs more contrast than a filled disc to read.
        borderColor = Colors.white.withValues(alpha: 0.45);
      }
    } else if (isSelected) {
      // Filled circle in the accent color; dark text on top so the digit
      // remains legible against the bright fill.
      backgroundColor = widget.accent;
      textColor = const Color.fromRGBO(20, 30, 60, 0.95);
      weight = FontWeight.w700;
    } else if (markColor != null) {
      // Other set dates render as bold coloured text so the user can see
      // them while editing a different type, but no fill — only the
      // selected day gets a circle.
      textColor = markColor;
      weight = FontWeight.w700;
      backgroundColor = null;
    } else if (isToday) {
      // Today marker: faded white-circle so the user can find today at
      // a glance without confusing it for the selected day (which is a
      // solid accent fill) or the date-type-coloured marked dates. Using
      // the day digit's own colour family (white) instead of the date-
      // type accent keeps the cue type-agnostic — it reads as "today"
      // rather than "today, but only in this date type's view".
      backgroundColor = Colors.white.withValues(alpha: 0.15);
      textColor = Colors.white.withValues(alpha: 0.85);
      weight = FontWeight.w400;
    } else {
      // Plain in-range days are light (FontWeight.w400) so the bold marked
      // dates stand out against them.
      textColor = Colors.white.withValues(alpha: 0.85);
      weight = FontWeight.w400;
      backgroundColor = null;
    }

    final shape = CircleBorder(
      side: borderColor != null
          ? BorderSide(color: borderColor, width: 1)
          : BorderSide.none,
    );
    return SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: inRange ? () => widget.onDateChanged(cellDate) : null,
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: weight,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static String _monthName(int m) => _monthNames[m - 1];
}

enum _ChevronDir { left, right }

class _ChevronButton extends StatelessWidget {
  final _ChevronDir direction;
  final VoidCallback onPressed;

  const _ChevronButton({required this.direction, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 16,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      icon: Icon(
        direction == _ChevronDir.left
            ? Icons.chevron_left
            : Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

/// Month/year picker bottom sheet for the mini calendar's "tap month label
/// → jump anywhere" affordance. Renders two scrollable columns side by
/// side (months on the left, years on the right) inside the dark popup
/// surface. Tapping a row updates that column's selection in place; the
/// user confirms with the Done button at the bottom which pops the sheet
/// with the chosen `(year, month)` packaged as a `DateTime`. Returns
/// `null` on dismiss / cancel.
///
/// The full year list is always shown so the user can navigate freely.
/// Years and months whose every day falls outside [firstDate]/[lastDate]
/// render faded and non-tappable, signalling that landing there would
/// produce no selectable day.
class _MonthYearPickerSheet extends StatefulWidget {
  final int firstYear;
  final int lastYear;
  final DateTime initial;
  final Color accent;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _MonthYearPickerSheet({
    required this.firstYear,
    required this.lastYear,
    required this.initial,
    required this.accent,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<_MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<_MonthYearPickerSheet> {
  late int _month;
  late int _year;
  late ScrollController _yearController;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _month = widget.initial.month;
    // Clamp the initial year into the list's [firstYear, lastYear]
    // window. The mini-calendar's chevron navigation isn't bounded,
    // so `widget.initial` (the displayed month at the moment the
    // user tapped the label) can drift outside the picker's ±100-year
    // range. Without the clamp, the sheet would render with no
    // visible selection (no list item matches `_year`) but the Done
    // button could still pop a year not present in the list.
    final raw = widget.initial.year;
    if (raw < widget.firstYear) {
      _year = widget.firstYear;
    } else if (raw > widget.lastYear) {
      _year = widget.lastYear;
    } else {
      _year = raw;
    }
    final yearCount = widget.lastYear - widget.firstYear + 1;
    final selectedIdx = _year - widget.firstYear;
    // Each year row is ~44px tall; centre the initially-selected year
    // by offsetting half the visible column height (~120px). Clamp
    // upper bound to the actual list length so the year column scrolls
    // correctly regardless of how wide `firstYear`..`lastYear` is.
    const itemExtent = 44.0;
    final maxOffset =
        (yearCount * itemExtent - 120).clamp(0.0, double.infinity);
    _yearController = ScrollController(
      initialScrollOffset:
          (selectedIdx * itemExtent - 120).clamp(0.0, maxOffset),
    );
  }

  /// True when the user's *current* picked (`_year`, `_month`) is
  /// committable: both inside the picker's own
  /// [widget.firstYear]..[widget.lastYear] list AND inside the optional
  /// [widget.firstDate]..[widget.lastDate] window. Used to gate the
  /// Done button so an out-of-range initial selection (or any state
  /// the picker can't actually present in its list) can't be committed
  /// without the user changing it first.
  bool _isCurrentSelectionInRange() {
    if (_year < widget.firstYear || _year > widget.lastYear) return false;
    return _yearInRange(_year) && _monthInRange(_year, _month);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TaskColors.popupBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 12, 12),
              child: Text(
                'Jump to month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildMonthColumn()),
                  Container(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  Expanded(child: _buildYearColumn()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Disable Done when the picked month/year sits
                  // entirely outside [firstDate]..[lastDate]. The
                  // sheet can open with an out-of-range initial value
                  // (e.g. when the calendar's `_displayedMonth` was
                  // already past the bound from a previous nav), so
                  // gating Done here is what enforces the
                  // "non-tappable" contract for invalid selections —
                  // the row-level fade is just the visual cue.
                  FilledButton(
                    onPressed: _isCurrentSelectionInRange()
                        ? () => Navigator.of(context).pop(
                              DateTime(_year, _month),
                            )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.accent,
                      foregroundColor: const Color.fromRGBO(20, 30, 60, 0.95),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// True when ANY day in [year]/[month] falls within
  /// [firstDate]..[lastDate]. Out-of-range months render faded/disabled.
  bool _monthInRange(int year, int month) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0); // last day of month
    if (first != null) {
      final firstDay = DateTime(first.year, first.month, first.day);
      if (monthEnd.isBefore(firstDay)) return false;
    }
    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      if (monthStart.isAfter(lastDay)) return false;
    }
    return true;
  }

  /// True when at least one month in [year] falls within
  /// [firstDate]..[lastDate]. Out-of-range years render faded/disabled.
  bool _yearInRange(int year) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null && year < first.year) return false;
    if (last != null && year > last.year) return false;
    return true;
  }

  Widget _buildMonthColumn() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _monthNames.length,
      itemBuilder: (ctx, i) {
        final monthNum = i + 1;
        final isSelected = monthNum == _month;
        // Whether this month has any valid day for the *currently picked*
        // year — months in entirely-out-of-range cells fade and disable.
        final inRange = _monthInRange(_year, monthNum);
        final color = !inRange
            ? Colors.white.withValues(alpha: 0.20)
            : (isSelected
                ? widget.accent
                : Colors.white.withValues(alpha: 0.85));
        return InkWell(
          onTap: inRange ? () => setState(() => _month = monthNum) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              _monthNames[i],
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearColumn() {
    final count = widget.lastYear - widget.firstYear + 1;
    return ListView.builder(
      controller: _yearController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: count,
      itemBuilder: (ctx, i) {
        final year = widget.firstYear + i;
        final isSelected = year == _year;
        final inRange = _yearInRange(year);
        final color = !inRange
            ? Colors.white.withValues(alpha: 0.20)
            : (isSelected
                ? widget.accent
                : Colors.white.withValues(alpha: 0.85));
        return InkWell(
          onTap: inRange ? () => setState(() => _year = year) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              '$year',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RemoveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(255, 120, 120, 0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color.fromRGBO(255, 120, 120, 0.30),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.close,
                size: 11,
                color: Color.fromRGBO(255, 180, 180, 0.95),
              ),
              SizedBox(width: 5),
              Text(
                'Remove',
                style: TextStyle(
                  color: Color.fromRGBO(255, 180, 180, 0.95),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5-segment time picker: 9 AM / 12 PM / 2 PM / 5 PM / Other...
///
/// "Other..." opens Flutter's `showTimePicker` so the user can pick any
/// time of day. When the current time matches one of the four standard
/// hours (and minute is 0), that segment is highlighted; otherwise the
/// "Other..." segment is highlighted and displays the actual time
/// (e.g. "8:30 PM") instead of the literal label.
///
/// Replaces the earlier "All day" affordance, which the user reported was
/// semantically unclear (when does the reminder fire?). "Other..." also
/// gives users an escape hatch when [minHour]/[maxHour] would block all
/// four standard buckets — they can dial in any time directly.
class _TimeBucketPicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<TimeOfDay> onChange;

  /// Inclusive lower bound. Standard buckets earlier than this become
  /// disabled; the "Other..." picker rejects times earlier than this.
  /// `null` = no lower bound. Should only be supplied when [date] falls
  /// on the same calendar day as the constraint date (otherwise the date
  /// itself already covers the chronological order). Compared at full
  /// hour+minute precision so an `Other...` pick of e.g. 9:30 correctly
  /// disables the 9 AM bucket on the next render.
  final TimeOfDay? minTime;

  /// Inclusive upper bound. Same rules as [minTime] but for the high end.
  final TimeOfDay? maxTime;

  /// Whether the "Other…" `showTimePicker` dialog targets the root
  /// navigator. `false` (from the docked editor pane, TM-384) keeps it
  /// scoped to the pane's nested navigator.
  final bool useRootNavigator;

  const _TimeBucketPicker({
    required this.date,
    required this.onChange,
    this.minTime,
    this.maxTime,
    this.useRootNavigator = true,
  });

  static const _buckets = [9, 12, 14, 17];
  static const _bucketLabels = ['9 AM', '12 PM', '2 PM', '5 PM'];

  /// Minutes since midnight, for ordering comparisons.
  static int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Active 0-based segment index. Returns 0..3 when the time matches one
  /// of the standard buckets exactly (minute == 0), or 4 for "Other..."
  /// otherwise.
  int _activeIndex() {
    if (date.minute != 0) return 4;
    final idx = _buckets.indexOf(date.hour);
    return idx >= 0 ? idx : 4;
  }

  /// Standard buckets are disabled when their effective time
  /// (`bucket_hour:00`) falls outside the supplied range. Compared in
  /// minutes-since-midnight so a min of e.g. `9:30` correctly disables
  /// the `9 AM` bucket. "Other..." (index 4) is always enabled — its
  /// validation happens in [_openOtherPicker] after the picker returns.
  bool _disabled(int segIdx) {
    if (segIdx == 4) return false;
    final bucketMins = _buckets[segIdx] * 60; // bucket times are on the hour
    if (minTime != null && bucketMins < _toMinutes(minTime!)) return true;
    if (maxTime != null && bucketMins > _toMinutes(maxTime!)) return true;
    return false;
  }

  Future<void> _openOtherPicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: useRootNavigator,
      initialTime: TimeOfDay(hour: date.hour, minute: date.minute),
    );
    if (picked == null) return;

    // Validate against the same bounds the standard buckets honor —
    // otherwise "Other..." would be a constraint-bypass for boundary days.
    final pickedMins = _toMinutes(picked);
    if (minTime != null && pickedMins < _toMinutes(minTime!)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Time must be ${_formatTime(minTime!)} or later on this day.'),
        ),
      );
      return;
    }
    if (maxTime != null && pickedMins > _toMinutes(maxTime!)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Time must be ${_formatTime(maxTime!)} or earlier on this day.'),
        ),
      );
      return;
    }
    onChange(picked);
  }

  /// 12-hour formatted time string used in the "Other..." segment when
  /// it's the active segment. Examples: `8 PM`, `8:30 PM`, `12:15 AM`.
  static String _formatTime(TimeOfDay t) {
    final hour12 = t.hour == 0
        ? 12
        : (t.hour > 12 ? t.hour - 12 : t.hour);
    final period = t.hour < 12 ? 'AM' : 'PM';
    if (t.minute == 0) return '$hour12 $period';
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _activeIndex();
    final accent = accentColorForIndex(SegmentedBarAccent.brand, 0);
    final otherLabel = activeIdx == 4
        ? _formatTime(TimeOfDay(hour: date.hour, minute: date.minute))
        : 'Other...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'TIME',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Opacity(
                  opacity: _disabled(i) ? 0.35 : 1.0,
                  child: IgnorePointer(
                    ignoring: _disabled(i),
                    child: Segment(
                      label: i == 4 ? otherLabel : _bucketLabels[i],
                      filled: i == activeIdx,
                      fillColor: accent,
                      height: 32,
                      onTap: () {
                        if (i == 4) {
                          _openOtherPicker(context);
                        } else {
                          onChange(TimeOfDay(hour: _buckets[i], minute: 0));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

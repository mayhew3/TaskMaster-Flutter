import 'package:flutter/material.dart';
import 'package:taskmaestro/features/shared/presentation/widgets/segmented_bar.dart';
import 'package:taskmaestro/models/task_colors.dart';
import 'package:taskmaestro/models/task_date_type.dart';

/// Modal bottom-sheet popup for editing the start/target/urgent/due dates of
/// a task. Renders:
///   1. A horizontal timeline with a marker per set date (snaps with the
///      date-type accent color).
///   2. A row of `+ Add` pills for unset dates (creates a default date for
///      that type).
///   3. When a marker is selected, an inline calendar + time-bucket picker +
///      Remove button so the user can edit or clear that single date.
///
/// Changes propagate immediately via [onChanged]; the Done button just
/// dismisses the sheet.
class DateTimelinePopup extends StatefulWidget {
  final Map<TaskDateType, DateTime?> dates;
  final void Function(TaskDateType type, DateTime? value) onChanged;

  const DateTimelinePopup({
    required this.dates,
    required this.onChanged,
    super.key,
  });

  /// Convenience: show the popup as a Material modal bottom sheet rooted at
  /// [context]. The popup is dismissed when the user taps Done or swipes
  /// down. Changes are pushed via [onChanged] as they happen.
  static Future<void> show({
    required BuildContext context,
    required Map<TaskDateType, DateTime?> dates,
    required void Function(TaskDateType type, DateTime? value) onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => DateTimelinePopup(
          dates: dates,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  State<DateTimelinePopup> createState() => _DateTimelinePopupState();
}

class _DateTimelinePopupState extends State<DateTimelinePopup> {
  /// Local mirror of the dates map so the timeline updates as the user
  /// edits. Each change is also bubbled up through `widget.onChanged`.
  late Map<TaskDateType, DateTime?> _dates;

  /// Currently-selected date type for inline editing. Null = nothing
  /// selected (just the timeline shown).
  TaskDateType? _selected;

  @override
  void initState() {
    super.initState();
    _dates = Map.of(widget.dates);
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
    widget.onChanged(type, value);
  }

  /// Best-effort default date for a newly-added date type, derived from
  /// other set dates: start = today, target = +5d, urgent = +13d, due = +20d.
  /// Falls back to "today + N days" relative to the latest set date.
  DateTime _defaultFor(TaskDateType type) {
    const offsets = {0: 0, 1: 5, 2: 13, 3: 20};
    final idx = TaskDateTypes.allTypes.indexOf(type);
    final base = TaskDateTypes.allTypes
            .map((t) => _dates[t])
            .where((d) => d != null)
            .cast<DateTime>()
            .fold<DateTime?>(null,
                (acc, d) => (acc == null || d.isAfter(acc)) ? d : acc) ??
        DateTime.now();
    final offset = offsets[idx] ?? 0;
    return DateTime(base.year, base.month, base.day, 9)
        .add(Duration(days: offset));
  }

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
          _Header(onClose: () => Navigator.of(context).pop()),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Timeline(
                    dates: _dates,
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
                      onChange: (v) => _setDate(_selected!, v),
                      onRemove: () => _setDate(_selected!, null),
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
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 4, 12, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Dates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClose,
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal timeline with markers at each set date. Layout uses LayoutBuilder
/// so marker positions can be percentage-based across the available width.
class _Timeline extends StatelessWidget {
  final Map<TaskDateType, DateTime?> dates;
  final TaskDateType? selected;
  final ValueChanged<TaskDateType> onSelect;

  const _Timeline({
    required this.dates,
    required this.selected,
    required this.onSelect,
  });

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

    final days = setTypes.map((t) => dates[t]!).toList();
    final minDate = days.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDate = days.reduce((a, b) => a.isAfter(b) ? a : b);
    final spanDays =
        (maxDate.difference(minDate).inDays).clamp(1, 365).toDouble();

    double pct(DateTime d) {
      if (spanDays == 0) return 0.5;
      final delta = d.difference(minDate).inDays.toDouble();
      return (delta / spanDays).clamp(0.0, 1.0);
    }

    return SizedBox(
      height: 110,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Track is fixed at y=80 of the 110px height.
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 80,
                child: Container(
                  height: 2,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              ..._buildMarkers(setTypes, pct, width),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildMarkers(
    List<TaskDateType> setTypes,
    double Function(DateTime) pct,
    double width,
  ) {
    return setTypes.map((t) {
      final d = dates[t]!;
      final isSelected = selected == t;
      // Inset markers slightly so they don't clip at 0% or 100%.
      const insetPx = 30.0;
      final usable = (width - insetPx * 2).clamp(0.0, double.infinity);
      final x = insetPx + usable * pct(d);
      return Positioned(
        left: x - 50,
        top: 0,
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: () => onSelect(t),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
              ),
              const SizedBox(height: 3),
              Text(
                _shortDate(d),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 1.5,
                height: 28,
                color: t.textColor,
              ),
              Container(
                width: isSelected ? 16 : 12,
                height: isSelected ? 16 : 12,
                decoration: BoxDecoration(
                  color: t.textColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: TaskColors.popupBg, width: 2),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
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
/// selected date type. Uses Flutter's `CalendarDatePicker` so we don't have
/// to reinvent month nav, weekday rows, or accessibility.
class _SelectedDateDetail extends StatelessWidget {
  final TaskDateType type;
  final DateTime date;
  final ValueChanged<DateTime> onChange;
  final VoidCallback onRemove;

  const _SelectedDateDetail({
    required this.type,
    required this.date,
    required this.onChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final accent = type.textColor;
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
            Text(
              _longDate(date),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 12.5,
              ),
            ),
            const Spacer(),
            _RemoveButton(onPressed: onRemove),
          ],
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: accent,
                  onPrimary: const Color.fromRGBO(20, 30, 60, 0.95),
                  surface: TaskColors.popupBg,
                  onSurface: Colors.white,
                ),
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
          ),
          child: SizedBox(
            height: 320,
            child: CalendarDatePicker(
              initialDate: date,
              firstDate: DateTime(date.year - 5),
              lastDate: DateTime(date.year + 5),
              onDateChanged: (newDate) {
                onChange(DateTime(
                  newDate.year, newDate.month, newDate.day,
                  date.hour, date.minute,
                ));
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _TimeBucketPicker(
          date: date,
          onChange: (h) {
            // h == null → all-day (00:00).
            final hour = h ?? 0;
            onChange(DateTime(
              date.year, date.month, date.day, hour,
            ));
          },
        ),
      ],
    );
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _longDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
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

/// 5-bucket time picker: 9 AM / 12 PM / 2 PM / 5 PM / All day. Snaps the
/// current hour to the closest bucket on render.
class _TimeBucketPicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<int?> onChange; // hour or null for all-day

  const _TimeBucketPicker({required this.date, required this.onChange});

  static const buckets = [9, 12, 14, 17];
  static const labels = ['9 AM', '12 PM', '2 PM', '5 PM', 'All day'];

  int _activeIndex() {
    if (date.hour == 0 && date.minute == 0) return 5; // All day
    var bestIdx = 0;
    var bestDelta = (buckets[0] - date.hour).abs();
    for (var i = 1; i < buckets.length; i++) {
      final d = (buckets[i] - date.hour).abs();
      if (d < bestDelta) {
        bestDelta = d;
        bestIdx = i;
      }
    }
    return bestIdx + 1;
  }

  @override
  Widget build(BuildContext context) {
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
        SegmentedBar(
          value: _activeIndex(),
          segments: 5,
          labels: labels,
          allowZero: false,
          onChanged: (v) {
            if (v == null) return;
            if (v == 5) {
              onChange(null); // All day
            } else {
              onChange(buckets[v - 1]);
            }
          },
        ),
      ],
    );
  }
}

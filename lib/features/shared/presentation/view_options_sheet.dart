import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/task_colors.dart';
import '../../../models/task_list_view.dart';
import '../../areas/presentation/area_multi_picker.dart';
import '../../contexts/providers/context_providers.dart';
import '../../shared/providers/task_list_view_providers.dart';
import 'widgets/segmented_bar.dart';

const _kGroupAxisLabels = <TaskGroupAxis, String>{
  TaskGroupAxis.dueStatus: 'Due Status',
  TaskGroupAxis.none: 'None',
  TaskGroupAxis.priority: 'Priority',
  TaskGroupAxis.area: 'Area',
  TaskGroupAxis.points: 'Points',
  TaskGroupAxis.duration: 'Duration',
};

const _kSortAxisLabels = <TaskSortAxis, String>{
  TaskSortAxis.dueStatus: 'Default',
  TaskSortAxis.dateAdded: 'Date Added',
  TaskSortAxis.points: 'Points',
  TaskSortAxis.area: 'Area',
  TaskSortAxis.duration: 'Duration',
  TaskSortAxis.priority: 'Priority',
  TaskSortAxis.efficiency: 'Efficiency',
  TaskSortAxis.startDate: 'Start Date',
  TaskSortAxis.completionDate: 'Completion Date',
};

const _kDueStatusLabels = <DueStatusBucket, String>{
  DueStatusBucket.pastDue: 'Past Due',
  DueStatusBucket.urgent: 'Urgent',
  DueStatusBucket.target: 'Target',
  DueStatusBucket.normal: 'Tasks',
  DueStatusBucket.scheduled: 'Scheduled',
  DueStatusBucket.completed: 'Completed',
};

const _kRecurrenceLabels = <RecurrenceFilter, String>{
  RecurrenceFilter.all: 'Any',
  RecurrenceFilter.scheduled: 'Scheduled',
  RecurrenceFilter.completed: 'Completed',
  RecurrenceFilter.none: 'None',
};

const _kPointsBarLabels = ['1', '2', '3', '5', '8', '13'];

const _kAgePresets = <int?, String>{
  null: 'Any',
  7: '≤ 7d',
  30: '≤ 30d',
  90: '≤ 90d',
};

/// Unified Group / Sort / Filter bottom sheet (TM-359). Opened from each
/// list surface's app-bar `Icons.tune` button. Edits the per-surface
/// `taskListViewStateProvider(surface)` directly — mutations land in
/// SharedPreferences on every tap and the underlying screen rebuilds in
/// real time, so there's no "Apply" button.
class ViewOptionsSheet extends ConsumerWidget {
  final TaskListSurface surface;

  const ViewOptionsSheet({super.key, required this.surface});

  /// Convenience for the canonical invocation site:
  /// `ViewOptionsSheet.show(context, surface: TaskListSurface.tasks)`.
  static Future<void> show(
    BuildContext context, {
    required TaskListSurface surface,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ViewOptionsSheet(surface: surface),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskListViewStateProvider(surface));
    final notifier = ref.read(taskListViewStateProvider(surface).notifier);

    return Container(
      decoration: const BoxDecoration(
        color: TaskColors.popupBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onClose: () => Navigator.of(context).pop()),
                const _Divider(),
                _SectionTitle('Group'),
                _GroupAxisChips(
                  current: view.groupAxis,
                  onSelected: notifier.setGroupAxis,
                ),
                const _Divider(),
                _SectionTitle('Sort'),
                _SortAxisChips(
                  currentAxis: view.sortAxis,
                  currentDirection: view.sortDirection,
                  onAxisSelected: notifier.setSortAxis,
                  onToggleDirection: notifier.toggleSortDirection,
                ),
                const _Divider(),
                _SectionTitle('Filter'),
                _FilterSection(
                  surface: surface,
                  filters: view.filters,
                  onChange: notifier.setFilters,
                ),
                const _Divider(),
                _Footer(
                  collapseCount: view.collapsedGroups.length,
                  onExpandAll: notifier.expandAll,
                  onReset: notifier.reset,
                ),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
      child: Row(
        children: [
          const Text(
            'View options',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClose,
            style: TextButton.styleFrom(
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
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

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
      );
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ChoiceChips<T> extends StatelessWidget {
  final List<T> options;
  final String Function(T) labelOf;
  final T current;
  final ValueChanged<T> onSelected;
  const _ChoiceChips({
    required this.options,
    required this.labelOf,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final o in options)
            ChoiceChip(
              label: Text(labelOf(o)),
              selected: o == current,
              onSelected: (sel) {
                if (sel) onSelected(o);
              },
            ),
        ],
      ),
    );
  }
}

class _GroupAxisChips extends StatelessWidget {
  final TaskGroupAxis current;
  final ValueChanged<TaskGroupAxis> onSelected;
  const _GroupAxisChips({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _ChoiceChips<TaskGroupAxis>(
      options: TaskGroupAxis.values,
      labelOf: (a) => _kGroupAxisLabels[a]!,
      current: current,
      onSelected: onSelected,
    );
  }
}

class _SortAxisChips extends StatelessWidget {
  final TaskSortAxis currentAxis;
  final SortDirection currentDirection;
  final ValueChanged<TaskSortAxis> onAxisSelected;
  final VoidCallback onToggleDirection;
  const _SortAxisChips({
    required this.currentAxis,
    required this.currentDirection,
    required this.onAxisSelected,
    required this.onToggleDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChoiceChips<TaskSortAxis>(
          options: TaskSortAxis.values,
          labelOf: (a) => _kSortAxisLabels[a]!,
          current: currentAxis,
          onSelected: onAxisSelected,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            children: [
              const Text(
                'Direction',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 18,
                onPressed: onToggleDirection,
                icon: Icon(currentDirection == SortDirection.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward),
                color: Colors.white,
                tooltip: currentDirection == SortDirection.ascending
                    ? 'Ascending'
                    : 'Descending',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterSection extends ConsumerWidget {
  final TaskListSurface surface;
  final TaskFilters filters;
  final ValueChanged<TaskFilters> onChange;
  const _FilterSection({
    required this.surface,
    required this.filters,
    required this.onChange,
  });

  void _mutate(void Function(TaskFiltersBuilder) update) {
    onChange(filters.rebuild(update));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterLabel('Search'),
          _FilterSearchField(
            value: filters.search,
            onChanged: (s) => _mutate((b) => b..search = s),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Areas'),
          AreaMultiPicker(
            selected: filters.areas.toSet(),
            onChanged: (set) =>
                _mutate((b) => b..areas.replace(set)),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Contexts'),
          _ContextFilterChips(
            selected: filters.contexts.toSet(),
            onChanged: (set) =>
                _mutate((b) => b..contexts.replace(set)),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Due status'),
          _DueStatusChips(
            selected: filters.dueStatus.toSet(),
            onChanged: (set) =>
                _mutate((b) => b..dueStatus.replace(set)),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Priority'),
          _BoundsRow(
            minValue: filters.minPriority,
            maxValue: filters.maxPriority,
            segments: 5,
            labels: const ['1', '2', '3', '4', '5'],
            accent: SegmentedBarAccent.priority,
            onMinChanged: (v) => _mutate((b) => b..minPriority = v),
            onMaxChanged: (v) => _mutate((b) => b..maxPriority = v),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Points'),
          _PointsBoundsRow(
            minValue: filters.minPoints,
            maxValue: filters.maxPoints,
            onMinChanged: (v) => _mutate((b) => b..minPoints = v),
            onMaxChanged: (v) => _mutate((b) => b..maxPoints = v),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Recurrence'),
          _ChoiceChips<RecurrenceFilter>(
            options: RecurrenceFilter.values,
            labelOf: (r) => _kRecurrenceLabels[r]!,
            current: filters.recurrence,
            onSelected: (r) => _mutate((b) => b..recurrence = r),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Age'),
          _AgeChips(
            value: filters.maxAgeDays,
            onChanged: (d) => _mutate((b) => b..maxAgeDays = d),
          ),
          const SizedBox(height: 12),
          _FilterLabel('Toggles'),
          _BoolRow(
            label: 'Show scheduled',
            value: filters.showScheduled,
            onChanged: (v) => _mutate((b) => b..showScheduled = v),
          ),
          _BoolRow(
            label: 'Show completed',
            value: filters.showCompleted,
            onChanged: (v) => _mutate((b) => b..showCompleted = v),
          ),
          if (surface == TaskListSurface.family)
            _BoolRow(
              label: 'Owned by me only',
              value: filters.ownedByMeOnly,
              onChanged: (v) => _mutate((b) => b..ownedByMeOnly = v),
            ),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String label;
  const _FilterLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _FilterSearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _FilterSearchField({required this.value, required this.onChanged});

  @override
  State<_FilterSearchField> createState() => _FilterSearchFieldState();
}

class _FilterSearchFieldState extends State<_FilterSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _FilterSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External resets (e.g. "Reset to defaults") must propagate into the
    // TextField. Skipping when the strings already match avoids stomping
    // cursor position during the round-trip from the user's keystroke.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search task names…',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _ContextFilterChips extends ConsumerWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const _ContextFilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContexts = ref.watch(contextsProvider);
    final ctxs = asyncContexts.value ?? const [];
    if (ctxs.isEmpty) {
      return Text(
        'No contexts to filter by.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.50),
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      );
    }
    final knownNames = ctxs.map((c) => c.name.toLowerCase()).toSet();
    final ghostNames = selected
        .where((s) => !knownNames.contains(s.toLowerCase()))
        .toList()
      ..sort();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final ctx in ctxs)
          FilterChip(
            label: Text(ctx.name),
            selected: selected
                .map((s) => s.toLowerCase())
                .contains(ctx.name.toLowerCase()),
            onSelected: (sel) {
              final next = {...selected};
              if (sel) {
                next.add(ctx.name);
              } else {
                next.removeWhere(
                    (s) => s.toLowerCase() == ctx.name.toLowerCase());
              }
              onChanged(next);
            },
          ),
        for (final ghost in ghostNames)
          FilterChip(
            // Strike-through marks the name as no longer in the catalog.
            label: Text(
              ghost,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
            selected: true,
            onSelected: (_) {
              final next = {...selected}..removeWhere(
                  (s) => s.toLowerCase() == ghost.toLowerCase());
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _DueStatusChips extends StatelessWidget {
  final Set<DueStatusBucket> selected;
  final ValueChanged<Set<DueStatusBucket>> onChanged;
  const _DueStatusChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final b in DueStatusBucket.values)
          FilterChip(
            label: Text(_kDueStatusLabels[b]!),
            selected: selected.contains(b),
            onSelected: (sel) {
              final next = {...selected};
              if (sel) {
                next.add(b);
              } else {
                next.remove(b);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _BoundsRow extends StatelessWidget {
  final int? minValue;
  final int? maxValue;
  final int segments;
  final List<String> labels;
  final SegmentedBarAccent accent;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  const _BoundsRow({
    required this.minValue,
    required this.maxValue,
    required this.segments,
    required this.labels,
    required this.accent,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoundLabeledBar(
          label: 'Min',
          value: minValue,
          segments: segments,
          labels: labels,
          accent: accent,
          onChanged: onMinChanged,
        ),
        const SizedBox(height: 6),
        _BoundLabeledBar(
          label: 'Max',
          value: maxValue,
          segments: segments,
          labels: labels,
          accent: accent,
          onChanged: onMaxChanged,
        ),
      ],
    );
  }
}

class _BoundLabeledBar extends StatelessWidget {
  final String label;
  final int? value;
  final int segments;
  final List<String> labels;
  final SegmentedBarAccent accent;
  final ValueChanged<int?> onChanged;
  const _BoundLabeledBar({
    required this.label,
    required this.value,
    required this.segments,
    required this.labels,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SegmentedBar(
            value: value,
            segments: segments,
            labels: labels,
            accent: accent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Min/max bounds for points use Fibonacci-aligned segments. The
/// SegmentedBar returns a 1-based index into the segment list; we map it
/// to the actual Fibonacci value before passing to the filter.
class _PointsBoundsRow extends StatelessWidget {
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  const _PointsBoundsRow({
    required this.minValue,
    required this.maxValue,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  static const _values = [1, 2, 3, 5, 8, 13];

  int? _indexOf(int? value) {
    if (value == null) return null;
    final i = _values.indexOf(value);
    return i < 0 ? null : i + 1;
  }

  int? _valueOf(int? oneBasedIndex) {
    if (oneBasedIndex == null) return null;
    final i = oneBasedIndex - 1;
    if (i < 0 || i >= _values.length) return null;
    return _values[i];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoundLabeledBar(
          label: 'Min',
          value: _indexOf(minValue),
          segments: 6,
          labels: _kPointsBarLabels,
          accent: SegmentedBarAccent.points,
          onChanged: (idx) => onMinChanged(_valueOf(idx)),
        ),
        const SizedBox(height: 6),
        _BoundLabeledBar(
          label: 'Max',
          value: _indexOf(maxValue),
          segments: 6,
          labels: _kPointsBarLabels,
          accent: SegmentedBarAccent.points,
          onChanged: (idx) => onMaxChanged(_valueOf(idx)),
        ),
      ],
    );
  }
}

class _AgeChips extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _AgeChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in _kAgePresets.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: value == entry.key,
            onSelected: (_) => onChanged(entry.key),
          ),
      ],
    );
  }
}

class _BoolRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13.5),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: TaskColors.highlight,
    );
  }
}

class _Footer extends StatelessWidget {
  final int collapseCount;
  final VoidCallback onExpandAll;
  final VoidCallback onReset;
  const _Footer({
    required this.collapseCount,
    required this.onExpandAll,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      child: Row(
        children: [
          if (collapseCount > 0)
            TextButton.icon(
              onPressed: onExpandAll,
              icon: const Icon(Icons.unfold_more, size: 16),
              label: Text('Expand all ($collapseCount)'),
            ),
          const Spacer(),
          TextButton(
            onPressed: onReset,
            child: const Text('Reset to defaults'),
          ),
        ],
      ),
    );
  }
}


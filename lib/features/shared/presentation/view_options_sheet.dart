import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/task_colors.dart';
import '../../../models/task_list_view.dart';
import '../../areas/providers/area_providers.dart';
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

const _kAgePresets = <int?, String>{
  null: 'Any',
  7: 'Last 7 days',
  30: 'Last 30 days',
  90: 'Last 90 days',
};

/// Cards-blue accent for selected state in this sheet's chips and
/// checkboxes — matches the surface of the task cards on the screen
/// behind so the visual language stays consistent (matches TM-359 review
/// feedback).
const Color _kSelectionAccent = TaskColors.cardColor;

/// View options bottom sheet (TM-359). Edits a *working copy* of the
/// per-surface `TaskListView` and only commits via "Apply Changes." A
/// sticky bottom row keeps Cancel / Apply visible without competing
/// with the phone's status bar.
class ViewOptionsSheet extends ConsumerStatefulWidget {
  final TaskListSurface surface;

  const ViewOptionsSheet({super.key, required this.surface});

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
  ConsumerState<ViewOptionsSheet> createState() => _ViewOptionsSheetState();
}

class _ViewOptionsSheetState extends ConsumerState<ViewOptionsSheet> {
  late TaskListView _working;

  /// Per-axis transient "all-deselected" flag — distinct from the saved
  /// empty-set sentinel. When true for an axis, the dropdown renders no
  /// items as checked (user just clicked Deselect All); user can then
  /// build a fresh selection. Once they tick any item, the flag drops
  /// and the working copy carries an explicit non-empty set.
  bool _areasDeselectedAll = false;
  bool _contextsDeselectedAll = false;
  bool _dueStatusDeselectedAll = false;

  @override
  void initState() {
    super.initState();
    _working = ref.read(taskListViewStateProvider(widget.surface));
  }

  void _mutateFilters(void Function(TaskFiltersBuilder) update) {
    setState(() {
      _working = _working
          .rebuild((b) => b..filters.replace(_working.filters.rebuild(update)));
    });
  }

  void _setGroupAxis(TaskGroupAxis axis) {
    setState(() => _working = _working.rebuild((b) => b.groupAxis = axis));
  }

  void _setSortAxis(TaskSortAxis axis) {
    setState(() => _working = _working.rebuild((b) => b.sortAxis = axis));
  }

  void _toggleSortDirection() {
    setState(() => _working = _working.rebuild((b) {
          b.sortDirection = _working.sortDirection == SortDirection.ascending
              ? SortDirection.descending
              : SortDirection.ascending;
        }));
  }

  void _onCancel() => Navigator.of(context).pop();

  void _onApply() {
    final notifier =
        ref.read(taskListViewStateProvider(widget.surface).notifier);
    final current = ref.read(taskListViewStateProvider(widget.surface));
    if (current.groupAxis != _working.groupAxis) {
      notifier.setGroupAxis(_working.groupAxis);
    }
    if (current.sortAxis != _working.sortAxis) {
      notifier.setSortAxis(_working.sortAxis);
    }
    if (current.sortDirection != _working.sortDirection) {
      notifier.setSortDirection(_working.sortDirection);
    }
    if (current.filters != _working.filters) {
      notifier.setFilters(_working.filters);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Text(
                  'View options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GroupSortRow(
                        groupAxis: _working.groupAxis,
                        sortAxis: _working.sortAxis,
                        sortDirection: _working.sortDirection,
                        onGroupChanged: _setGroupAxis,
                        onSortChanged: _setSortAxis,
                        onDirectionToggle: _toggleSortDirection,
                      ),
                      const SizedBox(height: 12),
                      _SectionDivider('Filter by'),
                      _AreasDropdown(
                        selected: _working.filters.areas.toSet(),
                        deselectedAll: _areasDeselectedAll,
                        onChanged: (set, deselectedAll) {
                          setState(() {
                            _areasDeselectedAll = deselectedAll;
                          });
                          _mutateFilters(
                              (b) => b..areas.replace(set));
                        },
                      ),
                      const SizedBox(height: 8),
                      _ContextsDropdown(
                        selected: _working.filters.contexts.toSet(),
                        deselectedAll: _contextsDeselectedAll,
                        onChanged: (set, deselectedAll) {
                          setState(() {
                            _contextsDeselectedAll = deselectedAll;
                          });
                          _mutateFilters(
                              (b) => b..contexts.replace(set));
                        },
                      ),
                      const SizedBox(height: 8),
                      _DueStatusDropdown(
                        selected: _working.filters.dueStatus.toSet(),
                        deselectedAll: _dueStatusDeselectedAll,
                        onChanged: (set, deselectedAll) {
                          setState(() {
                            _dueStatusDeselectedAll = deselectedAll;
                          });
                          _mutateFilters(
                              (b) => b..dueStatus.replace(set));
                        },
                      ),
                      const SizedBox(height: 8),
                      _RecurrenceDropdown(
                        value: _working.filters.recurrence,
                        onChanged: (r) =>
                            _mutateFilters((b) => b..recurrence = r),
                      ),
                      const SizedBox(height: 8),
                      _AgeDropdown(
                        value: _working.filters.maxAgeDays,
                        onChanged: (d) =>
                            _mutateFilters((b) => b..maxAgeDays = d),
                      ),
                      const SizedBox(height: 12),
                      _SectionDivider('Priority'),
                      _BoundsRow(
                        minValue: _working.filters.minPriority,
                        maxValue: _working.filters.maxPriority,
                        segments: 5,
                        labels: const ['1', '2', '3', '4', '5'],
                        accent: SegmentedBarAccent.priority,
                        onMinChanged: (v) =>
                            _mutateFilters((b) => b..minPriority = v),
                        onMaxChanged: (v) =>
                            _mutateFilters((b) => b..maxPriority = v),
                      ),
                      const SizedBox(height: 12),
                      _SectionDivider('Points'),
                      _PointsBoundsRow(
                        minValue: _working.filters.minPoints,
                        maxValue: _working.filters.maxPoints,
                        onMinChanged: (v) =>
                            _mutateFilters((b) => b..minPoints = v),
                        onMaxChanged: (v) =>
                            _mutateFilters((b) => b..maxPoints = v),
                      ),
                      if (widget.surface == TaskListSurface.family) ...[
                        const SizedBox(height: 12),
                        _SectionDivider('Family'),
                        _OwnedByMeRow(
                          value: _working.filters.ownedByMeOnly,
                          onChanged: (v) => _mutateFilters(
                              (b) => b..ownedByMeOnly = v),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _StickyBottomBar(onCancel: _onCancel, onApply: _onApply),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 6),
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

class _StickyBottomBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const _StickyBottomBar({required this.onCancel, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: TaskColors.popupBg,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: _kSelectionAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Apply Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSortRow extends StatelessWidget {
  final TaskGroupAxis groupAxis;
  final TaskSortAxis sortAxis;
  final SortDirection sortDirection;
  final ValueChanged<TaskGroupAxis> onGroupChanged;
  final ValueChanged<TaskSortAxis> onSortChanged;
  final VoidCallback onDirectionToggle;

  const _GroupSortRow({
    required this.groupAxis,
    required this.sortAxis,
    required this.sortDirection,
    required this.onGroupChanged,
    required this.onSortChanged,
    required this.onDirectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _LabeledDropdown<TaskGroupAxis>(
            label: 'Group',
            value: groupAxis,
            items: TaskGroupAxis.values,
            labelOf: (a) => _kGroupAxisLabels[a]!,
            onChanged: onGroupChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LabeledDropdown<TaskSortAxis>(
            label: 'Sort',
            value: sortAxis,
            items: TaskSortAxis.values,
            labelOf: (a) => _kSortAxisLabels[a]!,
            onChanged: onSortChanged,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: IconButton(
            iconSize: 18,
            onPressed: onDirectionToggle,
            icon: Icon(sortDirection == SortDirection.ascending
                ? Icons.arrow_upward
                : Icons.arrow_downward),
            color: Colors.white,
            tooltip: sortDirection == SortDirection.ascending
                ? 'Ascending'
                : 'Descending',
          ),
        ),
      ],
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: TaskColors.popupBg,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelOf(item)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 4),
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

// ─── Multi-select dropdowns ──────────────────────────────────────────────

/// Callback signature: (newSelection, isDeselectAllTransient).
typedef _MultiSelectChanged<T> = void Function(Set<T> selection,
    bool isDeselectAllTransient);

/// Shared "dropdown button → modal multi-select" widget. The dropdown
/// displays a summary ("All" / "N selected" / "None"); tapping opens a
/// scrollable checkbox list with Select All / Deselect All actions. The
/// "None" summary is only shown when the user has just hit Deselect All;
/// an empty saved set is "All" (no filter, every item logically
/// included).
class _MultiSelectDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final Set<T> selected;
  final bool deselectedAll;
  final _MultiSelectChanged<T> onChanged;
  final String? emptyItemsHint;

  const _MultiSelectDropdown({
    required this.label,
    required this.items,
    required this.labelOf,
    required this.selected,
    required this.deselectedAll,
    required this.onChanged,
    this.emptyItemsHint,
  });

  String _summary() {
    if (deselectedAll) return 'None';
    if (selected.isEmpty || selected.length == items.length) return 'All';
    return '${selected.length} selected';
  }

  Future<void> _open(BuildContext context) async {
    // Compute the initial "displayed checked" set: if working state is
    // empty AND not Deselect-All-transient, treat as all checked.
    final initiallyChecked = deselectedAll
        ? <T>{}
        : (selected.isEmpty
            ? items.toSet()
            : selected.where(items.contains).toSet());
    var working = {...initiallyChecked};
    var transientDeselectAll = deselectedAll;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void toggle(T item) {
              setSheetState(() {
                if (working.contains(item)) {
                  working.remove(item);
                } else {
                  working.add(item);
                  transientDeselectAll = false;
                }
              });
            }

            void selectAll() {
              setSheetState(() {
                working = items.toSet();
                transientDeselectAll = false;
              });
            }

            void deselectAll() {
              setSheetState(() {
                working = <T>{};
                transientDeselectAll = true;
              });
            }

            void done() {
              // If everything is checked, save as empty (= "no filter,
              // show all" — also auto-reacts to catalog growth).
              // Otherwise save the explicit set.
              final Set<T> toSave;
              final bool savedDeselectAll;
              if (transientDeselectAll && working.isEmpty) {
                toSave = <T>{};
                savedDeselectAll = true;
              } else if (working.length == items.length) {
                toSave = <T>{};
                savedDeselectAll = false;
              } else {
                toSave = {...working};
                savedDeselectAll = false;
              }
              onChanged(toSave, savedDeselectAll);
              Navigator.of(sheetContext).pop();
            }

            return Container(
              decoration: const BoxDecoration(
                color: TaskColors.popupBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(18, 14, 12, 12),
                        child: Row(
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: done,
                              style: TextButton.styleFrom(
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.70),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: selectAll,
                            child: const Text('Select all'),
                          ),
                          TextButton(
                            onPressed: deselectAll,
                            child: const Text('Deselect all'),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      Flexible(
                        child: items.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  emptyItemsHint ?? 'Nothing to filter by.',
                                  style: TextStyle(
                                    color: Colors.white60
                                        .withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4),
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  final item = items[i];
                                  return CheckboxListTile(
                                    value: working.contains(item),
                                    onChanged: (_) => toggle(item),
                                    title: Text(
                                      labelOf(item),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    activeColor: _kSelectionAccent,
                                    checkColor: Colors.white,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _summary(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    color: Colors.white.withValues(alpha: 0.65)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AreasDropdown extends ConsumerWidget {
  final Set<String> selected;
  final bool deselectedAll;
  final _MultiSelectChanged<String> onChanged;
  const _AreasDropdown({
    required this.selected,
    required this.deselectedAll,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasProvider).value ?? const [];
    final names = areas.map((a) => a.name).toList();
    return _MultiSelectDropdown<String>(
      label: 'Areas',
      items: names,
      labelOf: (s) => s,
      selected: selected,
      deselectedAll: deselectedAll,
      onChanged: onChanged,
      emptyItemsHint: 'No areas to filter by yet.',
    );
  }
}

class _ContextsDropdown extends ConsumerWidget {
  final Set<String> selected;
  final bool deselectedAll;
  final _MultiSelectChanged<String> onChanged;
  const _ContextsDropdown({
    required this.selected,
    required this.deselectedAll,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctxs = ref.watch(contextsProvider).value ?? const [];
    final names = ctxs.map((c) => c.name).toList();
    return _MultiSelectDropdown<String>(
      label: 'Contexts',
      items: names,
      labelOf: (s) => s,
      selected: selected,
      deselectedAll: deselectedAll,
      onChanged: onChanged,
      emptyItemsHint: 'No contexts to filter by yet.',
    );
  }
}

class _DueStatusDropdown extends StatelessWidget {
  final Set<DueStatusBucket> selected;
  final bool deselectedAll;
  final _MultiSelectChanged<DueStatusBucket> onChanged;
  const _DueStatusDropdown({
    required this.selected,
    required this.deselectedAll,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _MultiSelectDropdown<DueStatusBucket>(
      label: 'Due status',
      items: DueStatusBucket.values,
      labelOf: (b) => _kDueStatusLabels[b]!,
      selected: selected,
      deselectedAll: deselectedAll,
      onChanged: onChanged,
    );
  }
}

class _RecurrenceDropdown extends StatelessWidget {
  final RecurrenceFilter value;
  final ValueChanged<RecurrenceFilter> onChanged;
  const _RecurrenceDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _LabeledDropdown<RecurrenceFilter>(
      label: 'Recurrence',
      value: value,
      items: RecurrenceFilter.values,
      labelOf: (r) => _kRecurrenceLabels[r]!,
      onChanged: onChanged,
    );
  }
}

class _AgeDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _AgeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final entries = _kAgePresets.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _FieldLabel('Age'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: value,
              isExpanded: true,
              dropdownColor: TaskColors.popupBg,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                for (final e in entries)
                  DropdownMenuItem<int?>(
                    value: e.key,
                    child: Text(e.value),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
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
  static const _labels = ['1', '2', '3', '5', '8', '13'];

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
          labels: _labels,
          accent: SegmentedBarAccent.points,
          onChanged: (idx) => onMinChanged(_valueOf(idx)),
        ),
        const SizedBox(height: 6),
        _BoundLabeledBar(
          label: 'Max',
          value: _indexOf(maxValue),
          segments: 6,
          labels: _labels,
          accent: SegmentedBarAccent.points,
          onChanged: (idx) => onMaxChanged(_valueOf(idx)),
        ),
      ],
    );
  }
}

class _OwnedByMeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _OwnedByMeRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Owned by me only',
        style: TextStyle(color: Colors.white, fontSize: 13.5),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: _kSelectionAccent,
    );
  }
}

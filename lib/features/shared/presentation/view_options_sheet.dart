import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/form_factor.dart';
import '../../../models/task_colors.dart';
import '../../../models/task_list_view.dart';
import '../../areas/providers/area_providers.dart';
import '../../contexts/providers/context_providers.dart';
import '../../shared/providers/selected_task_providers.dart';
import '../../shared/providers/task_list_view_providers.dart';
import 'widgets/length_bucket_picker.dart';
import 'widgets/points_picker.dart';
import 'widgets/segmented_bar.dart';

const _kGroupAxisLabels = <TaskGroupAxis, String>{
  TaskGroupAxis.dueStatus: 'Due Status',
  TaskGroupAxis.none: 'None',
  TaskGroupAxis.priority: 'Priority',
  TaskGroupAxis.area: 'Area',
  TaskGroupAxis.points: 'Points',
  TaskGroupAxis.duration: 'Estimated Time',
};

const _kSortAxisLabels = <TaskSortAxis, String>{
  TaskSortAxis.urgency: 'Urgency',
  TaskSortAxis.dateAdded: 'Date Added',
  TaskSortAxis.points: 'Points',
  TaskSortAxis.area: 'Area',
  TaskSortAxis.duration: 'Estimated Time',
  TaskSortAxis.priority: 'Priority',
  TaskSortAxis.efficiency: 'Efficiency',
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

/// AppBar action button that opens the View Options sheet for [surface].
/// Shows a small green dot overlay when the saved view for that surface
/// differs from the per-surface default in any group/sort/filter axis
/// (search and collapse state excluded). Mirrors the green ring used on
/// individual fields inside the sheet so non-default state is visible at
/// a glance from the task-list screen.
class ViewOptionsButton extends ConsumerWidget {
  final TaskListSurface surface;
  final String tooltip;

  const ViewOptionsButton({
    super.key,
    required this.surface,
    this.tooltip = 'View options',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(taskListViewStateProvider(surface));
    final hasNonDefaults = !view.isDefaultForSurface(surface);
    final button = IconButton(
      icon: const Icon(Icons.tune),
      tooltip: tooltip,
      onPressed: () => _open(context, ref),
    );
    if (!hasNonDefaults) return button;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        button,
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: _ChangedFieldHighlight.accent,
              shape: BoxShape.circle,
              border: Border.all(color: TaskColors.menuColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// Wide two-pane path (TM-385): flip the right pane into the View
  /// Options mode and force-expand the panel for this surface (so a
  /// user who previously collapsed the panel sees the full UI on
  /// re-open). Otherwise (phone / sub-two-pane wide): keep the
  /// existing bottom-sheet behavior.
  ///
  /// Editor ⟺ View Options mutual exclusivity is **structural** —
  /// `RightPane` holds one `RightPaneMode`; setting `.viewOptions`
  /// automatically displaces `.editor`. Selection isn't cleared (the
  /// editor was just hidden); switching back via a row tap restores
  /// `.editor` for the existing selection through the
  /// `RightPaneSelectionSync` listener.
  void _open(BuildContext context, WidgetRef ref) {
    if (isTwoPaneWideLayout(MediaQuery.sizeOf(context))) {
      ref
          .read(taskListViewStateProvider(surface).notifier)
          .setViewOptionsCollapsed(false);
      ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.viewOptions);
    } else {
      ViewOptionsSheet.show(context, surface: surface);
    }
  }
}

/// View options bottom sheet (TM-359). Thin chrome wrapper around
/// [ViewOptionsPanelContent] for the phone path: rounded-top container,
/// SafeArea, keyboard inset padding. The body itself (header + scroll
/// + sticky action bar) is shared with the wide-layout side panel
/// (TM-385) via [ViewOptionsPanelContent].
class ViewOptionsSheet extends StatelessWidget {
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
      useSafeArea: true,
      builder: (_) => ViewOptionsSheet(surface: surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TaskColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ViewOptionsPanelContent(
            surface: surface,
            // Phone bottom sheet: Cancel + post-Apply both pop the
            // sheet (matches the pre-TM-385 contract). The wide
            // side panel (Story 5) passes a different callback that
            // collapses the panel rather than dismissing.
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

/// Shared View Options body — header + scrollable Group/Sort/Filter
/// controls + sticky Cancel/Apply action bar. Hosted by:
///   - [ViewOptionsSheet] on phone (bottom sheet chrome)
///   - `DockedViewOptionsPane` on wide (right pane chrome — TM-385
///     Story 5)
///
/// Owns the working-copy edit state: every mutator writes a fresh
/// `_working: TaskListView`; Apply commits the diff to
/// `taskListViewStateProvider(surface).notifier`. Cancel + post-Apply
/// invoke [onClose].
class ViewOptionsPanelContent extends ConsumerStatefulWidget {
  final TaskListSurface surface;
  final VoidCallback onClose;

  const ViewOptionsPanelContent({
    super.key,
    required this.surface,
    required this.onClose,
  });

  @override
  ConsumerState<ViewOptionsPanelContent> createState() =>
      _ViewOptionsPanelContentState();
}

class _ViewOptionsPanelContentState
    extends ConsumerState<ViewOptionsPanelContent> {
  late TaskListView _working;

  /// Per-axis transient "all-deselected" flag — distinct from the saved
  /// empty-set sentinel. When true for an axis, the dropdown renders no
  /// items as checked (user just clicked Deselect All); user can then
  /// build a fresh selection. Once they tick any item, the flag drops
  /// and the working copy carries an explicit non-empty set.
  bool _areasDeselectedAll = false;
  bool _contextsDeselectedAll = false;
  bool _dueStatusDeselectedAll = false;

  /// True once the user has applied any local mutation (any field
  /// setter, Reset, multi-select commit). While false, build() keeps
  /// `_working` synced with the watched `saved` state — covers the
  /// case where SharedPreferences hydrates async after initState, or
  /// an external write lands while the sheet is open. Without this,
  /// the working copy would stay at the in-memory default and the
  /// dirty check (`_working != saved`) would fire spuriously.
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _working = ref.read(taskListViewStateProvider(widget.surface));
  }

  void _mutateFilters(void Function(TaskFiltersBuilder) update) {
    setState(() {
      _touched = true;
      _working = _working.rebuild(
        (b) => b..filters.replace(_working.filters.rebuild(update)),
      );
    });
  }

  void _setGroupAxis(TaskGroupAxis axis) {
    setState(() {
      _touched = true;
      _working = _working.rebuild((b) => b.groupAxis = axis);
    });
  }

  void _setSortAxis(TaskSortAxis axis) {
    setState(() {
      _touched = true;
      _working = _working.rebuild((b) => b.sortAxis = axis);
    });
  }

  void _toggleSortDirection() {
    setState(() {
      _touched = true;
      _working = _working.rebuild((b) {
        b.sortDirection = _working.sortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending;
      });
    });
  }

  // ── Min/Max bounds setters (clamp the dependent bound so min ≤ max) ──
  //
  // Each pair mutates one bound and pushes the other if the new value
  // would invert the range. Extracted from the bounds-row callback
  // closures so call sites can pass these directly via tear-off.

  void _setMinPriority(int? v) => _mutateFilters((b) {
    b.minPriority = v;
    if (v != null && b.maxPriority != null && b.maxPriority! < v) {
      b.maxPriority = v;
    }
  });
  void _setMaxPriority(int? v) => _mutateFilters((b) {
    b.maxPriority = v;
    if (v != null && b.minPriority != null && b.minPriority! > v) {
      b.minPriority = v;
    }
  });

  void _setMinPoints(int? v) => _mutateFilters((b) {
    b.minPoints = v;
    if (v != null && b.maxPoints != null && b.maxPoints! < v) {
      b.maxPoints = v;
    }
  });
  void _setMaxPoints(int? v) => _mutateFilters((b) {
    b.maxPoints = v;
    if (v != null && b.minPoints != null && b.minPoints! > v) {
      b.minPoints = v;
    }
  });

  void _setMinDuration(int? v) => _mutateFilters((b) {
    b.minDuration = v;
    if (v != null && b.maxDuration != null && b.maxDuration! < v) {
      b.maxDuration = v;
    }
  });
  void _setMaxDuration(int? v) => _mutateFilters((b) {
    b.maxDuration = v;
    if (v != null && b.minDuration != null && b.minDuration! > v) {
      b.minDuration = v;
    }
  });

  /// Per-axis validation: a multi-select is in "accidentally empty"
  /// state when the working set is empty, the user has not explicitly
  /// hit Deselect All (transient flag is false), and the empty state
  /// differs from this surface's default. The error rule blocks Apply
  /// for those cases so a user who unchecks every chip individually
  /// gets explicit feedback rather than silently saving "show all" —
  /// which is the persistence semantic for an empty set but probably
  /// NOT what the user intended.
  ///
  /// Reset-to-defaults is unaffected: it puts working == default, so
  /// the third condition fails and Apply remains enabled. Deselect-All
  /// is also unaffected (transient flag is true).
  List<String> _validationErrors() {
    final wf = _working.filters;
    final df = TaskListView.defaultForSurface(widget.surface).filters;
    final errors = <String>[];
    if (wf.dueStatus.isEmpty &&
        !_dueStatusDeselectedAll &&
        wf.dueStatus != df.dueStatus) {
      errors.add('Due status');
    }
    if (wf.areas.isEmpty && !_areasDeselectedAll && wf.areas != df.areas) {
      errors.add('Areas');
    }
    if (wf.contexts.isEmpty &&
        !_contextsDeselectedAll &&
        wf.contexts != df.contexts) {
      errors.add('Contexts');
    }
    return errors;
  }

  void _onCancel() => widget.onClose();

  void _onResetToDefaults() {
    setState(() {
      _touched = true;
      _working = TaskListView.defaultForSurface(widget.surface);
      _areasDeselectedAll = false;
      _contextsDeselectedAll = false;
      _dueStatusDeselectedAll = false;
    });
  }

  void _onApply() {
    final notifier = ref.read(
      taskListViewStateProvider(widget.surface).notifier,
    );
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
    if (!mounted) return;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(taskListViewStateProvider(widget.surface));
    // While the user hasn't made any local edit, keep the working copy
    // synced with whatever `saved` resolves to. Covers two cases:
    //   1. SharedPreferences hydrates asynchronously: initState's
    //      `ref.read` captures the in-memory default, then later the
    //      persisted state lands and `saved` updates.
    //   2. An external write lands while the sheet is open (cross-
    //      device sync, another notifier, etc.).
    // Without this re-sync, the dirty check (`_working != saved`)
    // would false-positive on stale-default-vs-fresh-persisted and
    // Apply would silently clobber the freshly-loaded state back to
    // the default.
    if (!_touched && _working != saved) {
      _working = saved;
    }
    final dirty = _working != saved;
    final defaults = TaskListView.defaultForSurface(widget.surface);
    final df = defaults.filters;
    final wf = _working.filters;
    final errors = _validationErrors();
    final canApply = dirty && errors.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(onResetToDefaults: _onResetToDefaults),
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
                  groupChanged: _working.groupAxis != defaults.groupAxis,
                  sortChanged: _working.sortAxis != defaults.sortAxis,
                  directionChanged:
                      _working.sortDirection != defaults.sortDirection,
                  onGroupChanged: _setGroupAxis,
                  onSortChanged: _setSortAxis,
                  onDirectionToggle: _toggleSortDirection,
                ),
                const SizedBox(height: 12),
                _SectionDivider('Filter by'),
                _ChangedFieldHighlight(
                  changed: wf.dueStatus != df.dueStatus,
                  child: _DueStatusDropdown(
                    selected: _working.filters.dueStatus.toSet(),
                    deselectedAll: _dueStatusDeselectedAll,
                    onChanged: (set, deselectedAll) {
                      setState(() {
                        _dueStatusDeselectedAll = deselectedAll;
                      });
                      _mutateFilters((b) => b..dueStatus.replace(set));
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Estimated time'),
                _ChangedFieldHighlight(
                  changed:
                      wf.minDuration != df.minDuration ||
                      wf.maxDuration != df.maxDuration,
                  child: _DurationBoundsRow(
                    minValue: _working.filters.minDuration,
                    maxValue: _working.filters.maxDuration,
                    onMinChanged: _setMinDuration,
                    onMaxChanged: _setMaxDuration,
                  ),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Points'),
                _ChangedFieldHighlight(
                  changed:
                      wf.minPoints != df.minPoints ||
                      wf.maxPoints != df.maxPoints,
                  child: _PointsBoundsRow(
                    minValue: _working.filters.minPoints,
                    maxValue: _working.filters.maxPoints,
                    onMinChanged: _setMinPoints,
                    onMaxChanged: _setMaxPoints,
                  ),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Priority'),
                _ChangedFieldHighlight(
                  changed:
                      wf.minPriority != df.minPriority ||
                      wf.maxPriority != df.maxPriority,
                  child: _BoundsRow(
                    minValue: _working.filters.minPriority,
                    maxValue: _working.filters.maxPriority,
                    segments: 5,
                    labels: const ['1', '2', '3', '4', '5'],
                    accent: SegmentedBarAccent.priority,
                    onMinChanged: _setMinPriority,
                    onMaxChanged: _setMaxPriority,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChangedFieldHighlight(
                        changed: wf.areas != df.areas,
                        child: _AreasDropdown(
                          selected: _working.filters.areas.toSet(),
                          deselectedAll: _areasDeselectedAll,
                          onChanged: (set, deselectedAll) {
                            setState(() {
                              _areasDeselectedAll = deselectedAll;
                            });
                            _mutateFilters((b) => b..areas.replace(set));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChangedFieldHighlight(
                        changed: wf.contexts != df.contexts,
                        child: _ContextsDropdown(
                          selected: _working.filters.contexts.toSet(),
                          deselectedAll: _contextsDeselectedAll,
                          onChanged: (set, deselectedAll) {
                            setState(() {
                              _contextsDeselectedAll = deselectedAll;
                            });
                            _mutateFilters((b) => b..contexts.replace(set));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChangedFieldHighlight(
                        changed: wf.recurrence != df.recurrence,
                        child: _RecurrenceDropdown(
                          value: _working.filters.recurrence,
                          onChanged: (r) =>
                              _mutateFilters((b) => b..recurrence = r),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChangedFieldHighlight(
                        changed: wf.maxAgeDays != df.maxAgeDays,
                        child: _AgeDropdown(
                          value: _working.filters.maxAgeDays,
                          onChanged: (d) =>
                              _mutateFilters((b) => b..maxAgeDays = d),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.surface == TaskListSurface.family) ...[
                  const SizedBox(height: 12),
                  _SectionDivider('Family'),
                  _ChangedFieldHighlight(
                    changed: wf.ownedByMeOnly != df.ownedByMeOnly,
                    child: _OwnedByMeRow(
                      value: _working.filters.ownedByMeOnly,
                      onChanged: (v) =>
                          _mutateFilters((b) => b..ownedByMeOnly = v),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (errors.isNotEmpty) _ValidationBanner(fieldNames: errors),
        _StickyBottomBar(
          onCancel: _onCancel,
          onApply: canApply ? _onApply : null,
        ),
      ],
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

/// Pure resolver for `_MultiSelectDropdown._open`'s Done semantics.
/// Returns the `(saveSet, savedDeselectAll)` pair to hand back to the
/// parent state:
///
/// - working empty + transient flag set (Deselect All was pressed) →
///   save empty + flag=true. The empty set persists as "no filter,
///   show all"; the flag tells the parent to render the summary as
///   "None" so the user gets immediate visual confirmation that their
///   Deselect All click took effect.
/// - working contains every item → save empty + flag=false. Saving
///   empty here is intentional — it auto-reacts to catalog growth
///   (newly-added areas/contexts are included).
/// - any other case → save the explicit working set verbatim, flag=false.
///
/// Catalog-not-loaded handling and the "is working empty without
/// transient flag set" validation are the caller's responsibility.
(Set<T>, bool) _resolveMultiSelectSave<T>({
  required Set<T> working,
  required int itemsCount,
  required bool transientDeselectAll,
}) {
  if (transientDeselectAll && working.isEmpty) {
    return (<T>{}, true);
  }
  if (working.length == itemsCount) {
    return (<T>{}, false);
  }
  return ({...working}, false);
}

/// Sheet header strip: title on the left, Reset-to-defaults text button
/// on the right. Reset reverts the working copy only — Apply still
/// required to commit.
class _SheetHeader extends StatelessWidget {
  final VoidCallback onResetToDefaults;
  const _SheetHeader({required this.onResetToDefaults});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'View options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onResetToDefaults,
            icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
            label: const Text(
              'Reset to defaults',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline error banner shown immediately above the sticky bottom bar
/// when one or more multi-select axes are accidentally empty (working
/// set empty + transient flag false + working != surface default).
/// See `_validationErrors` for the rule. Apply is also disabled in
/// that state; the banner explains why.
class _ValidationBanner extends StatelessWidget {
  final List<String> fieldNames;
  const _ValidationBanner({required this.fieldNames});

  @override
  Widget build(BuildContext context) {
    final pluralS = fieldNames.length == 1 ? '' : 's';
    final list = fieldNames.join(', ');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE85D5D).withValues(alpha: 0.15),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE85D5D).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFE85D5D)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select at least one option for $list, '
              'or tap Deselect All to clear$pluralS explicitly.',
              style: const TextStyle(
                color: Color(0xFFF4B0B0),
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final VoidCallback onCancel;

  /// Null = Apply Changes disabled (working copy matches saved state).
  final VoidCallback? onApply;

  const _StickyBottomBar({required this.onCancel, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: TaskColors.cardColor,
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
                side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
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
  final bool groupChanged;
  final bool sortChanged;
  final bool directionChanged;
  final ValueChanged<TaskGroupAxis> onGroupChanged;
  final ValueChanged<TaskSortAxis> onSortChanged;
  final VoidCallback onDirectionToggle;

  const _GroupSortRow({
    required this.groupAxis,
    required this.sortAxis,
    required this.sortDirection,
    required this.groupChanged,
    required this.sortChanged,
    required this.directionChanged,
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
          child: _ChangedFieldHighlight(
            changed: groupChanged,
            child: _LabeledDropdown<TaskGroupAxis>(
              label: 'Group',
              value: groupAxis,
              items: TaskGroupAxis.values,
              labelOf: (a) => _kGroupAxisLabels[a]!,
              onChanged: onGroupChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChangedFieldHighlight(
            changed: sortChanged,
            child: _LabeledDropdown<TaskSortAxis>(
              label: 'Sort',
              value: sortAxis,
              items: TaskSortAxis.values,
              labelOf: (a) => _kSortAxisLabels[a]!,
              onChanged: onSortChanged,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _ChangedFieldHighlight(
            changed: directionChanged,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: IconButton(
              iconSize: 18,
              onPressed: onDirectionToggle,
              icon: Icon(
                sortDirection == SortDirection.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              color: Colors.white,
              tooltip: sortDirection == SortDirection.ascending
                  ? 'Ascending'
                  : 'Descending',
            ),
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
            color: TaskColors.cardColor,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: TaskColors.cardColor,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                for (final item in items)
                  DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
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
typedef _MultiSelectChanged<T> =
    void Function(Set<T> selection, bool isDeselectAllTransient);

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
      useSafeArea: true,
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
              // Catalog-not-loaded guard: if `items` is empty but the
              // user has a non-empty saved selection, the modal rendered
              // with zero chips and there's no meaningful edit they could
              // have made — treat Done as Cancel so we don't silently
              // overwrite their saved selection with empty.
              if (items.isEmpty && selected.isNotEmpty) {
                Navigator.of(sheetContext).pop();
                return;
              }
              final (toSave, savedDeselectAll) = _resolveMultiSelectSave<T>(
                working: working,
                itemsCount: items.length,
                transientDeselectAll: transientDeselectAll,
              );
              onChanged(toSave, savedDeselectAll);
              Navigator.of(sheetContext).pop();
            }

            return Container(
              decoration: const BoxDecoration(
                color: TaskColors.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                        padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
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
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
                                    color: Colors.white60.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  14,
                                  16,
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final item in items)
                                      _SelectableChip(
                                        label: labelOf(item),
                                        selected: working.contains(item),
                                        onTap: () => toggle(item),
                                      ),
                                  ],
                                ),
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
              color: TaskColors.cardColor,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _summary(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
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
            color: TaskColors.cardColor,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: value,
              isExpanded: true,
              dropdownColor: TaskColors.cardColor,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                for (final e in entries)
                  DropdownMenuItem<int?>(value: e.key, child: Text(e.value)),
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

/// Estimated-time filter min/max bounds. Each bound reuses
/// [LengthBucketPicker] so the user gets the same 5m / 15m / 30m / 1h /
/// 2h / 4h / 8h / 1d buckets as the Edit Task screen.
class _DurationBoundsRow extends StatelessWidget {
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  const _DurationBoundsRow({
    required this.minValue,
    required this.maxValue,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 32,
              child: Text(
                'Min',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LengthBucketPicker(
                minutes: minValue,
                onChanged: onMinChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(
              width: 32,
              child: Text(
                'Max',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LengthBucketPicker(
                minutes: maxValue,
                onChanged: onMaxChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Points filter min/max bounds. Each bound reuses [PointsPicker] so the
/// user gets the Fibonacci 1/2/3/5/8 scale plus an "Other" segment with
/// a numeric-input dialog — matching the Edit Task screen's points picker.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 32,
              child: Text(
                'Min',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PointsPicker(value: minValue, onChanged: onMinChanged),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(
              width: 32,
              child: Text(
                'Max',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PointsPicker(value: maxValue, onChanged: onMaxChanged),
            ),
          ],
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

/// Wraps a sheet field with a soft 2-px green ring when [changed] is true,
/// mirroring `_ChangedFieldHighlight` on the Edit Task screen. The padding
/// is preserved when not changed (transparent border occupies the same
/// space) so toggling doesn't shift layout.
class _ChangedFieldHighlight extends StatelessWidget {
  final bool changed;
  final BorderRadius borderRadius;
  final Widget child;

  /// Light green that reads against the brand-blue card surface.
  /// Matches `_ChangedFieldHighlight._accent` on the Edit Task screen.
  static const Color accent = Color(0xFF8FE5A1);
  static const Duration _animDuration = Duration(milliseconds: 180);
  static const double _borderWidth = 2;
  static const double _innerGap = 2;

  const _ChangedFieldHighlight({
    required this.changed,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(_innerGap),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: changed ? accent : Colors.transparent,
          width: _borderWidth,
        ),
      ),
      child: child,
    );
  }
}

/// Pill-shaped chip used in the multi-select modal. Selected = filled
/// with the cards-blue accent + a leading check; unselected = outlined
/// translucent. Replaces CheckboxListTile (TM-359 round-2 feedback).
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kSelectionAccent : Colors.transparent,
          border: Border.all(
            color: selected
                ? _kSelectionAccent
                : Colors.white.withValues(alpha: 0.30),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

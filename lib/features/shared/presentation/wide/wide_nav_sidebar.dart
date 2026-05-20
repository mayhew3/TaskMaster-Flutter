import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/areas/presentation/area_manage_screen.dart';
import '../../../../features/areas/providers/area_color_providers.dart';
import '../../../../features/areas/providers/area_providers.dart';
import '../../../../features/contexts/presentation/context_manage_screen.dart';
import '../../../../features/contexts/providers/context_providers.dart';
import '../../../../features/tasks/presentation/task_add_edit_screen.dart';
import '../../../../features/sprints/providers/sprint_providers.dart';
import '../../../../models/area.dart';
import '../../../../models/context.dart';
import '../../../../models/task_colors.dart';
import '../../../../models/task_list_view.dart';
import '../../../../models/top_nav_item.dart';
import '../../providers/sidebar_facet_counts.dart';
import '../../providers/task_list_view_providers.dart';
import '../widgets/context_icon.dart';
import 'sidebar_locked_row.dart';
import 'sidebar_profile_footer.dart';
import 'sidebar_row.dart';
import 'sidebar_section.dart';

const double _kSidebarWidth = 264.0;

/// Which axis a `_scopeToFilter` call targets.
enum _SidebarFacetAxis { areas, contexts }

/// Left navigation sidebar for the wide adaptive shell (TM-382, Story 1 of
/// Epic TM-188 — Direction A). Rendered only above the wide breakpoint; the
/// phone/compact bottom-nav path is untouched. Destinations share the same
/// [activeTabIndexProvider] selection as the bottom nav (driven via the
/// [onSelectDestination] callback). Areas / Contexts / search read & write
/// the *active destination's* `TaskListSurface` (tasks / family / sprint /
/// plan) — the same state the View Options sheet mutates — so they scope
/// whichever list is on screen.
class WideNavSidebar extends ConsumerWidget {
  const WideNavSidebar({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelectDestination,
  });

  final List<TopNavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelectDestination;

  /// Scope the active destination's list to [value] on [axis] (or clear
  /// the axis if [alreadyActive]). No tab switch — by design.
  void _scopeToFilter(
    WidgetRef ref,
    TaskListSurface surface,
    _SidebarFacetAxis axis,
    String value, {
    required bool alreadyActive,
  }) {
    final notifier = ref.read(taskListViewStateProvider(surface).notifier);
    final view = ref.read(taskListViewStateProvider(surface));
    notifier.setFilters(view.filters.rebuild((b) {
      final set = axis == _SidebarFacetAxis.areas ? b.areas : b.contexts;
      if (alreadyActive) {
        set.clear();
      } else {
        set.replace({value});
      }
    }));
  }

  /// The surface whose list the sidebar filters/searches, derived from the
  /// active destination (via [TopNavItem.destination], which is a stable
  /// enum — not the user-facing label, which would silently break under
  /// a rename / future localization). Plan maps to the active-sprint
  /// list (`sprint`) or the create/add list (`plan`), mirroring
  /// `PlanningHome`. Stats has no filterable list → null (search
  /// disabled; area/context rows inert).
  TaskListSurface? _activeFilterSurface(WidgetRef ref) {
    if (selectedIndex < 0 || selectedIndex >= navItems.length) return null;
    switch (navItems[selectedIndex].destination) {
      case NavDestination.tasks:
        return TaskListSurface.tasks;
      case NavDestination.family:
        return TaskListSurface.family;
      case NavDestination.plan:
        return ref.watch(activeSprintProvider) != null
            ? TaskListSurface.sprint
            : TaskListSurface.plan;
      case NavDestination.stats:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterSurface = _activeFilterSurface(ref);
    return Container(
      width: _kSidebarWidth,
      color: TaskColors.brandBlue,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const _SidebarBrandStrip(),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: _SidebarAddTaskButton(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: _SidebarSearchField(
                key: ValueKey(filterSurface),
                surface: filterSurface,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _destinationsSection(),
                    _areasSection(context, ref, filterSurface),
                    _contextsSection(context, ref, filterSurface),
                    const _ComingSoonSection(),
                  ],
                ),
              ),
            ),
            const SidebarProfileFooter(),
          ],
        ),
      ),
    );
  }

  Widget _destinationsSection() {
    return SidebarSection(
      title: 'Destinations',
      children: [
        for (final (i, item) in navItems.indexed)
          SidebarRow(
            icon: item.icon,
            label: item.label,
            selected: i == selectedIndex,
            onTap: () => onSelectDestination(i),
          ),
      ],
    );
  }

  Widget _areasSection(
      BuildContext context, WidgetRef ref, TaskListSurface? surface) {
    final areas = ref.watch(areasProvider).value ?? const <Area>[];
    final colors = ref.watch(areaColorsProvider);
    final facet = surface == null
        ? null
        : ref.watch(sidebarFacetCountsProvider(surface));
    final counts = facet?.value?.areas ?? const <String, int>{};
    // Hide zero-count rows only where the count is meaningful: a real
    // filterable surface (not plan/create-sprint, not Stats) with the
    // count actually computed. While loading / where counts don't apply,
    // show every row so the list never flashes empty.
    final hideZero = facet != null &&
        facet.hasValue &&
        surface != TaskListSurface.plan;
    final activeAreas = surface == null
        ? const <String>{}
        : ref
            .watch(taskListViewStateProvider(surface)
                .select((v) => v.filters.areas))
            .toSet();

    final rows = <Widget>[];
    for (final area in areas) {
      final key = area.name.trim().toLowerCase();
      final count = counts[key] ?? 0;
      final isActive = activeAreas.contains(area.name);
      if (hideZero && count == 0 && !isActive) continue;
      rows.add(SidebarRow(
        dotColor: colors[key] ?? TaskColors.primaryLight,
        label: area.name,
        trailingText: count > 0 ? '$count' : null,
        selected: surface != null && isActive,
        onTap: surface == null
            ? null
            : () => _scopeToFilter(
                ref, surface, _SidebarFacetAxis.areas, area.name,
                alreadyActive: isActive),
      ));
    }

    return SidebarSection(
      title: 'Areas',
      trailing: IconButton(
        icon: Icon(Icons.add, size: 17, color: TaskColors.textFaint),
        tooltip: 'Manage Areas',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AreaManageScreen()),
        ),
      ),
      children: rows,
    );
  }

  Widget _contextsSection(
      BuildContext context, WidgetRef ref, TaskListSurface? surface) {
    final contexts = ref.watch(contextsProvider).value ?? const <Context>[];
    final facet = surface == null
        ? null
        : ref.watch(sidebarFacetCountsProvider(surface));
    final counts = facet?.value?.contexts ?? const <String, int>{};
    final hideZero = facet != null &&
        facet.hasValue &&
        surface != TaskListSurface.plan;
    final activeContexts = surface == null
        ? const <String>{}
        : ref
            .watch(taskListViewStateProvider(surface)
                .select((v) => v.filters.contexts))
            .toSet();

    final rows = <Widget>[];
    for (final ctx in contexts) {
      final key = ctx.name.trim().toLowerCase();
      final count = counts[key] ?? 0;
      final isActive = activeContexts.contains(ctx.name);
      if (hideZero && count == 0 && !isActive) continue;
      rows.add(SidebarRow(
        leading: ContextIcon.hasIcon(ctx.iconName)
            ? ContextIcon(
                name: ctx.iconName, size: 18, color: TaskColors.textDim)
            : Icon(Icons.bookmark_outline,
                size: 18, color: TaskColors.textDim),
        label: ctx.name,
        trailingText: count > 0 ? '$count' : null,
        selected: surface != null && isActive,
        onTap: surface == null
            ? null
            : () => _scopeToFilter(
                ref, surface, _SidebarFacetAxis.contexts, ctx.name,
                alreadyActive: isActive),
      ));
    }

    return SidebarSection(
      title: 'Contexts',
      trailing: IconButton(
        icon: Icon(Icons.add, size: 17, color: TaskColors.textFaint),
        tooltip: 'Manage Contexts',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => const ContextManageScreen()),
        ),
      ),
      children: rows,
    );
  }
}

/// Brand strip: the app icon + the "TaskMaestro" wordmark. The icon is
/// the same `TaskMaestro_Logo.png` source `flutter_launcher_icons` builds
/// the installed launcher icon from, so the sidebar matches the device
/// icon. It is a full-bleed square, so a rounded clip is sufficient.
class _SidebarBrandStrip extends StatelessWidget {
  const _SidebarBrandStrip();

  @override
  Widget build(BuildContext context) {
    // 42px source rendered 1:1 — no runtime downscale, no aliasing.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/launcher/TaskMaestro_Logo_Small.png',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'TaskMaestro',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TaskColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "+ Add task" — the FAB relocated into the sidebar. Same destination as
/// the phone FABs: a pushed [TaskAddEditScreen] route (the docked-editor
/// behaviour is Story 3, TM-384).
class _SidebarAddTaskButton extends StatelessWidget {
  const _SidebarAddTaskButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TaskColors.brandMagentaMuted,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const TaskAddEditScreen(),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 17, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Add task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Context-aware search field. Reads/writes the *active destination's*
/// surface (Tasks / Family / the Plan destination's active-sprint or
/// create-sprint list) so it scopes whatever list is on screen. Disabled
/// on destinations with no text-searchable list (Stats). The enclosing
/// [WideNavSidebar] keys this widget by surface, so switching destination
/// rebuilds it seeded with the new surface's current query. The
/// `/`-to-focus shortcut + focus management are explicitly Story 4
/// (TM-385).
class _SidebarSearchField extends ConsumerStatefulWidget {
  const _SidebarSearchField({super.key, required this.surface});

  /// Surface whose `filters.search` this field drives; null = the active
  /// destination has no searchable list (the field renders disabled).
  final TaskListSurface? surface;

  @override
  ConsumerState<_SidebarSearchField> createState() =>
      _SidebarSearchFieldState();
}

class _SidebarSearchFieldState extends ConsumerState<_SidebarSearchField> {
  final TextEditingController _controller = TextEditingController();

  /// Debounce so each keystroke doesn't re-run the whole filter/group/sort
  /// pipeline (which made typing visibly stall). The text box stays
  /// instant; the list applies a beat after the user pauses.
  Timer? _debounce;
  static const _debounceDelay = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    final surface = widget.surface;
    if (surface != null) {
      _controller.text =
          ref.read(taskListViewStateProvider(surface)).filters.search;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.surface;
    if (surface == null) {
      return _buildField(enabled: false, onChanged: null);
    }
    // Sync controller when the surface's search is changed externally
    // (the screen's own app-bar search, or a tab-switch clear). Use
    // `value` rather than `text` so the cursor lands at the end —
    // otherwise a follow-up keystroke would prepend instead of append.
    ref.listen<String>(
      taskListViewStateProvider(surface).select((v) => v.filters.search),
      (_, next) {
        if (_controller.text != next) {
          _controller.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      },
    );
    return _buildField(
      enabled: true,
      onChanged: (v) {
        _debounce?.cancel();
        // `Timer.cancel()` in dispose guarantees no callback after
        // unmount, so a `mounted` check here would be dead-defensive.
        _debounce = Timer(_debounceDelay, () {
          ref
              .read(taskListViewStateProvider(surface).notifier)
              .setSearch(v);
        });
      },
    );
  }

  Widget _buildField({
    required bool enabled,
    required ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: _controller,
      enabled: enabled,
      onChanged: onChanged,
      style: TextStyle(color: TaskColors.textPrimary, fontSize: 13),
      cursorColor: TaskColors.textPrimary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        // Intentional literal: prototype's translucent-black search well
        // on brand-blue; no TaskColors token (sidebar tokens are Story 4).
        fillColor: Colors.black.withValues(alpha: 0.20),
        hintText: enabled ? 'Search tasks...' : 'Search unavailable here',
        hintStyle: TextStyle(color: TaskColors.textFaint, fontSize: 13),
        prefixIcon:
            Icon(Icons.search, size: 16, color: TaskColors.textFaint),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 34, minHeight: 34),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Locked "Coming Soon" placeholders. Static, non-interactive.
class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    return const SidebarSection(
      title: 'Coming Soon',
      children: [
        SidebarLockedRow(icon: Icons.flag_outlined, label: 'Yearly Goals'),
        SidebarLockedRow(
            icon: Icons.calendar_month_outlined, label: 'Monthly Plan'),
        SidebarLockedRow(
            icon: Icons.folder_outlined, label: 'Projects'),
      ],
    );
  }
}

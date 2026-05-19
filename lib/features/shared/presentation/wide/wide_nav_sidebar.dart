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
import '../../providers/task_list_view_providers.dart';
import '../widgets/context_icon.dart';
import 'sidebar_locked_row.dart';
import 'sidebar_profile_footer.dart';
import 'sidebar_row.dart';
import 'sidebar_section.dart';

const double _kSidebarWidth = 264.0;

/// Left navigation sidebar for the wide adaptive shell (TM-382, Story 1 of
/// Epic TM-188 — Direction A). Rendered only above the wide breakpoint; the
/// phone/compact bottom-nav path is untouched. Destinations share the same
/// [activeTabIndexProvider] selection as the bottom nav (driven via the
/// [onSelectDestination] callback). Areas reuse the existing Areas filter
/// (`taskListViewStateProvider(TaskListSurface.tasks).filters.areas`) — the
/// same state the View Options sheet mutates — so the two stay consistent.
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

  void _scopeToArea(WidgetRef ref, TaskListSurface surface, String areaName,
      bool alreadyActive) {
    final notifier = ref.read(taskListViewStateProvider(surface).notifier);
    final view = ref.read(taskListViewStateProvider(surface));
    // Scope the active destination's list in place — no tab switch.
    if (alreadyActive) {
      notifier.setFilters(view.filters.rebuild((b) => b..areas.clear()));
      return;
    }
    notifier.setFilters(
        view.filters.rebuild((b) => b..areas.replace({areaName})));
  }

  void _scopeToContext(WidgetRef ref, TaskListSurface surface,
      String contextName, bool alreadyActive) {
    final notifier = ref.read(taskListViewStateProvider(surface).notifier);
    final view = ref.read(taskListViewStateProvider(surface));
    // Scope the active destination's list in place — no tab switch.
    if (alreadyActive) {
      notifier.setFilters(view.filters.rebuild((b) => b..contexts.clear()));
      return;
    }
    notifier.setFilters(
        view.filters.rebuild((b) => b..contexts.replace({contextName})));
  }

  /// The surface whose list the sidebar filters/searches, derived from the
  /// active destination so Areas / Contexts / search all scope whatever
  /// list is on screen (no forced jump to Tasks). Plan maps to the
  /// active-sprint list (`sprint`) or the create/add list (`plan`),
  /// mirroring `PlanningHome`. Stats (and any unknown destination) has no
  /// filterable list → null (search disabled; area/context rows inert).
  TaskListSurface? _activeFilterSurface(WidgetRef ref) {
    if (selectedIndex < 0 || selectedIndex >= navItems.length) return null;
    switch (navItems[selectedIndex].label) {
      case 'Tasks':
        return TaskListSurface.tasks;
      case 'Family':
        return TaskListSurface.family;
      case 'Plan':
        return ref.watch(activeSprintProvider) != null
            ? TaskListSurface.sprint
            : TaskListSurface.plan;
      default:
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
                    _areasSection(context, ref),
                    _contextsSection(context, ref),
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
        for (var i = 0; i < navItems.length; i++)
          SidebarRow(
            icon: navItems[i].icon,
            label: navItems[i].label,
            selected: i == selectedIndex,
            onTap: () => onSelectDestination(i),
          ),
      ],
    );
  }

  Widget _areasSection(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasProvider).value ?? const <Area>[];
    final colors = ref.watch(areaColorsProvider);
    final counts =
        ref.watch(areaTaskCountsProvider).value ?? const <String, int>{};
    final TaskListSurface? surface = _activeFilterSurface(ref);
    final Set<String> activeAreas = surface == null
        ? const {}
        : ref
            .watch(taskListViewStateProvider(surface)
                .select((v) => v.filters.areas))
            .toSet();

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
      children: [
        for (final area in areas)
          SidebarRow(
            dotColor: colors[area.name.trim().toLowerCase()] ??
                TaskColors.primaryLight,
            label: area.name,
            trailingText: (counts[area.name.toLowerCase()] ?? 0) > 0
                ? '${counts[area.name.toLowerCase()]}'
                : null,
            selected: surface != null && activeAreas.contains(area.name),
            onTap: surface == null
                ? null
                : () => _scopeToArea(ref, surface, area.name,
                    activeAreas.contains(area.name)),
          ),
      ],
    );
  }

  Widget _contextsSection(BuildContext context, WidgetRef ref) {
    final contexts = ref.watch(contextsProvider).value ?? const <Context>[];
    final counts =
        ref.watch(contextTaskCountsProvider).value ?? const <String, int>{};
    final TaskListSurface? surface = _activeFilterSurface(ref);
    final Set<String> activeContexts = surface == null
        ? const {}
        : ref
            .watch(taskListViewStateProvider(surface)
                .select((v) => v.filters.contexts))
            .toSet();

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
      children: [
        for (final ctx in contexts)
          SidebarRow(
            leading: ContextIcon.hasIcon(ctx.iconName)
                ? ContextIcon(
                    name: ctx.iconName, size: 18, color: TaskColors.textDim)
                : Icon(Icons.bookmark_outline,
                    size: 18, color: TaskColors.textDim),
            label: ctx.name,
            trailingText: (counts[ctx.name.toLowerCase()] ?? 0) > 0
                ? '${counts[ctx.name.toLowerCase()]}'
                : null,
            selected:
                surface != null && activeContexts.contains(ctx.name),
            onTap: surface == null
                ? null
                : () => _scopeToContext(ref, surface, ctx.name,
                    activeContexts.contains(ctx.name)),
          ),
      ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/launcher/TaskMaestro_Logo.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TaskMaestro',
            style: TextStyle(
              color: TaskColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
    // Reflect external changes for this surface (the screen's own app-bar
    // search, or a tab-switch clear) into the box.
    ref.listen<String>(
      taskListViewStateProvider(surface).select((v) => v.filters.search),
      (_, next) {
        if (_controller.text != next) _controller.text = next;
      },
    );
    return _buildField(
      enabled: true,
      onChanged: (v) {
        _debounce?.cancel();
        _debounce = Timer(_debounceDelay, () {
          if (!mounted) return;
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

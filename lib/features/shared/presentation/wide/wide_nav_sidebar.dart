import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/areas/presentation/area_manage_screen.dart';
import '../../../../features/areas/providers/area_color_providers.dart';
import '../../../../features/areas/providers/area_providers.dart';
import '../../../../features/tasks/presentation/task_add_edit_screen.dart';
import '../../../../features/tasks/providers/task_filter_providers.dart';
import '../../../../models/area.dart';
import '../../../../models/task_colors.dart';
import '../../../../models/task_list_view.dart';
import '../../../../models/top_nav_item.dart';
import '../../providers/task_list_view_providers.dart';
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

  void _scopeToArea(WidgetRef ref, String areaName, bool alreadyActive) {
    final notifier =
        ref.read(taskListViewStateProvider(TaskListSurface.tasks).notifier);
    final view = ref.read(taskListViewStateProvider(TaskListSurface.tasks));
    if (alreadyActive) {
      // Tapping the active scope clears it back to "all areas".
      notifier.setFilters(view.filters.rebuild((b) => b..areas.clear()));
      return;
    }
    notifier
        .setFilters(view.filters.rebuild((b) => b..areas.replace({areaName})));
    final tasksIndex = navItems.indexWhere((n) => n.label == 'Tasks');
    if (tasksIndex >= 0 && tasksIndex != selectedIndex) {
      onSelectDestination(tasksIndex);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: _SidebarSearchField(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _destinationsSection(),
                    _areasSection(context, ref),
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
    final activeAreas =
        ref.watch(taskListViewStateProvider(TaskListSurface.tasks)
            .select((v) => v.filters.areas));

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
            selected: activeAreas.contains(area.name),
            onTap: () => _scopeToArea(
                ref, area.name, activeAreas.contains(area.name)),
          ),
      ],
    );
  }
}

/// Brand strip: a small drawn mark + the "TaskMaestro" wordmark. Drawn
/// (not an asset) so Story 1 has no asset dependency.
class _SidebarBrandStrip extends StatelessWidget {
  const _SidebarBrandStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  TaskColors.brandMagenta,
                  TaskColors.brandMagentaMuted,
                ],
              ),
            ),
            child: const Icon(Icons.check_rounded,
                size: 18, color: Colors.white),
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

/// Functional search field bound to the existing [searchQueryProvider]
/// (the source the Tasks list already filters on). The `/`-to-focus
/// shortcut + focus management are explicitly Story 4 (TM-385).
class _SidebarSearchField extends ConsumerStatefulWidget {
  const _SidebarSearchField();

  @override
  ConsumerState<_SidebarSearchField> createState() =>
      _SidebarSearchFieldState();
}

class _SidebarSearchFieldState extends ConsumerState<_SidebarSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reflect external changes (e.g. setTab clears the query) into the box.
    ref.listen<String>(searchQueryProvider, (_, next) {
      if (_controller.text != next) _controller.text = next;
    });
    return TextField(
      controller: _controller,
      onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
      style: TextStyle(color: TaskColors.textPrimary, fontSize: 13),
      cursorColor: TaskColors.textPrimary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        // Intentional literal: prototype's translucent-black search well
        // on brand-blue; no TaskColors token (sidebar tokens are Story 4).
        fillColor: Colors.black.withValues(alpha: 0.20),
        hintText: 'Search tasks...',
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

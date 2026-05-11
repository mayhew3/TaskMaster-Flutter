import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/services/task_completion_service.dart';
import '../../../models/check_state.dart';
import '../../../models/task_item.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/editable_task_item.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/snooze_dialog.dart';
import '../../shared/presentation/task_action_error_helper.dart';
import '../../shared/presentation/widgets/header_list_item.dart';
import '../../tasks/presentation/task_add_edit_screen.dart';
import '../providers/family_task_filter_providers.dart';
import 'family_manage_screen.dart';

/// Top-level tab content for "Family" — visible only when the user is in a
/// family (the bottom-nav rebuilds when familyDocId flips). Renders the
/// union of all family members' incomplete tasks, plus a small action row
/// for management (Members / Invite / Leave).
class FamilyTabScreen extends ConsumerStatefulWidget {
  const FamilyTabScreen({super.key});

  @override
  ConsumerState<FamilyTabScreen> createState() => _FamilyTabScreenState();
}

class _FamilyTabScreenState extends ConsumerState<FamilyTabScreen> {
  final _searchController = TextEditingController();
  bool _searchBarVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchBarVisible = !_searchBarVisible;
      if (!_searchBarVisible) {
        _searchController.clear();
        ref.read(familySearchQueryProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(familyGroupedTasksProvider);
    // Sync the search controller's text when the provider is cleared
    // externally (e.g. tab navigation). Done via `ref.listen` rather
    // than during build so the `_searchController.clear()` mutation
    // happens outside the build phase — mutating a TextEditingController
    // mid-build can trigger an `EditableText` listener rebuild that
    // racing with the in-progress build risks a "markNeedsBuild during
    // build" exception. Intentionally does NOT close the search bar
    // itself — losing the open input on an external clear would be
    // surprising and removes the user's affordance to type again.
    // The bar stays visible until the user dismisses it.
    ref.listen<String>(familySearchQueryProvider, (prev, next) {
      if (next.isEmpty &&
          _searchBarVisible &&
          _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    final tiles = <Widget>[];
    for (final group in groups) {
      tiles.add(HeadingItem(group.name));
      for (final task in group.tasks) {
        tiles.add(_FamilyTaskTile(task: task));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: _searchBarVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search family tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) =>
                    ref.read(familySearchQueryProvider.notifier).set(value),
              )
            : const Text('Family'),
        actions: [
          const ConnectionStatusIndicator(),
          IconButton(
            icon: Icon(_searchBarVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          const _FamilyFilterPopupMenu(),
          IconButton(
            tooltip: 'Manage family',
            icon: const Icon(Icons.group),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FamilyManageScreen()),
            ),
          ),
          const RefreshButton(),
        ],
      ),
      body: tiles.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No active tasks in your family yet. Add one with the + button below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 7.0,
                bottom: kFloatingActionButtonMargin + 54,
              ),
              itemCount: tiles.length,
              itemBuilder: (_, i) => tiles[i],
            ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  const TaskAddEditScreen(defaultFamilyShared: true)),
        ),
      ),
    );
  }
}

class _FamilyTaskTile extends ConsumerWidget {
  const _FamilyTaskTile({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPersonDocId = ref.watch(personDocIdProvider);
    final isMine = task.personDocId == myPersonDocId;
    return EditableTaskItemWidget(
      taskItem: task,
      highlightSprint: false,
      // Hide Edit on tasks the current user doesn't own — viewing a
      // teammate's task should be read-only from this tab.
      onEdit: isMine
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskAddEditScreen(taskItemId: task.docId),
                ),
              )
          : null,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showDialog<void>(
          context: context,
          builder: (context) => SnoozeDialog(taskItem: task),
        );
      },
      onTaskCompleteToggle: (checkState) {
        if (checkState == CheckState.pending) return null;
        if (checkState == CheckState.skipped) {
          ref.read(skipTaskProvider.notifier).unskip(task).catchError(
              (Object e, StackTrace st) =>
                  showTaskActionError(context, e, st));
          return null;
        }
        ref
            .read(completeTaskProvider.notifier)
            .call(task, complete: checkState == CheckState.inactive)
            .catchError((Object e, StackTrace st) =>
                showTaskActionError(context, e, st));
        return null;
      },
      // Swipe-to-delete is only allowed for tasks the current user owns; the
      // Family tab's MVP scope doesn't include deleting another member's
      // task. Surface a toast on attempt so the user understands why the
      // gesture bounced back instead of looking like an unresponsive UI.
      confirmDismiss: isMine
          ? (direction) async {
              if (direction == DismissDirection.endToStart) {
                try {
                  await ref.read(deleteTaskProvider.notifier).call(task);
                  return true;
                } catch (_) {
                  return false;
                }
              }
              return false;
            }
          : (_) async {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'You can only delete tasks you created.'),
                  ),
                );
              }
              return false;
            },
    );
  }
}

/// Filter popup menu mirroring the Tasks tab's `_FilterPopupMenu` — shows
/// explicit text options instead of icons so it's clear what's being toggled.
class _FamilyFilterPopupMenu extends ConsumerWidget {
  const _FamilyFilterPopupMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCompleted = ref.watch(familyShowCompletedProvider);
    final showScheduled = ref.watch(familyShowScheduledProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) {
        if (value == 'completed') {
          ref.read(familyShowCompletedProvider.notifier).toggle();
        } else if (value == 'scheduled') {
          ref.read(familyShowScheduledProvider.notifier).toggle();
        }
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem<String>(
          checked: showScheduled,
          value: 'scheduled',
          child: const Text('Show Scheduled'),
        ),
        CheckedPopupMenuItem<String>(
          checked: showCompleted,
          value: 'completed',
          child: const Text('Show Finished'),
        ),
      ],
    );
  }
}

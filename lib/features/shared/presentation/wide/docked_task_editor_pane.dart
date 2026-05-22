import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../helpers/area_color_helper.dart';
import '../../../../models/task_colors.dart';
import '../../../../models/task_item.dart';
import '../../../tasks/presentation/task_editor_body.dart';
import '../../../tasks/providers/expanded_task_provider.dart';
import '../../providers/selected_task_providers.dart';

/// The wide-layout docked editor (TM-384 Story 3 of Epic TM-188).
///
/// Renders in the right pane for two distinct states:
///   - [RightPaneMode.editor] + a task selected → **edit-mode** for
///     that task. Selection is driven by row taps; the
///     `RightPaneSelectionSync` listener flips the mode.
///   - [RightPaneMode.addingNewTask] → **add-mode** (no selection).
///     Set explicitly by the sidebar "+ Add task" button on the wide
///     two-pane layout. The mode value is distinct from `.editor` so
///     `RightPaneSelectionSync`'s null-selection downgrade doesn't
///     clobber it (see that widget's docs).
///
/// Hosts the shared [TaskEditorBody] — the same editor the full-screen
/// `TaskAddEditScreen` route uses — wrapped in:
///
///   - the prototype's header strip (area label + Delete + Close; **no**
///     back chevron — the docked editor isn't a route);
///   - a **nested [Navigator]** so the editor's pickers
///     (`showModalBottomSheet` / `showDialog` / `showTimePicker`, all run
///     with `useRootNavigator: false`) render scoped to the 380dp pane
///     instead of spanning the whole window;
///   - a [MediaQuery] override clamping `size` to the pane's box so the
///     date popup's height math stays pane-relative.
///
/// When nothing is selected and no add-task is in flight (i.e. the
/// "idle" state with [RightPaneMode.empty]) the right pane shows
/// [RightPaneEmptyState], not this widget.
///
/// The body is keyed by `(docId or '__add__', generation)`; a selection
/// change OR an edit-save (which bumps the generation) gives a fresh
/// editor that re-initialises — clearing the "changed-field" highlights
/// once the edits are persisted. On an add-mode save, the pane sets
/// `selectedTaskProvider` to the new docId, which flips mode `.editor`
/// via the listener and re-keys the body from `'__add__'` to the
/// freshly-created task's docId.
class DockedTaskEditorPane extends ConsumerStatefulWidget {
  const DockedTaskEditorPane({super.key});

  @override
  ConsumerState<DockedTaskEditorPane> createState() =>
      _DockedTaskEditorPaneState();
}

class _DockedTaskEditorPaneState extends ConsumerState<DockedTaskEditorPane> {
  /// Bumped on an edit-save so the body re-keys and re-initialises from
  /// the now-persisted task (clears the green change-highlights).
  int _generation = 0;

  /// Captured at edit-save success and passed to the re-keyed body as
  /// `initialTaskOverride`. Without this, the new body would re-fetch
  /// from `taskProvider(docId)` and (intermittently — repro'd at ~50%)
  /// read STALE data before the Drift stream emit had propagated
  /// through Riverpod's family-invalidation chain → blueprint
  /// initialised from the pre-edit task → all the user's edits
  /// appeared to revert in the pane (while the list correctly showed
  /// the persisted values from a separate read).
  TaskItem? _pendingSavedTask;

  void _handleClose() {
    // Close (X) / post-delete: tear down the editor entirely. Drop the
    // selection (aura clears via the listener; pane goes back to its
    // empty state), AND collapse the inline accordion so the row's
    // expanded body in the list collapses in lockstep with the editor
    // closing. On wide, a row tap opens BOTH the accordion and the
    // editor (per D7) — explicitly closing the editor must close the
    // accordion too, otherwise the row stays expanded in the list
    // with no editor to match it.
    ref.read(selectedTaskProvider.notifier).clear();
    ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.empty);
    ref.read(expandedTaskProvider.notifier).collapse();
  }

  void _handleCancel() {
    if (ref.read(selectedTaskProvider) == null) {
      // Add-mode: there's no persisted task to revert to. Cancel
      // discards the in-progress new task and closes the pane.
      _handleClose();
      return;
    }
    // Edit-mode Cancel: discard unsaved edits but keep the inspector
    // open on the same task — symmetric with Save (D5), which also
    // stays open. Bumping the generation re-keys the body; the fresh
    // `State` re-initialises from `taskProvider(docId)`, which holds
    // the un-edited persisted task, so the blueprint reverts and the
    // green change-highlights clear. The user closes the inspector
    // explicitly via the header's Close (X) icon (or by selecting a
    // different row, re-tapping to deselect, switching tabs, etc.).
    setState(() => _generation++);
  }

  void _handleSaved(String savedDocId, TaskItem? savedTask) {
    // D5: keep the editor open on the saved task. Bump the generation
    // so the body re-keys (clears change-highlights, re-initialises
    // from saved state) AND stash the persisted snapshot so the new
    // body initialises from it directly — bypassing the deferred
    // `taskProvider(docId)` read that races with stream propagation.
    if (kDebugMode) {
      debugPrint(
        '[DockedTaskEditorPane] _handleSaved docId=$savedDocId '
        'gen ${_generation} → ${_generation + 1} '
        'savedTask=${savedTask?.docId} priority=${savedTask?.priority}',
      );
    }
    final wasAddMode = ref.read(selectedTaskProvider) == null;
    setState(() {
      _pendingSavedTask = savedTask;
      _generation++;
    });
    if (wasAddMode && savedDocId.isNotEmpty) {
      // Transition add-mode → edit-mode for the freshly-created task.
      // Setting selection triggers `RightPaneSelectionSync` to flip
      // mode `.addingNewTask` → `.editor`; the next build sees the
      // new selection and re-keys the body from `'__add__'` to the
      // saved docId. `initialTaskOverride = _pendingSavedTask` (set
      // above) seeds the fresh body without a `taskProvider` read.
      ref.read(selectedTaskProvider.notifier).select(savedDocId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDocId = ref.watch(selectedTaskProvider);
    final mode = ref.watch(rightPaneProvider);

    // The pane renders two distinct states:
    //  - edit-mode: `.editor` + a non-null selection.
    //  - add-mode: `.addingNewTask` (selection should be null; the
    //    sidebar Add Task button clears selection before setting
    //    this mode).
    // Anything else (e.g. `.editor` + a brief null-selection race
    // window) falls through to the defensive `SizedBox.shrink`.
    final String? taskItemIdForBody;
    final String keyPrefix;
    final TaskItem? overrideTask;
    if (mode == RightPaneMode.editor && selectedDocId != null) {
      taskItemIdForBody = selectedDocId;
      keyPrefix = selectedDocId;
      overrideTask = _pendingSavedTask?.docId == selectedDocId
          ? _pendingSavedTask
          : null;
    } else if (mode == RightPaneMode.addingNewTask) {
      taskItemIdForBody = null;
      keyPrefix = '__add__';
      overrideTask = null;
    } else {
      return const SizedBox.shrink();
    }

    return Material(
      color: TaskColors.cardColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Clamp MediaQuery to the pane's box so descendant pickers that
          // size themselves off `MediaQuery.size` (the date popup's
          // month/year sub-sheet) stay within the 380dp pane.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            child: Navigator(
              onDidRemovePage: (page) {},
              pages: [
                MaterialPage<void>(
                  // Constant key: the route never swaps. Re-keying happens
                  // on the TaskEditorBody child instead, so a selection
                  // change refreshes the editor in place with no route
                  // transition.
                  key: const ValueKey('docked-editor-route'),
                  child: TaskEditorBody(
                    key: ValueKey('$keyPrefix-$_generation'),
                    taskItemId: taskItemIdForBody,
                    initialTaskOverride: overrideTask,
                    useRootNavigatorForPickers: false,
                    onClose: _handleClose,
                    onCancel: _handleCancel,
                    onDeleted: _handleClose,
                    onSaveSucceeded: _handleSaved,
                    headerBuilder: (ctx, info) =>
                        _DockedEditorHeader(info: info),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The docked editor's header strip — area label + Delete + Close. No back
/// chevron (the docked editor isn't a navigation route). Ported from
/// `wide-editor.jsx`'s editor header.
class _DockedEditorHeader extends StatelessWidget {
  final TaskEditorHeaderInfo info;

  const _DockedEditorHeader({required this.info});

  @override
  Widget build(BuildContext context) {
    final area = info.taskItem?.area;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.isEditMode ? 'TASK DETAILS' : 'NEW TASK',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (area != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AreaColorHelper.colorForArea(area),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        area ?? 'No area',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: area != null ? 0.78 : 0.45,
                          ),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: area != null
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (info.onDelete != null) ...[
            _EditorIconButton(
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFFFB4B4).withValues(alpha: 0.85),
              tooltip: 'Delete task',
              onTap: info.onDelete!,
            ),
            const SizedBox(width: 8),
          ],
          _EditorIconButton(
            icon: Icons.close,
            iconColor: Colors.white.withValues(alpha: 0.70),
            tooltip: 'Close editor',
            onTap: info.onClose,
          ),
        ],
      ),
    );
  }
}

/// 32×32 icon button used in the docked editor header — faint surface +
/// hairline border, per the prototype's `EditorIconBtn`.
class _EditorIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback onTap;

  const _EditorIconButton({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
        ),
      ),
    );
  }
}

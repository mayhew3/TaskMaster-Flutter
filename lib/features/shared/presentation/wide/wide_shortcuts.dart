import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/services/task_completion_service.dart';
import '../../../../features/tasks/providers/expanded_task_provider.dart';
import '../../../../features/tasks/providers/task_filter_providers.dart';
import '../../../../models/task_list_view.dart';
import '../../../family/providers/family_task_filter_providers.dart';
import '../../providers/right_pane_width_provider.dart';
import '../../providers/selected_task_providers.dart';

part 'wide_shortcuts.g.dart';

// ── FocusNode for sidebar search ─────────────────────────────────────────

/// Shared FocusNode owned by the wide shell so the keyboard `/`
/// shortcut can call `requestFocus()` on the sidebar search field.
/// The sidebar widget reads this provider and passes the same node
/// to its `TextField.focusNode`.
@Riverpod(keepAlive: true)
FocusNode sidebarSearchFocusNode(Ref ref) {
  final node = FocusNode(debugLabel: 'sidebar-search');
  ref.onDispose(node.dispose);
  return node;
}

// ── WideShortcuts ────────────────────────────────────────────────────────

/// Wraps the wide-shell `Row` in `Shortcuts` + `Actions` so keyboard
/// bindings drive the same providers a mouse user would (TM-385).
///
/// Mounted only on the wide path (see `_buildWideShell`); phone keeps
/// its existing un-shortcut'd behavior.
///
/// Bindings:
///   - `j` / `k` → move selection down / up in the active list (vim
///     convention: j=down=next row, k=up=prev row — matches Gmail /
///     GitHub / Trello / most keyboard-driven list apps)
///   - `e` → open editor for selection
///   - `c` → toggle complete on selection
///   - `/` → focus sidebar search
///   - `n` → add new task (Family-aware default). Bare `n` (no
///     modifier) instead of Cmd/Ctrl+N because the browser intercepts
///     Cmd/Ctrl+N for "new window/tab" before Flutter sees it on the
///     web target.
///
/// TextField focus takes precedence: each Action's first check is
/// `_isTextFieldFocused()` — typing into a search/edit field never
/// fires these shortcuts even though Flutter's bare Shortcuts widget
/// would otherwise let raw character keys through.
///
/// Routes raw key events directly through `HardwareKeyboard.instance.
/// addHandler` rather than wiring `Shortcuts` + `Actions` into the
/// focus tree. The Shortcuts widget only dispatches when the
/// FocusManager's primaryFocus is a descendant of the Shortcuts
/// widget; users routinely move focus out (typing in the sidebar
/// search and then clicking somewhere unfocusable would collapse
/// focus to the root scope, silencing every shortcut until the
/// user explicitly clicked back into something focusable).
///
/// Hardware-keyboard dispatch sidesteps the focus tree entirely.
/// The per-key TextField-focus guard via [_isTextFieldFocused]
/// keeps text entry safe — when an editable text field has focus,
/// the handler returns false ("not handled") and the keystroke
/// propagates normally to the field.
class WideShortcuts extends ConsumerStatefulWidget {
  final Widget child;
  const WideShortcuts({super.key, required this.child});

  @override
  ConsumerState<WideShortcuts> createState() => _WideShortcutsState();
}

class _WideShortcutsState extends ConsumerState<WideShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Only act on key-down (ignore up + repeat to keep semantics
    // crisp; users expect one keystroke = one action).
    if (event is! KeyDownEvent) return false;
    // TextField focus always wins: typing into a search/edit field
    // never fires a shortcut, regardless of what key it is.
    if (_isTextFieldFocused()) return false;
    // Modifier combos belong to the OS / browser (Cmd+N = new window,
    // Ctrl+E = address bar focus on Linux Firefox, etc.). Letting bare
    // shortcuts also fire on Cmd+J / Ctrl+J / Alt+E would silently
    // hijack platform bindings the user expects to do something else,
    // and Shift+N would treat capital `N` as a "new task" trigger
    // instead of a typed character if a non-field surface ever
    // accepted text in the future. Ignore any non-bare keypress.
    final kb = HardwareKeyboard.instance;
    if (kb.isControlPressed ||
        kb.isMetaPressed ||
        kb.isAltPressed ||
        kb.isShiftPressed) {
      return false;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyJ) {
      _moveSelection(1);
      return true;
    }
    if (key == LogicalKeyboardKey.keyK) {
      _moveSelection(-1);
      return true;
    }
    if (key == LogicalKeyboardKey.keyE) {
      _editSelected();
      return true;
    }
    if (key == LogicalKeyboardKey.keyC) {
      _completeSelected();
      return true;
    }
    if (key == LogicalKeyboardKey.slash) {
      _focusSearch();
      return true;
    }
    if (key == LogicalKeyboardKey.keyN) {
      _addNewTask();
      return true;
    }
    return false;
  }

  void _moveSelection(int direction) {
    final docIds = _flatDocIdsForActiveSurface(ref);
    if (docIds.isEmpty) return;
    final current = ref.read(selectedTaskProvider);
    final selectionNotifier = ref.read(selectedTaskProvider.notifier);
    final expandedNotifier = ref.read(expandedTaskProvider.notifier);

    String? nextDocId;
    if (current == null) {
      nextDocId = direction > 0 ? docIds.first : docIds.last;
    } else {
      final idx = docIds.indexOf(current);
      if (idx == -1) {
        nextDocId = docIds.first;
      } else {
        final clamped = (idx + direction).clamp(0, docIds.length - 1);
        if (clamped == idx) return;
        nextDocId = docIds[clamped];
      }
    }
    selectionNotifier.select(nextDocId);
    // Mirror the wide-tap contract: selection + accordion fire in
    // lockstep so j/k feels like "move the focused card." `toggle`
    // with a non-matching docId sets state to that docId (only
    // collapses when state already equals docId, which can't happen
    // mid-navigation since we always move to a different row).
    expandedNotifier.toggle(nextDocId);
  }

  void _editSelected() {
    if (ref.read(selectedTaskProvider) == null) return;
    ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.editor);
  }

  void _completeSelected() {
    final docId = ref.read(selectedTaskProvider);
    if (docId == null) return;
    final surface = ref.read(activeSurfaceProvider);
    if (surface == null) return;
    final task = switch (surface) {
      TaskListSurface.tasks => ref
          .read(groupedTasksProvider)
          .value
          ?.expand((g) => g.tasks)
          .where((t) => t.docId == docId)
          .firstOrNull,
      TaskListSurface.family => ref
          .read(familyGroupedTasksProvider)
          .expand((g) => g.tasks)
          .where((t) => t.docId == docId)
          .firstOrNull,
      _ => null,
    };
    if (task == null) return;
    // Ownership guard: don't complete a teammate's task. Mirrors the
    // `RightPaneSelectionSync` editor guard. Without this, on the
    // Family surface a selected teammate-owned task + `c` would
    // optimistically write completion locally and queue a Firestore
    // write that the rules should reject — surfacing as a
    // confusing-looking visual flicker. Bail unless the task belongs
    // to the current person (unknown ownership treated as editable
    // for the same hot-path reason as the editor guard).
    final myPersonDocId = ref.read(personDocIdProvider);
    if (myPersonDocId != null && task.personDocId != myPersonDocId) {
      return;
    }
    final wasComplete = task.completionDate != null;
    ref.read(completeTaskProvider.notifier).call(task, complete: !wasComplete);
  }

  void _focusSearch() {
    ref.read(sidebarSearchFocusNodeProvider).requestFocus();
  }

  void _addNewTask() {
    ref.read(selectedTaskProvider.notifier).clear();
    ref.read(expandedTaskProvider.notifier).collapse();
    ref.read(rightPaneProvider.notifier).setMode(RightPaneMode.addingNewTask);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Actions ──────────────────────────────────────────────────────────────

/// True when an editable text widget (TextField / TextFormField /
/// any descendant of `EditableText`) currently has focus.
///
/// `HardwareKeyboard.instance.addHandler` dispatch is focus-tree
/// independent — when a TextField is focused, ordinary character keys
/// reach both `EditableText` (which inserts them into the field) AND
/// our handler (which would otherwise fire `n`/`/`/`e` shortcuts).
/// Returning `true` here short-circuits the handler before any shortcut
/// fires, leaving the keystroke for the field. Without this guard,
/// typing `e` into a search field would ALSO open the docked editor.
///
/// Every bare-key shortcut consults this (j/k/e/c/slash/n). The TM-385
/// implementation uses bare `n` (not Cmd/Ctrl+N) because the browser
/// intercepts the modifier combo on web; the separate
/// `HardwareKeyboard.isControlPressed / isMetaPressed / isAltPressed /
/// isShiftPressed` guard in `_handleKeyEvent` keeps modifier presses
/// (Cmd+J, Shift+N, …) from accidentally triggering bare-key actions.
bool _isTextFieldFocused() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus == null) return false;
  final ctx = focus.context;
  if (ctx == null) return false;
  // EditableText (the inner widget of TextField/TextFormField) wraps
  // its content in its own Focus, so primaryFocus.context.widget is
  // typically the Focus widget, not EditableText itself — walk up
  // looking for the EditableText ancestor.
  return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
}

/// Flat ordered list of docIds for the active surface — what j/k
/// navigates through. Returns empty when the surface has no list
/// (Stats), is loading, or has no tasks.
List<String> _flatDocIdsForActiveSurface(WidgetRef ref) {
  final surface = ref.read(activeSurfaceProvider);
  if (surface == null) return const [];
  switch (surface) {
    case TaskListSurface.tasks:
      final groups = ref.read(groupedTasksProvider).value;
      if (groups == null) return const [];
      return [for (final g in groups) for (final t in g.tasks) t.docId];
    case TaskListSurface.family:
      final groups = ref.read(familyGroupedTasksProvider);
      return [for (final g in groups) for (final t in g.tasks) t.docId];
    case TaskListSurface.sprint:
    case TaskListSurface.plan:
      // Sprint/Plan navigation via keyboard would need their own
      // grouped providers and an active-sprint dependency; defer
      // those bindings until the Plan/Sprint side panels surface
      // their own keyboard ergonomics. Empty list = no-op shortcut.
      return const [];
  }
}


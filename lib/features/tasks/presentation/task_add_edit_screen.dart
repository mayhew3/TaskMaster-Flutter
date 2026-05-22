import 'package:flutter/material.dart';
import 'package:taskmaestro/models/task_colors.dart';

import 'task_editor_body.dart';

/// Full-screen Add/Edit Task route (phone / compact layout).
///
/// Since TM-384 this is a thin chrome wrapper: the gradient `Scaffold` and
/// the back-chevron top nav, around the shared [TaskEditorBody] which owns
/// all editor state + save/cancel/delete logic. The wide layout's docked
/// editor (`DockedTaskEditorPane`) wraps the same [TaskEditorBody] with
/// different chrome. All close paths here pop the route.
class TaskAddEditScreen extends StatelessWidget {
  final String? taskItemId;

  /// When `true` and adding a new task (no [taskItemId]), pre-stamp the
  /// blueprint with the current user's `familyDocId` so the task becomes
  /// family-shared. Set by the Family-tab FAB; the Tasks-tab FAB leaves
  /// this `false` so additions stay personal even while in a family.
  final bool defaultFamilyShared;

  const TaskAddEditScreen({
    super.key,
    this.taskItemId,
    this.defaultFamilyShared = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaskColors.cardColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, -0.34), // ~280px on a typical phone height
            colors: [TaskColors.editorBgTop, TaskColors.cardColor],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: TaskEditorBody(
            taskItemId: taskItemId,
            defaultFamilyShared: defaultFamilyShared,
            // Full-screen route: pickers behave exactly as before TM-384.
            useRootNavigatorForPickers: true,
            // Phone has no inspector concept — every exit pops the route.
            onClose: () => Navigator.of(context).pop(),
            onCancel: () => Navigator.of(context).pop(),
            onDeleted: () => Navigator.of(context).pop(),
            // Full-screen route ignores the saved-task passthrough —
            // the route closes on save; the user-visible behavior is
            // unchanged.
            onSaveSucceeded: (_, __) => Navigator.of(context).pop(),
            headerBuilder: (ctx, info) => _TopNav(
              title: info.title,
              onBack: info.onClose,
              onDelete: info.onDelete,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  const _TopNav({
    required this.title,
    required this.onBack,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 22,
                color: const Color(0xFFFFB4B4).withValues(alpha: 0.85),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../models/context.dart';
import '../../shared/presentation/widgets/context_icon.dart';
import '../providers/context_providers.dart';
import '../services/context_service.dart';

/// "Manage Contexts" settings screen (TM-181).
///
/// Lets the user add, rename, delete, and drag-to-reorder contexts. Tasks
/// tagged with a deleted context keep their string value — the value just no
/// longer appears in the picker. Mirror of [AreaManageScreen] (TM-345).
class ContextManageScreen extends ConsumerWidget {
  const ContextManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContexts = ref.watch(contextsWithDefaultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Contexts')),
      body: asyncContexts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load contexts: $e')),
        data: (contexts) {
          if (contexts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No contexts yet. Tap + to add one.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: contexts.length,
            itemBuilder: (context, index) {
              final ctx = contexts[index];
              return _ContextTile(
                key: ValueKey(ctx.docId),
                context: ctx,
                index: index,
              );
            },
            onReorder: (oldIndex, newIndex) async {
              final adjusted =
                  newIndex > oldIndex ? newIndex - 1 : newIndex;
              final reordered = [...contexts];
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(adjusted, moved);
              await ref
                  .read(contextServiceProvider)
                  .reorderContexts(reordered);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add context',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final existing =
        ref.read(contextsProvider).valueOrNull ?? const <Context>[];
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _ContextNameDialog(
        existingNames: existing.map((c) => c.name).toList(),
      ),
    );
    if (newName == null) return;
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    try {
      await ref
          .read(contextServiceProvider)
          .createContext(name: newName, personDocId: personDocId);
    } on DuplicateContextNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } on ReservedContextNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _ContextTile extends ConsumerWidget {
  const _ContextTile({super.key, required this.context, required this.index});

  final Context context;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconWidget = ContextIcon(name: this.context.iconName, size: 20);
    final hasIcon = ContextIcon.hasIcon(this.context.iconName);
    final counts = ref.watch(contextTaskCountsProvider).valueOrNull ??
        const <String, int>{};
    final count = counts[this.context.name.toLowerCase()] ?? 0;
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Row(
        children: [
          if (hasIcon) ...[
            iconWidget,
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(this.context.name)),
          if (count > 0) _CountBadge(count: count),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Rename',
            onPressed: () => _rename(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final existing =
        ref.read(contextsProvider).valueOrNull ?? const <Context>[];
    final otherNames = existing
        .where((c) => c.docId != this.context.docId)
        .map((c) => c.name)
        .toList();
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _ContextNameDialog(
        initialValue: this.context.name,
        existingNames: otherNames,
        title: 'Rename context',
        submitLabel: 'Rename',
      ),
    );
    if (newName == null) return;
    if (newName == this.context.name) return;

    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final svc = ref.read(contextServiceProvider);
    // Surface a "rename on tasks too?" prompt when the context is in use.
    // Without this the catalog rename leaves orphan references with the old
    // name on every tagged task — confusing because the picker now shows
    // the new name but the cards still show the old one.
    final inUseCount = await svc.countTasksUsingContext(
      contextName: this.context.name,
      personDocId: personDocId,
    );
    if (!context.mounted) return;

    var renameOnTasks = false;
    if (inUseCount > 0) {
      final tasksWord = inUseCount == 1 ? 'task' : 'tasks';
      final choice = await showDialog<_RenameChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Rename "${this.context.name}" → "$newName"?'),
          content: Text(
            '"${this.context.name}" is used by $inUseCount $tasksWord. '
            'Update those $tasksWord to use "$newName" as well?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_RenameChoice.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_RenameChoice.renameOnly),
              child: const Text('Rename only'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_RenameChoice.renameAndUpdate),
              child: const Text('Update tasks'),
            ),
          ],
        ),
      );
      if (choice == null || choice == _RenameChoice.cancel) return;
      renameOnTasks = choice == _RenameChoice.renameAndUpdate;
    }

    try {
      await svc.renameContext(this.context, newName);
      if (renameOnTasks) {
        await svc.renameContextOnAllTasks(
          oldName: this.context.name,
          newName: newName,
          personDocId: personDocId,
        );
      }
    } on DuplicateContextNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } on ReservedContextNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final svc = ref.read(contextServiceProvider);
    final inUseCount = await svc.countTasksUsingContext(
      contextName: this.context.name,
      personDocId: personDocId,
    );
    if (!context.mounted) return;

    if (inUseCount == 0) {
      // No tasks reference this context — simple confirm.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete "${this.context.name}"?'),
          content: const Text(
            'No tasks are tagged with this context.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await svc.deleteContext(this.context);
      return;
    }

    // In-use path: offer the user a choice between removing the context
    // value from those tasks too, or leaving them tagged with the now-
    // orphaned name (the value persists; it just won't appear in the picker).
    final tasksWord = inUseCount == 1 ? 'task' : 'tasks';
    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${this.context.name}"?'),
        content: Text(
          '"${this.context.name}" is used by $inUseCount $tasksWord. '
          'Remove it from those $tasksWord as well?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_DeleteChoice.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DeleteChoice.keepOnTasks),
            child: const Text('Keep on tasks'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DeleteChoice.removeFromTasks),
            child: const Text('Remove from tasks'),
          ),
        ],
      ),
    );
    if (choice == null || choice == _DeleteChoice.cancel) return;

    if (choice == _DeleteChoice.removeFromTasks) {
      await svc.removeContextFromAllTasks(
        contextName: this.context.name,
        personDocId: personDocId,
      );
    }
    await svc.deleteContext(this.context);
  }
}

/// Branching outcomes from the in-use delete dialog.
enum _DeleteChoice { cancel, keepOnTasks, removeFromTasks }

/// Branching outcomes from the in-use rename dialog.
enum _RenameChoice { cancel, renameOnly, renameAndUpdate }

/// Compact pill-shaped task-count badge. Mirror of `_CountBadge` in
/// `area_manage_screen.dart` — kept separate to avoid an extra
/// import-only-for-this dependency between the two manage screens.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ContextNameDialog extends StatefulWidget {
  const _ContextNameDialog({
    this.initialValue,
    required this.existingNames,
    this.title = 'New context',
    this.submitLabel = 'Add',
  });

  final String? initialValue;
  final List<String> existingNames;
  final String title;
  final String submitLabel;

  @override
  State<_ContextNameDialog> createState() => _ContextNameDialogState();
}

class _ContextNameDialogState extends State<_ContextNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Context name'),
          validator: _validate,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  String? _validate(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return 'Name required';
    if (kReservedContextNames.contains(value)) {
      return 'Reserved name; choose another';
    }
    final exists = widget.existingNames
        .any((n) => n.toLowerCase() == value.toLowerCase());
    if (exists) return 'Already in your list';
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(_controller.text.trim());
  }
}

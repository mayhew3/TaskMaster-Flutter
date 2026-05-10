import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../models/area.dart';
import '../providers/area_providers.dart';
import '../services/area_service.dart';

/// "Manage Areas" settings screen (TM-345).
///
/// Lets the user add, rename, delete, and drag-to-reorder areas. Tasks tagged
/// with a deleted area keep their string value — the value just no longer
/// appears in the picker.
class AreaManageScreen extends ConsumerWidget {
  const AreaManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAreas = ref.watch(areasWithDefaultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Areas')),
      body: asyncAreas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load areas: $e')),
        data: (areas) {
          if (areas.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No areas yet. Tap + to add one.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              return _AreaTile(
                key: ValueKey(area.docId),
                area: area,
                index: index,
              );
            },
            onReorder: (oldIndex, newIndex) async {
              final adjusted =
                  newIndex > oldIndex ? newIndex - 1 : newIndex;
              final reordered = [...areas];
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(adjusted, moved);
              await ref.read(areaServiceProvider).reorderAreas(reordered);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Add area',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final existing = ref.read(areasProvider).valueOrNull ?? const <Area>[];
    final newName = await showDialog<String>(
      context: context,
      builder: (_) =>
          _AreaNameDialog(existingNames: existing.map((a) => a.name).toList()),
    );
    if (newName == null) return;
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    try {
      await ref
          .read(areaServiceProvider)
          .createArea(name: newName, personDocId: personDocId);
    } on DuplicateAreaNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } on ReservedAreaNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _AreaTile extends ConsumerWidget {
  const _AreaTile({super.key, required this.area, required this.index});

  final Area area;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(areaTaskCountsProvider).valueOrNull ??
        const <String, int>{};
    final count = counts[area.name.toLowerCase()] ?? 0;
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Row(
        children: [
          Expanded(child: Text(area.name)),
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
    final existing = ref.read(areasProvider).valueOrNull ?? const <Area>[];
    final otherNames = existing
        .where((a) => a.docId != area.docId)
        .map((a) => a.name)
        .toList();
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _AreaNameDialog(
        initialValue: area.name,
        existingNames: otherNames,
        title: 'Rename area',
        submitLabel: 'Rename',
      ),
    );
    if (newName == null) return;
    if (newName == area.name) return;

    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final svc = ref.read(areaServiceProvider);
    // See ContextManageScreen._rename — same rationale: a catalog-only
    // rename leaves orphan references with the old name on tagged tasks.
    final inUseCount = await svc.countTasksUsingArea(
      areaName: area.name,
      personDocId: personDocId,
    );
    if (!context.mounted) return;

    var renameOnTasks = false;
    if (inUseCount > 0) {
      final tasksWord = inUseCount == 1 ? 'task' : 'tasks';
      final choice = await showDialog<_RenameAreaChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Rename "${area.name}" → "$newName"?'),
          content: Text(
            '"${area.name}" is used by $inUseCount $tasksWord. '
            'Update those $tasksWord to use "$newName" as well?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_RenameAreaChoice.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_RenameAreaChoice.renameOnly),
              child: const Text('Rename only'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_RenameAreaChoice.renameAndUpdate),
              child: const Text('Update tasks'),
            ),
          ],
        ),
      );
      if (choice == null || choice == _RenameAreaChoice.cancel) return;
      renameOnTasks = choice == _RenameAreaChoice.renameAndUpdate;
    }

    try {
      await svc.renameArea(area, newName);
      if (renameOnTasks) {
        await svc.renameAreaOnAllTasks(
          oldName: area.name,
          newName: newName,
          personDocId: personDocId,
        );
      }
    } on DuplicateAreaNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } on ReservedAreaNameException catch (e) {
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
    final svc = ref.read(areaServiceProvider);
    final inUseCount = await svc.countTasksUsingArea(
      areaName: area.name,
      personDocId: personDocId,
    );
    if (!context.mounted) return;

    if (inUseCount == 0) {
      // No tasks reference this area — simple confirm.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete "${area.name}"?'),
          content: const Text('No tasks are tagged with this area.'),
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
      await svc.deleteArea(area);
      return;
    }

    // In-use path: offer the user a choice between clearing the area on
    // those tasks or leaving them tagged with the now-orphaned name (the
    // value persists; it just won't appear in the picker).
    final tasksWord = inUseCount == 1 ? 'task' : 'tasks';
    final choice = await showDialog<_DeleteAreaChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${area.name}"?'),
        content: Text(
          '"${area.name}" is used by $inUseCount $tasksWord. '
          'Remove it from those $tasksWord as well?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_DeleteAreaChoice.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DeleteAreaChoice.keepOnTasks),
            child: const Text('Keep on tasks'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_DeleteAreaChoice.removeFromTasks),
            child: const Text('Remove from tasks'),
          ),
        ],
      ),
    );
    if (choice == null || choice == _DeleteAreaChoice.cancel) return;

    if (choice == _DeleteAreaChoice.removeFromTasks) {
      await svc.removeAreaFromAllTasks(
        areaName: area.name,
        personDocId: personDocId,
      );
    }
    await svc.deleteArea(area);
  }
}

/// Branching outcomes from the in-use delete dialog.
enum _DeleteAreaChoice { cancel, keepOnTasks, removeFromTasks }

/// Branching outcomes from the in-use rename dialog.
enum _RenameAreaChoice { cancel, renameOnly, renameAndUpdate }

/// Compact pill-shaped task-count badge shown next to each area / context
/// row in the Manage screens (TM-181). Singular vs plural is left implicit
/// via the bare number — the row's name is right next to it so context is
/// obvious.
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

class _AreaNameDialog extends StatefulWidget {
  const _AreaNameDialog({
    this.initialValue,
    required this.existingNames,
    this.title = 'New area',
    this.submitLabel = 'Add',
  });

  final String? initialValue;
  final List<String> existingNames;
  final String title;
  final String submitLabel;

  @override
  State<_AreaNameDialog> createState() => _AreaNameDialogState();
}

class _AreaNameDialogState extends State<_AreaNameDialog> {
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
          decoration: const InputDecoration(labelText: 'Area name'),
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
    if (kReservedAreaNames.contains(value)) return 'Reserved name; choose another';
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

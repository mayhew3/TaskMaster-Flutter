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
    }
  }
}

class _AreaTile extends ConsumerWidget {
  const _AreaTile({super.key, required this.area, required this.index});

  final Area area;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(area.name),
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
    try {
      await ref.read(areaServiceProvider).renameArea(area, newName);
    } on DuplicateAreaNameException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${area.name}"?'),
        content: const Text(
          "Tasks tagged with this area will keep the value but it won't appear in the picker.",
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
    await ref.read(areaServiceProvider).deleteArea(area);
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

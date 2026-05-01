import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../models/area.dart';
import '../providers/area_providers.dart';
import '../services/area_service.dart';

/// Dropdown for picking the user's `area` for a task (TM-345).
///
/// Sources its options from [areasWithDefaultsProvider] (lazy-seeds defaults
/// for new users). Adds two sentinels to the dropdown values:
///   - `(none)` at the top → maps to `null`
///   - `+ Add new area…` at the bottom → opens an inline dialog that creates
///     a new area on submit and selects it for the current task.
class AreaPicker extends ConsumerStatefulWidget {
  const AreaPicker({
    super.key,
    required this.initialValue,
    required this.valueSetter,
    this.labelText = 'Area',
  });

  final String? initialValue;
  final ValueSetter<String?> valueSetter;
  final String labelText;

  @override
  ConsumerState<AreaPicker> createState() => _AreaPickerState();
}

const String _noneSentinel = '(none)';
const String _addSentinel = '+ Add new area…';

class _AreaPickerState extends ConsumerState<AreaPicker> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue ?? _noneSentinel;
  }

  @override
  Widget build(BuildContext context) {
    final asyncAreas = ref.watch(areasWithDefaultsProvider);
    final areaNames = asyncAreas.maybeWhen(
      data: (areas) => areas.map((a) => a.name).toList(),
      orElse: () => const <String>[],
    );

    // If the current selection is a stale area name (deleted from the list),
    // the dropdown still needs the value present in its items or it crashes
    // — so include it explicitly even if it's not in the live list.
    final values = <String>[
      _noneSentinel,
      ...areaNames,
      if (_selected != _noneSentinel && !areaNames.contains(_selected))
        _selected,
      _addSentinel,
    ];

    return Container(
      margin: const EdgeInsets.all(7.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          contentPadding: const EdgeInsets.fromLTRB(12, 21, 12, 14),
        ),
        value: _selected,
        items: values
            .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
            .toList(),
        onChanged: (String? newValue) async {
          if (newValue == null) return;
          if (newValue == _addSentinel) {
            await _handleAddNew(asyncAreas.valueOrNull ?? const []);
            return;
          }
          setState(() => _selected = newValue);
          widget.valueSetter(newValue == _noneSentinel ? null : newValue);
        },
      ),
    );
  }

  Future<void> _handleAddNew(List<Area> existing) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _AddAreaDialog(existingNames: existing.map((a) => a.name).toList()),
    );
    if (newName == null) {
      // Cancelled — revert dropdown to previous selection by rebuilding.
      setState(() {});
      return;
    }
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      setState(() {});
      return;
    }
    final service = ref.read(areaServiceProvider);
    final created = await service.createArea(name: newName, personDocId: personDocId);
    setState(() => _selected = created.name);
    widget.valueSetter(created.name);
  }
}

class _AddAreaDialog extends StatefulWidget {
  const _AddAreaDialog({required this.existingNames});
  final List<String> existingNames;

  @override
  State<_AddAreaDialog> createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends State<_AddAreaDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New area'),
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
          child: const Text('Add'),
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

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
  // GlobalKey on the DropdownButtonFormField so we can reach into its
  // FormFieldState and call didChange(...) to update the displayed value.
  // Required because DropdownButtonFormField is uncontrolled by `value:`
  // after init — the field tracks its own internal state, and we need to
  // mutate that state from outside (after the inline-add dialog) so the
  // parent's enclosing Form.onChanged fires and hasChanges() re-evaluates.
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

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

    final secondary = Theme.of(context).colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.all(7.0),
      child: DropdownButtonFormField<String>(
        key: _formFieldKey,
        isDense: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          contentPadding: const EdgeInsets.fromLTRB(12, 21, 12, 14),
        ),
        value: _selected,
        // Closed-state display: render every value as plain text. Avoids the
        // sentinel briefly rendering with its divider+colored styling between
        // the user's pick and the dialog opening.
        selectedItemBuilder: (context) =>
            values.map((v) => Text(v)).toList(),
        items: values.map((v) {
          if (v == _addSentinel) {
            return DropdownMenuItem<String>(
              value: v,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      v,
                      style: TextStyle(color: secondary),
                    ),
                  ),
                ],
              ),
            );
          }
          return DropdownMenuItem<String>(value: v, child: Text(v));
        }).toList(),
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
    // Snapshot the previous selection before opening the dialog so we can
    // revert if the user cancels. Do NOT use _selected after the dialog —
    // it's the local state, which is fine here since the sentinel pick
    // didn't update _selected (the if-branch returns early in onChanged).
    final previous = _selected;

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _AddAreaDialog(
          existingNames: existing.map((a) => a.name).toList()),
    );
    if (newName == null) {
      // Cancelled — push the previous value back into the FormField so the
      // dropdown stops showing the sentinel.
      _formFieldKey.currentState?.didChange(previous);
      return;
    }
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      _formFieldKey.currentState?.didChange(previous);
      return;
    }
    final service = ref.read(areaServiceProvider);
    final created =
        await service.createArea(name: newName, personDocId: personDocId);
    // Route through didChange so the FormField's internal state updates,
    // Form.onChanged fires on the parent, and the FAB's hasChanges() check
    // sees the blueprint.area mutation. didChange triggers our own onChanged
    // again with the new value, which handles setState + valueSetter.
    _formFieldKey.currentState?.didChange(created.name);
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

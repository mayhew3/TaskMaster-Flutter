import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../helpers/area_color_helper.dart';
import '../../../models/area.dart';
import '../../../models/task_colors.dart';
import '../providers/area_providers.dart';
import '../services/area_service.dart';

/// Picker for the user's `area` for a task (TM-345).
///
/// Renders as a chevron-style button that opens a modal bottom sheet listing
/// the user's areas. The sheet sources options from [areasWithDefaultsProvider]
/// (lazy-seeds defaults for new users) and includes:
///   - a "None" entry that maps to `null`
///   - a `+ Add new area…` action at the bottom that opens an inline dialog;
///     submitting creates a new area and selects it
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

// Use the shared "+ Add new area…" sentinel so the service's reserved-name
// rejection (kReservedAreaNames) stays in sync with the picker's UI string.
const String _addSentinel = kAddNewSentinelName;

class _AreaPickerState extends ConsumerState<AreaPicker> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Material(
      color: TaskColors.fieldSurface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        // Stable key so widget tests can target the chevron button without
        // depending on Material/InkWell counts elsewhere on the screen.
        key: const Key('area_picker_button'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => _open(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: TaskColors.fieldBorder, width: 1),
          ),
          child: Row(
            children: [
              if (selected != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AreaColorHelper.colorForArea(selected),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  selected ?? 'None',
                  style: TextStyle(
                    color: selected == null
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        selected == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.white.withValues(alpha: 0.40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        // Watch within the sheet builder so additions reflect immediately.
        return Consumer(builder: (ctx, ref, _) {
          final asyncAreas = ref.watch(areasWithDefaultsProvider);
          final areas = asyncAreas.maybeWhen(
            data: (a) => a,
            orElse: () => const <Area>[],
          );
          final names = areas.map((a) => a.name).toList(growable: false);

          return Container(
            decoration: const BoxDecoration(
              color: TaskColors.popupBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: Text(
                      'Select area',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AreaOption(
                            label: 'None',
                            italic: true,
                            selected: _selected == null,
                            onTap: () {
                              setState(() => _selected = null);
                              widget.valueSetter(null);
                              Navigator.of(sheetCtx).pop();
                            },
                          ),
                          ...names.map(
                            (name) => _AreaOption(
                              label: name,
                              dotColor: AreaColorHelper.colorForArea(name),
                              selected: _selected == name,
                              onTap: () {
                                setState(() => _selected = name);
                                widget.valueSetter(name);
                                Navigator.of(sheetCtx).pop();
                              },
                            ),
                          ),
                          // Stale selection: keep it visible so users can
                          // re-select / clear when an area was deleted.
                          if (_selected != null && !names.contains(_selected))
                            _AreaOption(
                              label: _selected!,
                              dotColor:
                                  AreaColorHelper.colorForArea(_selected),
                              selected: true,
                              onTap: () => Navigator.of(sheetCtx).pop(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0x1FFFFFFF)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                    child: _AddAreaAction(
                      onTap: () async {
                        Navigator.of(sheetCtx).pop();
                        await _handleAddNew(areas);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _handleAddNew(List<Area> existing) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _AddAreaDialog(
        existingNames: existing.map((a) => a.name).toList(),
      ),
    );
    if (newName == null) return; // cancelled
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return;
    final service = ref.read(areaServiceProvider);
    try {
      final created =
          await service.createArea(name: newName, personDocId: personDocId);
      if (!mounted) return;
      setState(() => _selected = created.name);
      widget.valueSetter(created.name);
    } on DuplicateAreaNameException catch (e) {
      // The dialog validator catches dups in the in-memory list; this catches
      // races where a second area with the same name synced down between the
      // dialog opening and submit.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } on ReservedAreaNameException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _AreaOption extends StatelessWidget {
  const _AreaOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.italic = false,
  });

  final String label;
  final Color? dotColor;
  final bool selected;
  final bool italic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: italic
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check,
                  size: 18,
                  color: Color.fromRGBO(143, 184, 255, 0.95),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAreaAction extends StatelessWidget {
  const _AddAreaAction({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 10),
              Text(
                _addSentinel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    if (kReservedAreaNames.contains(value)) {
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

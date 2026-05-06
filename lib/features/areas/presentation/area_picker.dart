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
                    child: _InlineAddAreaField(
                      existingNames: areas.map((a) => a.name).toList(),
                      onSubmit: (name) async {
                        final created = await _createAreaInline(name);
                        if (created != null) {
                          // Close the sheet so the parent reflects the
                          // selection without keeping the sheet stale.
                          if (sheetCtx.mounted) {
                            Navigator.of(sheetCtx).pop();
                          }
                        }
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

  /// Returns the created [Area] on success, or `null` if creation was
  /// rejected (e.g. duplicate after a sync race). Surfaces a SnackBar for
  /// user-visible failures.
  Future<Area?> _createAreaInline(String newName) async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) return null;
    final service = ref.read(areaServiceProvider);
    try {
      final created =
          await service.createArea(name: newName, personDocId: personDocId);
      if (!mounted) return created;
      setState(() => _selected = created.name);
      widget.valueSetter(created.name);
      return created;
    } on DuplicateAreaNameException catch (e) {
      // Inline-field validator catches dups in the in-memory list; this
      // catches races where another client synced an area with the same
      // name in between the field's last validation and submit.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return null;
    } on ReservedAreaNameException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return null;
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

/// Inline "add new area" affordance shown at the bottom of the picker
/// sheet. Mirrors the design's `AddNewInline` component: a translucent row
/// with a `+` icon, a TextField, and an Add button that only renders once
/// non-whitespace text is entered. Submits via the Add button or Enter key.
/// Validation messages render inline (no separate dialog).
class _InlineAddAreaField extends StatefulWidget {
  const _InlineAddAreaField({
    required this.existingNames,
    required this.onSubmit,
  });

  final List<String> existingNames;
  final Future<void> Function(String name) onSubmit;

  @override
  State<_InlineAddAreaField> createState() => _InlineAddAreaFieldState();
}

class _InlineAddAreaFieldState extends State<_InlineAddAreaField> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'Name required';
    if (kReservedAreaNames.contains(value)) {
      return 'Reserved name; choose another';
    }
    final exists = widget.existingNames
        .any((n) => n.toLowerCase() == value.toLowerCase());
    if (exists) return 'Already in your list';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final raw = _controller.text;
    final error = _validate(raw);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(raw.trim());
      if (!mounted) return;
      _controller.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 14,
                color: Colors.white.withValues(alpha: 0.50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: 40,
                  enabled: !_submitting,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                    setState(() {}); // refresh Add button visibility
                  },
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    counterText: '',
                    hintText: _addSentinel,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (hasText)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                      backgroundColor: TaskColors.brandMagenta,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFFFB4B4),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

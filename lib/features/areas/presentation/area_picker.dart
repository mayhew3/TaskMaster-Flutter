import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../helpers/area_color_helper.dart';
import '../../../models/area.dart';
import '../../../models/task_colors.dart';
import '../../shared/presentation/widgets/inline_add_field.dart';
import '../providers/area_providers.dart';
import '../services/area_service.dart';

/// Picker for the user's `area` for a task (TM-345).
///
/// Renders as a chevron-style button that opens a modal bottom sheet listing
/// the user's areas. The sheet sources options from [areasWithDefaultsProvider]
/// (lazy-seeds defaults for new users) and includes:
///   - a "None" entry that maps to `null`
///   - a pinned **inline TextField** at the bottom (`+ icon` + "Add new
///     area…" hint) that creates a new area on submit and selects it.
///     Validation messages render inline; there is no separate dialog.
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

// The picker no longer renders the sentinel string in its UI (the inline
// field uses "Add new area…" without the leading "+", since the + icon
// already provides that affordance). The service's reserved-name set
// (kReservedAreaNames) still contains the sentinel so typing it
// literally is rejected by the inline validator.

class _AreaPickerState extends ConsumerState<AreaPicker> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant AreaPicker old) {
    super.didUpdateWidget(old);
    // Keep the local `_selected` in sync when the parent rebuilds with a
    // different `initialValue` (e.g. a programmatic blueprint reset, or
    // a stream-driven re-init). Without this the chevron-button would
    // keep showing a stale name until the user re-opened the sheet.
    if (old.initialValue != widget.initialValue) {
      _selected = widget.initialValue;
    }
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
              // Lift the entire sheet above the soft keyboard so the
              // inline-add TextField at the bottom remains visible while
              // the user types. Without this, the keyboard slides over the
              // field and the user can't see what they're entering. Mirror
              // of the ContextPickerSheet's MediaQuery.viewInsets handling.
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
                    child: Row(
                      children: [
                        const Text(
                          'Select area',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // Done dismisses the sheet without changing the
                        // selection. Picking an area row already auto-pops
                        // the sheet — Done is the escape hatch when the
                        // user wants to exit without picking.
                        TextButton(
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                          style: TextButton.styleFrom(
                            // Don't pick up the global text-button outline
                            // that's set on the dialog/card surface — the
                            // popup BG (TaskColors.popupBg) is darker and a
                            // borderless button reads cleaner here.
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Thin separator beneath the header, matching the prototype.
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
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
                    child: InlineAddField(
                      hintText: 'Add new area…',
                      validator: (value) {
                        if (kReservedAreaNames.contains(value)) {
                          return 'Reserved name; choose another';
                        }
                        final exists = areas.any(
                            (a) => a.name.toLowerCase() == value.toLowerCase());
                        if (exists) return 'Already in your list';
                        return null;
                      },
                      onSubmit: (name) async {
                        final errorMessage = await _createAreaInline(name);
                        if (errorMessage != null) return errorMessage;
                        // Close the sheet so the parent reflects the
                        // selection without keeping the sheet stale.
                        if (sheetCtx.mounted) {
                          Navigator.of(sheetCtx).pop();
                        }
                        return null;
                      },
                    ),
                  ),
                ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  /// Creates a new area and selects it. Returns `null` on success, or a
  /// user-visible error message that the inline field should display.
  /// The previous SnackBar fallback was removed in favor of inline
  /// errors so the user's typed input is preserved when the service
  /// rejects (DuplicateAreaNameException race / ReservedAreaNameException).
  Future<String?> _createAreaInline(String newName) async {
    final personDocId = ref.read(personDocIdProvider);
    if (personDocId == null) {
      return 'Cannot add: not signed in';
    }
    final service = ref.read(areaServiceProvider);
    try {
      final created =
          await service.createArea(name: newName, personDocId: personDocId);
      if (!mounted) return null;
      setState(() => _selected = created.name);
      widget.valueSetter(created.name);
      return null;
    } on DuplicateAreaNameException catch (e) {
      // Inline-field validator catches dups in the in-memory list; this
      // catches races where another client synced an area with the same
      // name in between the field's last validation and submit.
      return e.toString();
    } on ReservedAreaNameException catch (e) {
      return e.toString();
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


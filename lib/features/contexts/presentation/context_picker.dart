import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../models/context.dart' as ctx_model;
import '../../../models/task_colors.dart';
import '../../../models/task_context.dart';
import '../../shared/presentation/widgets/context_icon.dart';
import '../../shared/presentation/widgets/inline_add_field.dart';
import '../../shared/presentation/widgets/pill.dart';
import '../providers/context_providers.dart';
import '../services/context_service.dart';

/// Multi-select context picker for the task add/edit screen (TM-181).
///
/// Renders zero-or-more selected contexts as removable [Pill]s followed by an
/// [AddPill] that opens a modal bottom sheet listing the user's REMAINING
/// contexts (already-selected ones are filtered out — never shown twice).
/// The bottom sheet ends with an inline "+ Add new context…" field that
/// creates AND selects the new context in a single tap, mirroring the design
/// prototype's `ContextsPicker` flow.
///
/// Reads/writes the canonical [TaskContext] list owned by the parent edit
/// screen so the existing `taskItemBlueprint.contexts` field is the source of
/// truth (no internal duplicate state).
class ContextPicker extends ConsumerWidget {
  final List<TaskContext> selected;
  final ValueChanged<List<TaskContext>> onChanged;

  const ContextPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContexts = ref.watch(contextsWithDefaultsProvider);
    final available = asyncContexts.valueOrNull ?? const <ctx_model.Context>[];

    // Build a name → catalog Context lookup so each pill can read its
    // iconName from the catalog, even when the task's TaskContext only
    // carries the bare name (the canonical case post-181).
    final byName = <String, ctx_model.Context>{
      for (final c in available) c.name.toLowerCase(): c,
    };

    final pills = <Widget>[
      for (final tc in selected)
        Pill(
          label: Text(tc.name),
          leading: () {
            final iconName = byName[tc.name.toLowerCase()]?.iconName;
            if (!ContextIcon.hasIcon(iconName)) return null;
            return ContextIcon(name: iconName, size: 12);
          }(),
          onRemove: () {
            final next = [...selected]..removeWhere((x) => x.name == tc.name);
            onChanged(next);
          },
        ),
      AddPill(
        label: 'Add',
        onTap: () => _openPickerSheet(context, ref, available),
      ),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: pills,
    );
  }

  Future<void> _openPickerSheet(
    BuildContext context,
    WidgetRef ref,
    List<ctx_model.Context> available,
  ) async {
    final selectedNames = selected.map((c) => c.name.toLowerCase()).toSet();
    final remaining = available
        .where((c) => !selectedNames.contains(c.name.toLowerCase()))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ContextPickerSheet(
          remaining: remaining,
          alreadySelectedCount: selected.length,
          existingNames:
              available.map((c) => c.name).toList(growable: false),
          onSelect: (ctx) {
            // Append the catalog context and dismiss the sheet — same
            // contract as `onCreateAndSelect`. Keeping the sheet open
            // would also reuse a stale `selected` snapshot captured by
            // this closure, which made consecutive taps appear to
            // overwrite each other; one-pick-per-open avoids the trap.
            final next = [
              ...selected,
              TaskContext.named(ctx.name),
            ];
            onChanged(next);
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
          },
          // Returns null on success, or an error string to surface inline.
          // The sheet itself dismisses on success (per the AreaPicker
          // pattern — once the new context is created and selected, there's
          // nothing left to do in the sheet).
          onCreateAndSelect: (newName) async {
            final personDocId = ref.read(personDocIdProvider);
            if (personDocId == null) return 'Not signed in';
            try {
              final created =
                  await ref.read(contextServiceProvider).createContext(
                        name: newName,
                        personDocId: personDocId,
                      );
              final next = [
                ...selected,
                TaskContext.named(created.name),
              ];
              onChanged(next);
              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
              return null;
            } on DuplicateContextNameException catch (e) {
              return e.toString();
            } on ReservedContextNameException catch (e) {
              return e.toString();
            }
          },
        );
      },
    );
  }
}

/// Stateful sheet widget so the inline-add TextField can survive selection
/// taps without rebuilding from props each time.
class _ContextPickerSheet extends StatelessWidget {
  final List<ctx_model.Context> remaining;
  final int alreadySelectedCount;
  final List<String> existingNames;
  final ValueChanged<ctx_model.Context> onSelect;
  final Future<String?> Function(String) onCreateAndSelect;

  const _ContextPickerSheet({
    required this.remaining,
    required this.alreadySelectedCount,
    required this.existingNames,
    required this.onSelect,
    required this.onCreateAndSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TaskColors.popupBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
                child: Row(
                  children: [
                    Text(
                      alreadySelectedCount == 0
                          ? 'Add context'
                          : 'Add context · $alreadySelectedCount already selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Done dismisses the sheet without picking. Tapping a
                    // grid cell or submitting the inline-add already auto-
                    // pops the sheet — Done is the escape hatch when the
                    // user opens the sheet, decides not to add anything,
                    // and wants to close without picking. Mirrors the
                    // AreaPicker header (TM-345).
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
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
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (remaining.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'All contexts are already selected.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        _Grid(
                          remaining: remaining,
                          onSelect: onSelect,
                        ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InlineAddField(
                          hintText: 'Add new context…',
                          validator: (value) {
                            if (kReservedContextNames.contains(value)) {
                              return 'Reserved name; choose another';
                            }
                            final exists = existingNames.any(
                                (n) => n.toLowerCase() == value.toLowerCase());
                            if (exists) return 'Already in your list';
                            return null;
                          },
                          onSubmit: onCreateAndSelect,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column grid of context cells. Tapping a cell calls [onSelect] and
/// keeps the sheet open so the user can chain selections.
class _Grid extends StatelessWidget {
  final List<ctx_model.Context> remaining;
  final ValueChanged<ctx_model.Context> onSelect;

  const _Grid({required this.remaining, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < remaining.length; i += 2) {
      final left = remaining[i];
      final right = i + 1 < remaining.length ? remaining[i + 1] : null;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: _Cell(value: left, onTap: () => onSelect(left))),
            const SizedBox(width: 8),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _Cell(value: right, onTap: () => onSelect(right)),
            ),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _Cell extends StatelessWidget {
  final ctx_model.Context value;
  final VoidCallback onTap;

  const _Cell({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (ContextIcon.hasIcon(value.iconName)) ...[
                ContextIcon(name: value.iconName, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.add,
                size: 16,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


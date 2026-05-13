import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/area.dart';
import '../../../models/task_colors.dart';
import '../../shared/presentation/widgets/pill.dart';
import '../providers/area_providers.dart';

/// Multi-select Area picker used by TM-359's ViewOptionsSheet. Mirrors the
/// pattern from `ContextPicker` (chips of currently-selected entries +
/// `AddPill` that opens a modal bottom sheet), but the sheet is true
/// multi-select — tapping toggles selection and stays open until the user
/// dismisses with Done. The picker stores selections by *name* rather than
/// docId so a since-deleted area renders as a ghost chip with a remove
/// affordance instead of silently disappearing.
class AreaMultiPicker extends ConsumerWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const AreaMultiPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAreas = ref.watch(areasProvider);
    final available = asyncAreas.value ?? const <Area>[];
    final knownNames =
        available.map((a) => a.name.toLowerCase()).toSet();

    // Sort selected: known names first (in the order the catalog provides),
    // then ghost names alphabetically. Lets the user see "the filter is
    // pointing at a missing area" clearly without burying it.
    final selectedKnown = available
        .where((a) => selected
            .map((n) => n.toLowerCase())
            .contains(a.name.toLowerCase()))
        .map((a) => a.name)
        .toList();
    final selectedGhost = selected
        .where((n) => !knownNames.contains(n.toLowerCase()))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final pills = <Widget>[
      for (final name in selectedKnown)
        Pill(
          label: Text(name),
          onRemove: () {
            final next = {...selected}..removeWhere(
                (s) => s.toLowerCase() == name.toLowerCase());
            onChanged(next);
          },
        ),
      for (final ghost in selectedGhost)
        Pill(
          // Strike-through indicates the area no longer exists in the
          // catalog. Tap the ✕ to clear the dead filter.
          label: Text(
            ghost,
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.white,
            ),
          ),
          onRemove: () {
            final next = {...selected}..removeWhere(
                (s) => s.toLowerCase() == ghost.toLowerCase());
            onChanged(next);
          },
        ),
      AddPill(
        label: 'Pick areas',
        onTap: () => _openSheet(context, available),
      ),
    ];

    return Wrap(spacing: 6, runSpacing: 6, children: pills);
  }

  Future<void> _openSheet(
    BuildContext context,
    List<Area> available,
  ) async {
    // Capture the current selection on open and let the sheet mutate a
    // local copy; commit on close (instead of after every tap) so a fast
    // multi-select doesn't trigger N rebuilds of the parent.
    var working = {...selected};
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return _AreaMultiSheet(
              available: available,
              selectedLower: working.map((s) => s.toLowerCase()).toSet(),
              onToggle: (name) {
                setSheetState(() {
                  final isSelected = working
                      .any((s) => s.toLowerCase() == name.toLowerCase());
                  if (isSelected) {
                    working.removeWhere(
                        (s) => s.toLowerCase() == name.toLowerCase());
                  } else {
                    working.add(name);
                  }
                });
              },
              onDone: () {
                onChanged(working);
                Navigator.of(sheetContext).pop();
              },
            );
          },
        );
      },
    );
  }
}

class _AreaMultiSheet extends StatelessWidget {
  final List<Area> available;
  final Set<String> selectedLower;
  final ValueChanged<String> onToggle;
  final VoidCallback onDone;

  const _AreaMultiSheet({
    required this.available,
    required this.selectedLower,
    required this.onToggle,
    required this.onDone,
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
                    const Text(
                      'Filter by area',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onDone,
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
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  itemCount: available.length,
                  itemBuilder: (context, i) {
                    final area = available[i];
                    final isSelected =
                        selectedLower.contains(area.name.toLowerCase());
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => onToggle(area.name),
                      title: Text(
                        area.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: TaskColors.highlight,
                      checkColor: Colors.white,
                    );
                  },
                ),
              ),
              if (available.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No areas to filter by.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
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

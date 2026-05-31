import 'package:built_collection/built_collection.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/platform/form_factor.dart';
import '../../../date_util.dart';
import '../../../parse_helper.dart';
import '../providers/create_sprint_draft_provider.dart';
import '../providers/sprint_providers.dart';
import '../../shared/presentation/plan_task_list.dart';
import '../../shared/presentation/widgets/editable_task_field.dart';
import '../../shared/presentation/widgets/nullable_dropdown.dart';
import '../../shared/presentation/connection_status_indicator.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/app_drawer.dart';

/// Create-sprint cadence form.
///
/// TM-388: form state (numUnits / unitName / sprintStart) lives in
/// [createSprintDraftProvider] now, not in this widget's State, so the
/// wide in-shell task picker and `planBasePool` (sidebar faceted counts)
/// read the same values. This widget owns only the two display text
/// controllers, kept in sync with the watched draft.
///
/// "Create Sprint" branches by layout:
///   - **wide** (sidebar visible): flip [createSprintStepProvider] to
///     `picking` so `PlanningHome` swaps in `PlanTaskList` IN PLACE — no
///     full-screen route that would cover the sidebar.
///   - **compact**: push `PlanTaskList` as a full-screen route (unchanged).
class NewSprintScreen extends ConsumerStatefulWidget {
  const NewSprintScreen({super.key});

  @override
  ConsumerState<NewSprintScreen> createState() => _NewSprintScreenState();
}

class _NewSprintScreenState extends ConsumerState<NewSprintScreen> {
  late TextEditingController sprintStartDateController;
  late TextEditingController sprintStartTimeController;

  // True while build() is force-syncing controller text from the draft.
  // `controller.text = ...` notifies DateTimeField's internal listener
  // synchronously, which fires `onChanged` → would call setStartDate /
  // setStartTime on the notifier *inside build()* and trip Riverpod's
  // "modify a provider while building" assertion. The onChanged handlers
  // skip on this flag so only genuine picker selections write back.
  bool _syncingFromDraft = false;

  final BuiltList<String> possibleRecurUnits = ListBuilder<String>([
    'Days',
    'Weeks',
    'Months',
    'Years',
  ]).build();

  @override
  void initState() {
    super.initState();
    sprintStartDateController = TextEditingController();
    sprintStartTimeController = TextEditingController();
  }

  @override
  void dispose() {
    sprintStartDateController.dispose();
    sprintStartTimeController.dispose();
    super.dispose();
  }

  CreateSprintDraft get _draftNotifier =>
      ref.read(createSprintDraftProvider.notifier);

  void _openPlanning(BuildContext context) async {
    // Compact-only full-screen route. Params sourced from the draft so
    // the picker matches what the form showed (single source of truth).
    final draft = ref.read(createSprintDraftProvider);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PlanTaskList(
            numUnits: draft.numUnits,
            unitName: draft.unitName,
            startDate: draft.sprintStart,
          );
        },
      ),
    );
  }

  void _onCreateSprint(BuildContext context) {
    if (isWideLayout(MediaQuery.sizeOf(context))) {
      ref.read(createSprintStepProvider.notifier).toPicker();
    } else {
      _openPlanning(context);
    }
  }

  Widget _lastSprintSummary() {
    final lastCompleted = ref.watch(lastCompletedSprintProvider);

    if (lastCompleted == null) {
      return const Text('This is your first sprint! Choose the cadence below:');
    } else {
      DateTime oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      DateTime lastEndDate = lastCompleted.endDate;
      String dateString = oneYearAgo.isAfter(lastEndDate)
          ? ' over a year ago.'
          : DateUtil.formatMediumMaybeHidingYear(lastEndDate);
      return Text('Last Sprint Ended: $dateString');
    }
  }

  DateTime _getLowerLimit() {
    final lastCompleted = ref.read(lastCompletedSprintProvider);
    return lastCompleted?.endDate ?? DateTime(DateTime.now().year - 1);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createSprintDraftProvider);
    final wide = isWideLayout(MediaQuery.sizeOf(context));
    // TM-388 (R1 follow-up): the Num/Unit fields take `initialText` /
    // `initialValue` only at mount and don't react to subsequent changes
    // (the shared widgets are read-once-on-init). When the draft
    // re-seeds (a late `lastCompletedSprint` arrival on an untouched
    // form), the displayed Num/Unit would diverge from the underlying
    // draft. Forcing the ValueKey to track the seed identity remounts
    // those fields with the freshly-seeded initial value. Typing into
    // the field calls `_draftNotifier.set*` (writes to `_userEdited`)
    // but doesn't change `lastCompleted.docId`, so this key stays
    // stable across keystrokes — no spurious cursor-resetting remounts
    // mid-edit.
    final lastCompleted = ref.watch(lastCompletedSprintProvider);
    final seedKey = lastCompleted?.docId ?? '__none__';

    // Keep the display controllers in sync with the draft (these are
    // picker-driven, never free-typed, so resetting text is safe).
    final dateStr = DateFormat('MM-dd-yyyy').format(draft.sprintStart.toLocal());
    final timeStr = DateFormat('hh:mm a').format(draft.sprintStart.toLocal());
    if (sprintStartDateController.text != dateStr ||
        sprintStartTimeController.text != timeStr) {
      _syncingFromDraft = true;
      if (sprintStartDateController.text != dateStr) {
        sprintStartDateController.text = dateStr;
      }
      if (sprintStartTimeController.text != timeStr) {
        sprintStartTimeController.text = timeStr;
      }
      _syncingFromDraft = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: const <Widget>[
          ConnectionStatusIndicator(),
          RefreshButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: _lastSprintSummary(),
            ),
            Row(
              children: [
                SizedBox(
                  width: 80.0,
                  child: EditableTaskField(
                    key: ValueKey('num-$seedKey'),
                    initialText: draft.numUnits.toString(),
                    labelText: 'Num',
                    inputType: TextInputType.number,
                    onChanged: (value) => _draftNotifier
                        .setNumUnits(ParseHelper.parseInt(value) ?? 1),
                    fieldSetter: (value) => _draftNotifier
                        .setNumUnits(ParseHelper.parseInt(value) ?? 1),
                  ),
                ),
                Expanded(
                  child: NullableDropdown(
                    key: ValueKey('unit-$seedKey'),
                    initialValue: draft.unitName,
                    labelText: 'Unit',
                    possibleValues: possibleRecurUnits,
                    onChanged: (value) =>
                        _draftNotifier.setUnitName(value ?? ''),
                    valueSetter: (value) =>
                        _draftNotifier.setUnitName(value ?? ''),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(7.0),
                    child: DateTimeField(
                      controller: sprintStartDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                      ),
                      onChanged: (value) {
                        if (_syncingFromDraft) return;
                        _draftNotifier.setStartDate(value ?? DateTime.now());
                      },
                      onShowPicker: (context, currentValue) async {
                        return await showDatePicker(
                          context: context,
                          initialDate: currentValue ?? draft.sprintStart,
                          firstDate: _getLowerLimit(),
                          lastDate: DateTime(2100),
                        );
                      },
                      format: DateFormat('MM-dd-yyyy'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(7.0),
                    child: DateTimeField(
                      controller: sprintStartTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                      ),
                      onChanged: (value) {
                        if (_syncingFromDraft) return;
                        _draftNotifier.setStartTime(value ?? DateTime.now());
                      },
                      onShowPicker: (context, currentValue) async {
                        DateTime base = currentValue ?? draft.sprintStart;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(base),
                        );
                        return DateTimeField.convert(time);
                      },
                      format: DateFormat('hh:mm a'),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _onCreateSprint(context),
              child: const Text('Create Sprint'),
            ),
          ],
        ),
      ),
      // TM-388: wide uses the sidebar profile footer to open the wide
      // shell's drawer; suppress this inner-screen drawer + auto-burger
      // on wide.
      drawer: wide ? null : const AppDrawer(),
    );
  }
}

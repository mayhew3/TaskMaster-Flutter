import 'package:built_collection/built_collection.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../date_util.dart';
import '../../../parse_helper.dart';
import '../../../core/providers/firebase_providers.dart';
import '../providers/sprint_providers.dart';
import 'sprint_planning_screen.dart';
import '../../shared/presentation/widgets/editable_task_field.dart';
import '../../shared/presentation/widgets/nullable_dropdown.dart';
import '../../shared/presentation/refresh_button.dart';
import '../../shared/presentation/app_drawer.dart';
import '../../shared/presentation/app_bottom_nav.dart';

class NewSprintScreen extends ConsumerStatefulWidget {
  const NewSprintScreen({super.key});

  @override
  ConsumerState<NewSprintScreen> createState() => _NewSprintScreenState();
}

class _NewSprintScreenState extends ConsumerState<NewSprintScreen> {
  DateTime sprintStart = DateTime.now();
  late TextEditingController sprintStartDateController;
  late TextEditingController sprintStartTimeController;

  int numUnits = 1;
  String unitName = 'Weeks';

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

  void _updateDatesOnInit() {
    final lastCompleted = ref.read(lastCompletedSprintProvider);

    final nextScheduled = _getNextScheduledStart();
    if (nextScheduled != null && lastCompleted != null) {
      numUnits = lastCompleted.numUnits;
      unitName = lastCompleted.unitName;
      sprintStart = nextScheduled;
    }

    sprintStartDateController.text =
        DateFormat('MM-dd-yyyy').format(sprintStart.toLocal());
    sprintStartTimeController.text =
        DateFormat('hh:mm a').format(sprintStart.toLocal());
  }

  DateTime? _getNextScheduledStart() {
    final lastCompleted = ref.read(lastCompletedSprintProvider);

    if (lastCompleted == null) {
      return null;
    }

    DateTime nextStart;
    DateTime nextEnd = lastCompleted.endDate;
    DateTime now = DateTime.now();

    do {
      nextStart = nextEnd;
      nextEnd = DateUtil.adjustToDate(
        nextStart,
        lastCompleted.numUnits,
        lastCompleted.unitName,
      );
    } while (nextEnd.isBefore(now));

    return nextStart;
  }

  void updateDateForDateField(DateTime? dateTime) {
    DateTime base = dateTime ?? DateTime.now();
    setState(() {
      sprintStart = DateUtil.combineDateAndTime(base, sprintStart);
      sprintStartDateController.text =
          DateFormat('MM-dd-yyyy').format(base.toLocal());
    });
  }

  void updateTimeForDateField(DateTime? dateTime) {
    DateTime base = dateTime ?? DateTime.now();
    setState(() {
      sprintStart = DateUtil.combineDateAndTime(sprintStart, base);
      sprintStartTimeController.text =
          DateFormat('hh:mm a').format(base.toLocal());
    });
  }

  void _openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return SprintPlanningScreen(
            numUnits: numUnits,
            unitName: unitName,
            startDate: sprintStart,
          );
        },
      ),
    );
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
    // Initialize dates on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sprintStartDateController.text.isEmpty) {
        _updateDatesOnInit();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: const <Widget>[
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
                    initialText: numUnits.toString(),
                    labelText: 'Num',
                    inputType: TextInputType.number,
                    onChanged: (value) =>
                        numUnits = ParseHelper.parseInt(value) ?? 1,
                    fieldSetter: (value) =>
                        numUnits = ParseHelper.parseInt(value) ?? 1,
                  ),
                ),
                Expanded(
                  child: NullableDropdown(
                    initialValue: unitName,
                    labelText: 'Unit',
                    possibleValues: possibleRecurUnits,
                    onChanged: (value) => unitName = value ?? '',
                    valueSetter: (value) => unitName = value ?? '',
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
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => updateDateForDateField(value),
                      onShowPicker: (context, currentValue) async {
                        return await showDatePicker(
                          context: context,
                          initialDate: currentValue ?? sprintStart,
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
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => updateTimeForDateField(value),
                      onShowPicker: (context, currentValue) async {
                        DateTime base = currentValue ?? sprintStart;
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
              onPressed: () => _openPlanning(context),
              child: const Text('Create Sprint'),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}

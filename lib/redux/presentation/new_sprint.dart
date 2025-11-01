import 'package:built_collection/built_collection.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/redux/presentation/new_sprint_viewmodel.dart';
import 'package:taskmaster/redux/presentation/plan_task_list.dart';
import 'package:taskmaster/redux/presentation/refresh_button.dart';
import 'package:taskmaster/redux/presentation/task_main_menu.dart';

import '../../date_util.dart';
import '../../models/sprint.dart';
import '../../parse_helper.dart';
import '../app_state.dart';
import '../containers/tab_selector.dart';
import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class NewSprint extends StatefulWidget {
  const NewSprint({super.key});

  @override
  State<StatefulWidget> createState() => _NewSprintState();
}

class _NewSprintState extends State<NewSprint> {

  DateTime sprintStart = DateTime.now();
  TextEditingController sprintStartDateController = TextEditingController();
  TextEditingController sprintStartTimeController = TextEditingController();

  int numUnits = 1;
  String unitName = 'Weeks';

  final BuiltList<String> possibleRecurUnits = ListBuilder<String>([
    'Days',
    'Weeks',
    'Months',
    'Years',
  ]).build();

  @override
  void dispose() {
    sprintStartDateController.dispose();
    sprintStartTimeController.dispose();
    super.dispose();
  }

  void _updateDatesOnInit(NewSprintViewModel viewModel) {
    _updateDates(getNextScheduledStart(viewModel), viewModel);
  }

/*

  void _updateNewSprintStartAfterCreate(NewSprintViewModel viewModel) {
    _updateDates(viewModel.lastCompleted?.endDate, viewModel);
  }
*/

  void _updateDates(DateTime? nextScheduled, NewSprintViewModel viewModel) {
    if (nextScheduled != null) {
      numUnits = viewModel.lastCompleted!.numUnits;
      unitName = viewModel.lastCompleted!.unitName;
      sprintStart = nextScheduled;
    }
    sprintStartDateController.text = viewModel.timezoneHelper.getFormattedLocalTime(sprintStart, 'MM-dd-yyyy');
    sprintStartTimeController.text = viewModel.timezoneHelper.getFormattedLocalTime(sprintStart, 'hh:mm a');
  }

  DateTime? getNextScheduledStart(NewSprintViewModel viewModel) {
    Sprint? localLastCompleted = viewModel.lastCompleted;

    if (localLastCompleted == null) {
      return null;
    }

    DateTime nextStart;
    DateTime nextEnd = localLastCompleted.endDate;
    DateTime now = DateTime.now();

    do {
      nextStart = nextEnd;
      nextEnd = DateUtil.adjustToDate(
          nextStart,
          localLastCompleted.numUnits,
          localLastCompleted.unitName
      );
    } while (nextEnd.isBefore(now));

    return nextStart;
  }

  void updateDateForDateField(DateTime? dateTime, NewSprintViewModel viewModel) {
    DateTime base = dateTime ?? DateTime.now();
    sprintStart = DateUtil.combineDateAndTime(base, sprintStart);
    sprintStartDateController.text = viewModel.timezoneHelper.getFormattedLocalTime(base, 'MM-dd-yyyy');
  }

  void updateTimeForDateField(DateTime? dateTime, NewSprintViewModel viewModel) {
    DateTime base = dateTime ?? DateTime.now();
    sprintStart = DateUtil.combineDateAndTime(sprintStart, base);
    sprintStartTimeController.text = viewModel.timezoneHelper.getFormattedLocalTime(base, 'hh:mm a');
  }

  void _openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList(
            numUnits: numUnits,
            unitName: unitName,
            startDate: sprintStart,
          );
        },
        )
    );
    /*setState(() {
      if (result == 'Added') {
        _updateSprints();
        _updateNewSprintStartAfterCreate();
      } else {
        _updateDatesOnInit();
      }
    });*/
  }

  Widget _lastSprintSummary(NewSprintViewModel viewModel) {
    if (viewModel.lastCompleted == null) {
      return Text('This is your first sprint! Choose the cadence below:');
    } else {
      DateTime oneYearAgo = DateTime.now().subtract(Duration(days: 365));
      DateTime lastEndDate = viewModel.lastCompleted!.endDate;
      String dateString = oneYearAgo.isAfter(lastEndDate) ?
      ' over a year ago.' :
      DateUtil.formatMediumMaybeHidingYear(lastEndDate);
      return Text('Last Sprint Ended: $dateString');
    }
  }

  DateTime _getLowerLimit(NewSprintViewModel viewModel) {
    return viewModel.lastCompleted?.endDate ?? DateTime(DateTime.now().year - 1);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NewSprintViewModel>(
        builder: (context, NewSprintViewModel viewModel) {
          _updateDatesOnInit(viewModel);
          return Scaffold(
            appBar: AppBar(
              title: Text('All Tasks'),
              actions: <Widget>[
                RefreshButton(),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: _lastSprintSummary(viewModel),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 80.0,
                        child: EditableTaskField(
                          initialText: numUnits.toString(),
                          labelText: 'Num',
                          inputType: TextInputType.number,
                          onChanged: (value) => numUnits = ParseHelper.parseInt(value) ?? 1,
                          fieldSetter: (value) => numUnits = ParseHelper.parseInt(value) ?? 1,
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
                            margin: EdgeInsets.all(7.0),
                            child: DateTimeField(
                              controller: sprintStartDateController,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                filled: false,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => updateDateForDateField(value, viewModel),
                              onShowPicker: (context, currentValue) async {
                                return await showDatePicker(
                                    context: context,
                                    initialDate: currentValue ?? sprintStart,
                                    firstDate: _getLowerLimit(viewModel),
                                    lastDate: DateTime(2100));
                              },
                              format: DateFormat('MM-dd-yyyy'),
                            ),
                          )
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(7.0),
                          child: DateTimeField(
                            controller: sprintStartTimeController,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              filled: false,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => updateTimeForDateField(value, viewModel),
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
                      child: Text('Create Sprint')),
                ],
              ),
            ),
            drawer: TaskMainMenu(),
            bottomNavigationBar: TabSelector(),
          );
        },
        converter: NewSprintViewModel.fromStore
    );
  }

}
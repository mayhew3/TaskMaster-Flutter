
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/parse_helper.dart';
import 'package:taskmaster/screens/plan_task_list.dart';
import 'package:taskmaster/screens/task_list.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';
import 'package:taskmaster/widgets/task_main_menu.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../typedefs.dart';

class PlanningHome extends StatefulWidget {

  final AppState appState;
  final BottomNavigationBarGetter bottomNavigationBarGetter;
  final TaskHelper taskHelper;

  PlanningHome({
    Key? key,
    required this.appState,
    required this.bottomNavigationBarGetter,
    required this.taskHelper,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlanningHomeState();

}

class PlanningHomeState extends State<PlanningHome> {

  DateTime sprintStart = DateTime.now();
  TextEditingController sprintStartDateController = TextEditingController();
  TextEditingController sprintStartTimeController = TextEditingController();

  int numUnits = 1;
  String unitName = 'Weeks';
  Sprint? activeSprint;
  Sprint? lastCompleted;

  List<String> possibleRecurUnits = [
    'Days',
    'Weeks',
    'Months',
    'Years',
  ];

  @override
  void initState() {
    super.initState();
    _updateSprints();
    _updateDatesOnInit();
  }


  @override
  void dispose() {
    sprintStartDateController.dispose();
    sprintStartTimeController.dispose();
    super.dispose();
  }

  void _updateSprints() {
    activeSprint = widget.appState.getActiveSprint();
    lastCompleted = widget.appState.getLastCompletedSprint();
  }

  void _updateDatesOnInit() {
    if (lastCompleted != null) {
      numUnits = lastCompleted!.numUnits.value!;
      unitName = lastCompleted!.unitName.value!;
      sprintStart = getNextScheduledStart();
    }
    sprintStartDateController.text = DateFormat('MM-dd-yyyy').format(sprintStart);
    sprintStartTimeController.text = DateFormat('hh:mm a').format(sprintStart);
  }

  void _updateNewSprintStartAfterCreate() {
    if (lastCompleted != null) {
      numUnits = lastCompleted!.numUnits.value!;
      unitName = lastCompleted!.unitName.value!;
      sprintStart = lastCompleted!.endDate.value!;
    }
    sprintStartDateController.text = DateFormat('MM-dd-yyyy').format(sprintStart);
    sprintStartTimeController.text = DateFormat('hh:mm a').format(sprintStart);
  }

  DateTime getNextScheduledStart() {
    DateTime nextStart;
    DateTime nextEnd = lastCompleted!.endDate.value!;
    DateTime now = DateTime.now();

    do {
      nextStart = nextEnd;
      nextEnd = DateUtil.adjustToDate(
          nextStart,
          lastCompleted!.numUnits.value!,
          lastCompleted!.unitName.value!
      );
    } while (nextEnd.isBefore(now));

    return nextStart;
  }

  void updateDateForDateField(DateTime? dateTime) {
    DateTime base = dateTime ?? DateTime.now();
    sprintStart = DateUtil.combineDateAndTime(base, sprintStart);
    sprintStartDateController.text = DateFormat('MM-dd-yyyy').format(base);
  }

  void updateTimeForDateField(DateTime? dateTime) {
    DateTime base = dateTime ?? DateTime.now();
    sprintStart = DateUtil.combineDateAndTime(sprintStart, base);
    sprintStartTimeController.text = DateFormat('hh:mm a').format(base);
  }

  void _openPlanning(BuildContext context) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return PlanTaskList(
            appState: widget.appState,
            taskHelper: widget.taskHelper,
            taskListGetter: widget.appState.getAllTasks,
            numUnits: numUnits,
            unitName: unitName,
            startDate: sprintStart,
          );
        },
        )
    );
    setState(() {
      _updateSprints();
      _updateNewSprintStartAfterCreate();
    });
  }

  String _getSubHeader() {
    String startDateFormatted = DateFormat('M/d').format(activeSprint!.startDate.value!);
    String endDateFormatted = DateFormat('M/d').format(activeSprint!.endDate.value!);
    return 'Tasks for ' + startDateFormatted + ' - ' + endDateFormatted;
  }

  String _getSubSubHeader() {
    DateTime endDate = activeSprint!.endDate.value!;
    String goodFormat = timeago.format(endDate, allowFromNow: true);
    String better = goodFormat.replaceAll('from now', 'left');
    return '(' + better + ')';
  }

  Widget _lastSprintSummary() {
    if (lastCompleted == null) {
      return Text('This is your first sprint! Choose the cadence below:');
    } else {
      DateTime oneYearAgo = DateTime.now().subtract(Duration(days: 365));
      DateTime lastEndDate = lastCompleted!.endDate.value!;
      String dateString = oneYearAgo.isAfter(lastEndDate) ?
                        ' over a year ago.' :
                        DateUtil.formatMediumMaybeHidingYear(lastEndDate);
      return Text('Last Sprint Ended: ' + dateString);
    }
  }

  DateTime _getLowerLimit() {
    return lastCompleted?.endDate.value ?? DateTime(DateTime.now().year - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (this.activeSprint == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('New Sprint'),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
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
                          onChanged: (value) => updateDateForDateField(value),
                          onShowPicker: (context, currentValue) async {
                            return await showDatePicker(
                                context: context,
                                initialDate: currentValue ?? sprintStart,
                                firstDate: _getLowerLimit(),
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
              FlatButton(
                  color: TaskColors.cardColor,
                  onPressed: () => _openPlanning(context),
                  child: Text('Create Sprint')),
            ],
          ),
        ),
        drawer: TaskMainMenu(
          appState: widget.appState,
        ),
        bottomNavigationBar: widget.bottomNavigationBarGetter(),
      );
    } else {
      return TaskListScreen(
        title: 'Sprint Tasks',
        appState: widget.appState,
        bottomNavigationBarGetter: widget.bottomNavigationBarGetter,
        taskHelper: widget.taskHelper,
        taskListGetter: widget.appState.getTasksForActiveSprint,
        sprint: activeSprint,
        subHeader: _getSubHeader(),
        subSubHeader: _getSubSubHeader(),
      );
    }
  }

}
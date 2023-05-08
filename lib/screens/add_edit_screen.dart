
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';

import '../date_util.dart';
import '../models/task_item.dart';

class AddEditScreen extends StatefulWidget {
  final TaskItem? taskItem;
  final TaskItemRefresher? taskItemRefresher;
  final TaskHelper taskHelper;

  const AddEditScreen({
    Key? key,
    this.taskItem,
    this.taskItemRefresher,
    required this.taskHelper,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEditScreenState();
}

class AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TimezoneHelper timezoneHelper = TimezoneHelper();

  late List<String> possibleProjects;
  late List<String> possibleContexts;
  late List<String> possibleAnchorDates;
  late List<String> possibleRecurUnits;

  late bool _hasChanges;

  bool _repeatOn = false;
  bool _initialRepeatOn = false;

  late TaskItemBlueprint blueprint;

  @override
  void initState() {
    super.initState();

    _hasChanges = false;

    var taskItemTmp = widget.taskItem;

    blueprint = taskItemTmp == null ? TaskItemBlueprint() : taskItemTmp.createEditBlueprint();

    _initialRepeatOn = blueprint.isRecurring();
    _repeatOn = _initialRepeatOn;

    possibleProjects = [
      '(none)',
      'Career',
      'Hobby',
      'Friends',
      'Family',
      'Health',
      'Maintenance',
      'Organization',
      'Shopping',
      'Entertainment',
      'WIG Mentorship',
      'Writing',
      'Bugs',
      'Projects',
    ];

    possibleContexts = [
      '(none)',
      'Computer',
      'Home',
      'Office',
      'E-Mail',
      'Phone',
      'Outside',
      'Reading',
      'Planning',
    ];

    possibleAnchorDates = [
      '(none)',
      'Schedule Dates',
      'Completed Date',
    ];

    possibleRecurUnits = [
      '(none)',
      'Days',
      'Weeks',
      'Months',
      'Years',
    ];
  }

  bool get isEditing {
    return widget.taskItem != null;
  }

  DateTime getLocalDate(DateTime dateTime) {
    return timezoneHelper.getLocalTime(dateTime);
  }

  bool hasDate() {
    return
      blueprint.startDate != null ||
      blueprint.targetDate != null ||
      blueprint.urgentDate != null ||
      blueprint.dueDate != null;
  }

  bool? anchorDateToRecurWait(String anchorDate) {
    if (anchorDate == '(none)') {
      return null;
    } else {
      return anchorDate == 'Completed Date';
    }
  }

  String recurWaitToAnchorDate(bool? recurWait) {
    return (recurWait == null) ?
    '(none)' : !recurWait ? 'Schedule Dates' : 'Completed Date';
  }

  void clearRepeatOn() {
    _repeatOn = false;
  }

  @override
  Widget build(BuildContext context) {

    bool hasPassed(DateTime? dateTime) {
      return dateTime != null && dateTime.isBefore(DateTime.now());
    }

    DateTime? getLastDateBefore(TaskDateType taskDateType) {
      var allDates = <DateTime?>[blueprint.startDate, blueprint.targetDate, blueprint.urgentDate, blueprint.dueDate];
      var pastDates = allDates.whereType<DateTime>().where((dateTime) => hasPassed(dateTime));

      return pastDates.length == 0 ? null : DateUtil.maxDate(pastDates);
    }

    DateTime _getPreviousDateOrNow(TaskDateType taskDateType) {
      var lastDate = getLastDateBefore(taskDateType);
      return lastDate == null ? DateTime.now() : lastDate;
    }

    DateTime _getOnePastPreviousDateOrNow(TaskDateType taskDateType) {
      var lastDate = getLastDateBefore(taskDateType);
      return lastDate == null ? DateTime.now() : lastDate.add(Duration(days: 1));
    }

    String _getInputDisplay(dynamic value) {
      if (value == null) {
        return '';
      } else {
        return value.toString();
      }
    }

    String? _cleanString(String? str) {
      if (str == null) {
        return null;
      } else {
        var trimmed = str.trim();
        if (trimmed.isEmpty) {
          return null;
        } else {
          return trimmed;
        }
      }
    }

    int? _parseInt(String? str) {
      if (str == null) {
        return null;
      }
      var cleanString = _cleanString(str);
      return cleanString == null ? null : int.parse(str);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            setState(() {
              _hasChanges = true;
            });
          },
          child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  EditableTaskField(
                    initialText: blueprint.name,
                    labelText: 'Name',
                    fieldSetter: (value) => blueprint.name = value,
                    inputType: TextInputType.multiline,
                    isRequired: true,
                    wordCaps: true,
                  ),
                  NullableDropdown(
                    initialValue: blueprint.project,
                    labelText: 'Project',
                    possibleValues: possibleProjects,
                    valueSetter: (value) => blueprint.project = value,
                  ),
                  NullableDropdown(
                    initialValue: blueprint.context,
                    labelText: 'Context',
                    possibleValues: possibleContexts,
                    valueSetter: (value) => blueprint.context = value,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(blueprint.priority),
                          labelText: 'Priority',
                          fieldSetter: (value) => blueprint.priority = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(blueprint.gamePoints),
                          labelText: 'Points',
                          fieldSetter: (value) => blueprint.gamePoints = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(blueprint.duration),
                          labelText: 'Length',
                          fieldSetter: (value) => blueprint.duration = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  ClearableDateTimeField(
                    labelText: 'Start Date',
                    dateGetter: () {
                      return blueprint.startDate;
                    },
                    initialPickerGetter: () {
                      return DateTime.now();
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        blueprint.startDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                    timezoneHelper: timezoneHelper,
                  ),
                  ClearableDateTimeField(
                    labelText: 'Target Date',
                    dateGetter: () {
                      return blueprint.targetDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.target);
                    },
                    firstDateGetter: () {
                      return blueprint.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.target);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        blueprint.targetDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                    timezoneHelper: timezoneHelper,
                  ),
                  ClearableDateTimeField(
                    labelText: 'Urgent Date',
                    dateGetter: () {
                      return blueprint.urgentDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    firstDateGetter: () {
                      return blueprint.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        blueprint.urgentDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                    timezoneHelper: timezoneHelper,
                  ),
                  ClearableDateTimeField(
                    labelText: 'Due Date',
                    dateGetter: () {
                      return blueprint.dueDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.due);
                    },
                    firstDateGetter: () {
                      return blueprint.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.due);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        blueprint.dueDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                    timezoneHelper: timezoneHelper,
                  ),
                  Visibility(
                    visible: hasDate(),
                    child: Card(
                      elevation: 3.0,
                      color: TaskColors.cardColor,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                                      child: Text('Repeat',
                                        style: Theme.of(context).textTheme.subtitle1,),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Switch(
                                        value: _repeatOn,
                                        onChanged: (value) {
                                          setState(() {
                                            _repeatOn = value;
                                            print(_repeatOn);
                                          });
                                        },
                                        activeTrackColor: Colors.pinkAccent,
                                        activeColor: Colors.pink,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: _repeatOn,
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 80.0,
                                              child: EditableTaskField(
                                                initialText: _getInputDisplay(blueprint.recurNumber),
                                                labelText: 'Num',
                                                fieldSetter: (value) => blueprint.recurNumber = _parseInt(value),
                                                inputType: TextInputType.number,
                                                validator: (value) {
                                                  if (_repeatOn && value != null && value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: NullableDropdown(
                                            initialValue: blueprint.recurUnit,
                                            labelText: 'Unit',
                                            possibleValues: possibleRecurUnits,
                                            valueSetter: (value) => blueprint.recurUnit = value,
                                            validator: (value) {
                                              if (_repeatOn && value == '(none)') {
                                                return 'Unit is required for repeat.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    NullableDropdown(
                                      initialValue: recurWaitToAnchorDate(blueprint.recurWait),
                                      labelText: 'Anchor',
                                      possibleValues: possibleAnchorDates,
                                      valueSetter: (value) => blueprint.recurWait = anchorDateToRecurWait(value!),
                                      validator: (value) {
                                        if (_repeatOn && value == '(none)') {
                                          return 'Anchor Date is required for repeat.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                  EditableTaskField(
                    initialText: blueprint.description,
                    labelText: 'Notes',
                    fieldSetter: (value) => blueprint.description = value,
                    inputType: TextInputType.multiline,
                  ),
                ],
              )
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _hasChanges || (_initialRepeatOn && !_repeatOn),
        child: FloatingActionButton(
          child: Icon(isEditing ? Icons.check : Icons.add),
          onPressed: () async {
            final form = formKey.currentState;

            if (!_repeatOn) {
              blueprint.recurUnit = null;
              blueprint.recurNumber = null;
              blueprint.recurWait = null;
              blueprint.recurrenceId = null;
              blueprint.recurIteration = null;
            }

            if (form != null && form.validate()) {
              form.save();

              var tmpTaskItem = widget.taskItem;

              if (tmpTaskItem != null) {
                var editing = blueprint;
                var updatedItem = await widget.taskHelper.updateTask(tmpTaskItem, editing);
                var taskItemRefresher2 = widget.taskItemRefresher;
                if (taskItemRefresher2 != null) {
                  taskItemRefresher2(updatedItem);
                }
              } else {
                if (_repeatOn) {
                  blueprint.recurIteration = 1;

                  var recurrence = new TaskRecurrenceBlueprint();
                  recurrence.name = blueprint.name;
                  recurrence.recurUnit = blueprint.recurUnit;
                  recurrence.recurIteration = blueprint.recurIteration;
                  recurrence.recurNumber = blueprint.recurNumber;
                  recurrence.recurWait = blueprint.recurWait;
                  recurrence.anchorDate = blueprint.getAnchorDate();
                  recurrence.anchorType = blueprint.getAnchorDateType()!.label;

                  blueprint.taskRecurrenceBlueprint = recurrence;
                }
                await widget.taskHelper.addTask(blueprint);
              }

              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

}

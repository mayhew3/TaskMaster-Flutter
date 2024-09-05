
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/redux/actions/actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../../date_util.dart';
import '../../models/task_item.dart';
import '../../models/task_item_blueprint.dart';
import 'clearable_date_time_field.dart';
import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  final TaskItem? taskItem;
  final TimezoneHelper timezoneHelper;

  const AddEditScreen({
    Key? key,
    this.taskItem,
    required this.timezoneHelper,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEditScreenState();
}

class AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late BuiltList<String> possibleProjects;
  late BuiltList<String> possibleContexts;
  late BuiltList<String> possibleAnchorDates;
  late BuiltList<String> possibleRecurUnits;

  late bool _hasChanges;

  bool _repeatOn = false;
  bool _initialRepeatOn = false;

  late TaskItemBlueprint blueprint;
  late TaskItem? taskItem;

  @override
  void initState() {
    super.initState();

    _hasChanges = false;

    taskItem = widget.taskItem;
    // var taskRecurrence = taskItem?.taskRecurrencePreview;

    blueprint = taskItem == null ? TaskItemBlueprint() : taskItem!.createCreateBlueprint();
    // blueprint.taskRecurrenceBlueprint = taskItem == null || taskRecurrence == null ? TaskRecurrenceBlueprint() : taskRecurrence.createCreationBlueprint();

    _initialRepeatOn = taskItem?.recurrenceId != null;
    _repeatOn = _initialRepeatOn;

    possibleProjects = ListBuilder<String>([
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
    ]).build();

    possibleContexts = ListBuilder<String>([
      '(none)',
      'Computer',
      'Home',
      'Office',
      'E-Mail',
      'Phone',
      'Outside',
      'Reading',
      'Planning',
    ]).build();

    possibleAnchorDates = ListBuilder<String>([
      '(none)',
      'Schedule Dates',
      'Completed Date',
    ]).build();

    possibleRecurUnits = ListBuilder<String>([
      '(none)',
      'Days',
      'Weeks',
      'Months',
      'Years',
    ]).build();
  }

  bool get isEditing {
    return widget.taskItem != null;
  }

  DateTime getLocalDate(DateTime dateTime) {
    return widget.timezoneHelper.getLocalTime(dateTime);
  }

  bool hasDate() {
    return blueprint.getAnchorDate() != null;
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

    DateTime? getLastDateBefore(TaskDateType taskDateType) {
      var typesPreceding = TaskDateTypes.getTypesPreceding(taskDateType);
      var allDates = typesPreceding.map((type) => type.dateFieldGetter(blueprint)).whereType<DateTime>();

      return allDates.length == 0 ? null : DateUtil.maxDate(allDates);
    }

    // todo: write some tests
    DateTime _getPreviousDateOrNow(TaskDateType taskDateType) {
      var lastDate = getLastDateBefore(taskDateType);
      return lastDate == null ? DateTime.now() : lastDate;
    }

    // todo: write some tests
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

    void clearRecurrenceFieldsFromTask() {
      blueprint.recurUnit = null;
      blueprint.recurNumber = null;
      blueprint.recurWait = null;
      blueprint.recurrenceId = null;
      blueprint.recurIteration = null;
      // blueprint.taskRecurrenceBlueprint = null;
    }
/*

    void updateRecurrenceBlueprint() {
      var recurrenceBlueprint = blueprint.taskRecurrenceBlueprint;

      if (recurrenceBlueprint != null) {
        recurrenceBlueprint.name = blueprint.name;
        recurrenceBlueprint.recurUnit = blueprint.recurUnit;
        recurrenceBlueprint.recurIteration = blueprint.recurIteration;
        recurrenceBlueprint.recurNumber = blueprint.recurNumber;
        recurrenceBlueprint.recurWait = blueprint.recurWait;
        recurrenceBlueprint.anchorDate = blueprint.getAnchorDate();
        recurrenceBlueprint.anchorType = blueprint.getAnchorDateType()!.label;
      }
    }
*/

    bool editMode() {
      return taskItem != null;
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
                    timezoneHelper: widget.timezoneHelper,
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
                    timezoneHelper: widget.timezoneHelper,
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
                    timezoneHelper: widget.timezoneHelper,
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
                    timezoneHelper: widget.timezoneHelper,
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
                                        style: Theme.of(context).textTheme.titleMedium,),
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
                    fieldSetter: (value) => blueprint.description = value == null || value.isEmpty ? null : value,
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
                clearRecurrenceFieldsFromTask();
              }

              if (form != null && form.validate()) {
                form.save();

                if (_repeatOn) {
                  if (!_initialRepeatOn) {
                    blueprint.recurIteration = 1;
                  }
                  // updateRecurrenceBlueprint();
                }

                if (editMode()) {
                  StoreProvider.of<AppState>(context).dispatch(UpdateTaskItemAction(taskItem: taskItem!, blueprint: blueprint));
                } else { // add mode
                  StoreProvider.of<AppState>(context).dispatch(AddTaskItemAction(blueprint: blueprint));
                  // await widget.taskHelper.addTask(blueprint, (callback) => setState(() => callback()));
                }
              }

              Navigator.pop(context);
            }
        ),
      ),
    );
  }

}

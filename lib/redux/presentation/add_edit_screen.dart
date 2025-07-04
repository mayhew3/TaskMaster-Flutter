
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/add_edit_screen_viewmodel.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../../date_util.dart';
import '../../models/anchor_date.dart';
import '../../models/task_item.dart';
import '../../models/task_item_blueprint.dart';
import 'clearable_date_time_field.dart';
import 'editable_task_field.dart';
import 'nullable_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  final TaskItem? taskItem;
  final TimezoneHelper timezoneHelper;

  const AddEditScreen({
    super.key,
    this.taskItem,
    required this.timezoneHelper,
  });

  @override
  State<StatefulWidget> createState() => AddEditScreenState();
}

class AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late BuiltList<String> possibleProjects;
  late BuiltList<String> possibleContexts;
  late BuiltList<String> possibleAnchorDates;
  late BuiltList<String> possibleRecurUnits;

  bool _repeatOn = false;
  late final bool _initialRepeatOn;

  late TaskItemBlueprint taskItemBlueprint;
  late TaskItem? taskItem;

  TaskItemBlueprint blankBlueprint = TaskItemBlueprint();
  late TaskRecurrenceBlueprint taskRecurrenceBlueprint;

  bool popped = false;

  @override
  void initState() {
    super.initState();


    taskItem = widget.taskItem;
    // var taskRecurrence = taskItem?.taskRecurrencePreview;

    taskItemBlueprint = taskItem == null ? TaskItemBlueprint() : taskItem!.createBlueprint();
    var existingRecurrence = taskItem?.recurrence;
    taskRecurrenceBlueprint = (existingRecurrence == null) ? TaskRecurrenceBlueprint() : existingRecurrence.createBlueprint();

    _initialRepeatOn = taskItem?.recurrenceDocId != null;
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
    return taskItemBlueprint.getAnchorDate() != null;
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

  DateTime? getLastDateBefore(TaskDateType taskDateType) {
    var typesPreceding = TaskDateTypes.getTypesPreceding(taskDateType);
    var allDates = typesPreceding.map((type) => type.dateFieldGetter(taskItemBlueprint)).whereType<DateTime>();

    return allDates.isEmpty ? null : DateUtil.maxDate(allDates);
  }

  // todo: write some tests
  DateTime _getPreviousDateOrNow(TaskDateType taskDateType) {
    var lastDate = getLastDateBefore(taskDateType);
    return lastDate ?? DateTime.now();
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
    taskItemBlueprint.recurUnit = null;
    taskItemBlueprint.recurNumber = null;
    taskItemBlueprint.recurWait = null;
    taskItemBlueprint.recurIteration = null;
    taskItemBlueprint.recurrenceBlueprint = null;
    taskItemBlueprint.recurrenceDocId = null;
  }

  void updateRecurrenceBlueprint() {
    taskRecurrenceBlueprint.recurIteration = taskItemBlueprint.recurIteration;
    taskRecurrenceBlueprint.recurNumber = taskItemBlueprint.recurNumber;
    taskRecurrenceBlueprint.recurWait = taskItemBlueprint.recurWait;
    taskRecurrenceBlueprint.recurUnit = taskItemBlueprint.recurUnit;
    taskRecurrenceBlueprint.name = taskItemBlueprint.name;
    taskRecurrenceBlueprint.anchorDate = taskItemBlueprint.getAnchorDate();
    taskItemBlueprint.recurrenceBlueprint = taskRecurrenceBlueprint;
    taskItemBlueprint.recurrenceDocId = taskItem?.recurrence?.docId;
  }

  bool hasChanges() {
    if (editMode()) {
      return taskItemBlueprint.hasChanges(taskItem!);
    } else {
      return taskItemBlueprint.hasChangesBlueprint(blankBlueprint);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AddEditScreenViewModel>(
        onWillChange: (prev, current) {
          if (!popped) {
            if (editMode()) {
              var latestTask = taskItemSelector(
                  current.allTaskItems, taskItem!.docId);
              var latestRecurrence = taskRecurrenceSelector(
                  current.allTaskRecurrences, taskItem!.recurrence?.docId);
              var hasTaskChanges = latestTask != null &&
                  latestTask.hasChanges(taskItem!);
              var recurrenceAddedOrRemoved = prev != null &&
                  current.allTaskRecurrences.length !=
                      prev.allTaskRecurrences.length;
              var hasRecurrenceChanges = latestRecurrence != null &&
                  latestRecurrence.hasChanges(taskItem!.recurrence);
              if (hasTaskChanges || hasRecurrenceChanges ||
                  recurrenceAddedOrRemoved) {
                popped = true;
                Navigator.pop(context);
              }
            } else {
              if (prev != null &&
                  current.allTaskItems.length > prev.allTaskItems.length) {
                popped = true;
                Navigator.pop(context);
              }
            }
          }
        },
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Task Details'),
            ),
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: () {
                  setState(() {
                  });
                },
                child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        EditableTaskField(
                          initialText: taskItemBlueprint.name,
                          labelText: 'Name',
                          onChanged: (value) => taskItemBlueprint.name = value,
                          fieldSetter: (value) => taskItemBlueprint.name = value,
                          inputType: TextInputType.multiline,
                          isRequired: true,
                          wordCaps: true,
                        ),
                        NullableDropdown(
                          initialValue: taskItemBlueprint.project,
                          labelText: 'Project',
                          possibleValues: possibleProjects,
                          valueSetter: (value) => taskItemBlueprint.project = value,
                        ),
                        NullableDropdown(
                          initialValue: taskItemBlueprint.context,
                          labelText: 'Context',
                          possibleValues: possibleContexts,
                          valueSetter: (value) => taskItemBlueprint.context = value,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: EditableTaskField(
                                initialText: _getInputDisplay(taskItemBlueprint.priority),
                                labelText: 'Priority',
                                fieldSetter: (value) => taskItemBlueprint.priority = _parseInt(value),
                                inputType: TextInputType.number,
                              ),
                            ),
                            Expanded(
                              child: EditableTaskField(
                                initialText: _getInputDisplay(taskItemBlueprint.gamePoints),
                                labelText: 'Points',
                                fieldSetter: (value) => taskItemBlueprint.gamePoints = _parseInt(value),
                                inputType: TextInputType.number,
                              ),
                            ),
                            Expanded(
                              child: EditableTaskField(
                                initialText: _getInputDisplay(taskItemBlueprint.duration),
                                labelText: 'Length',
                                fieldSetter: (value) => taskItemBlueprint.duration = _parseInt(value),
                                inputType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        ClearableDateTimeField(
                          labelText: 'Start Date',
                          dateGetter: () {
                            return taskItemBlueprint.startDate;
                          },
                          initialPickerGetter: () {
                            return DateTime.now();
                          },
                          dateSetter: (DateTime? pickedDate) {
                            setState(() {
                              taskItemBlueprint.startDate = pickedDate;
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
                            return taskItemBlueprint.targetDate;
                          },
                          initialPickerGetter: () {
                            return _getOnePastPreviousDateOrNow(TaskDateTypes.target);
                          },
                          firstDateGetter: () {
                            return taskItemBlueprint.startDate;
                          },
                          currentDateGetter: () {
                            return _getPreviousDateOrNow(TaskDateTypes.target);
                          },
                          dateSetter: (DateTime? pickedDate) {
                            setState(() {
                              taskItemBlueprint.targetDate = pickedDate;
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
                            return taskItemBlueprint.urgentDate;
                          },
                          initialPickerGetter: () {
                            return _getOnePastPreviousDateOrNow(TaskDateTypes.urgent);
                          },
                          firstDateGetter: () {
                            return taskItemBlueprint.startDate;
                          },
                          currentDateGetter: () {
                            return _getPreviousDateOrNow(TaskDateTypes.urgent);
                          },
                          dateSetter: (DateTime? pickedDate) {
                            setState(() {
                              taskItemBlueprint.urgentDate = pickedDate;
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
                            return taskItemBlueprint.dueDate;
                          },
                          initialPickerGetter: () {
                            return _getOnePastPreviousDateOrNow(TaskDateTypes.due);
                          },
                          firstDateGetter: () {
                            return taskItemBlueprint.startDate;
                          },
                          currentDateGetter: () {
                            return _getPreviousDateOrNow(TaskDateTypes.due);
                          },
                          dateSetter: (DateTime? pickedDate) {
                            setState(() {
                              taskItemBlueprint.dueDate = pickedDate;
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
                                                      initialText: _getInputDisplay(taskItemBlueprint.recurNumber),
                                                      labelText: 'Num',
                                                      fieldSetter: (value) => taskItemBlueprint.recurNumber = _parseInt(value),
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
                                                  initialValue: taskItemBlueprint.recurUnit,
                                                  labelText: 'Unit',
                                                  possibleValues: possibleRecurUnits,
                                                  valueSetter: (value) => taskItemBlueprint.recurUnit = value,
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
                                            initialValue: recurWaitToAnchorDate(taskItemBlueprint.recurWait),
                                            labelText: 'Anchor',
                                            possibleValues: possibleAnchorDates,
                                            valueSetter: (value) => taskItemBlueprint.recurWait = anchorDateToRecurWait(value!),
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
                          initialText: taskItemBlueprint.description,
                          labelText: 'Notes',
                          onChanged: (value) => taskItemBlueprint.description = value == null || value.isEmpty ? null : value,
                          fieldSetter: (value) => taskItemBlueprint.description = value == null || value.isEmpty ? null : value,
                          inputType: TextInputType.multiline,
                        ),
                      ],
                    )
                ),
              ),
            ),
            floatingActionButton: Visibility(
              visible: hasChanges() || (_initialRepeatOn && !_repeatOn),
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
                          taskItemBlueprint.recurIteration = 1;
                        }
                        updateRecurrenceBlueprint();
                      }

                      if (editMode()) {
                        StoreProvider.of<AppState>(context).dispatch(UpdateTaskItemAction(taskItem: taskItem!, blueprint: taskItemBlueprint));
                      } else { // add mode
                        StoreProvider.of<AppState>(context).dispatch(AddTaskItemAction(blueprint: taskItemBlueprint));
                      }
                    }
                  }
              ),
            ),
          );
        },
        converter: AddEditScreenViewModel.fromStore
    );
  }

}

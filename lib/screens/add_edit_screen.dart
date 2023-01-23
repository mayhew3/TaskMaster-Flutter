
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskItemRefresher? taskItemRefresher;
  final TaskHelper taskHelper;
  final bool isEditing;

  const AddEditScreen({
    Key? key,
    required this.taskItem,
    this.taskItemRefresher,
    required this.taskHelper,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEditScreenState();
}

class AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late List<String> possibleProjects;
  late List<String> possibleContexts;
  late List<String> possibleAnchorDates;
  late List<String> possibleRecurUnits;

  late bool _hasChanges;

  bool _repeatOn = false;
  bool _initialRepeatOn = false;

  late TaskItemBlueprint fields;

  @override
  void initState() {
    super.initState();

    _hasChanges = false;

    fields = widget.isEditing ? widget.taskItem.createEditTemplate() : widget.taskItem.createBlueprint();

    _initialRepeatOn = fields.recurNumber != null;
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

  bool hasDate() {
    return
      fields.startDate != null ||
      fields.targetDate != null ||
      fields.urgentDate != null ||
      fields.dueDate != null;
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
      var allDates = [fields.startDate, fields.targetDate, fields.urgentDate, fields.dueDate];
      var pastDates = allDates.where((dateTime) => dateTime != null && hasPassed(dateTime));

      return pastDates.reduce((a, b) => a!.isAfter(b!) ? a : b);
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
                    initialText: fields.name,
                    labelText: 'Name',
                    fieldSetter: (value) => fields.name = value,
                    inputType: TextInputType.multiline,
                    isRequired: true,
                    wordCaps: true,
                  ),
                  NullableDropdown(
                    initialValue: fields.project,
                    labelText: 'Project',
                    possibleValues: possibleProjects,
                    valueSetter: (value) => fields.project = value,
                  ),
                  NullableDropdown(
                    initialValue: fields.context,
                    labelText: 'Context',
                    possibleValues: possibleContexts,
                    valueSetter: (value) => fields.context = value,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(fields.priority),
                          labelText: 'Priority',
                          fieldSetter: (value) => fields.priority = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(fields.gamePoints),
                          labelText: 'Points',
                          fieldSetter: (value) => fields.gamePoints = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: _getInputDisplay(fields.duration),
                          labelText: 'Length',
                          fieldSetter: (value) => fields.duration = _parseInt(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  ClearableDateTimeField(
                    labelText: 'Start Date',
                    dateGetter: () {
                      return fields.startDate;
                    },
                    initialPickerGetter: () {
                      return DateTime.now();
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        fields.startDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Target Date',
                    dateGetter: () {
                      return fields.targetDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.target);
                    },
                    firstDateGetter: () {
                      return fields.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.target);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        fields.targetDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Urgent Date',
                    dateGetter: () {
                      return fields.urgentDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    firstDateGetter: () {
                      return fields.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        fields.urgentDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Due Date',
                    dateGetter: () {
                      return fields.dueDate;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.due);
                    },
                    firstDateGetter: () {
                      return fields.startDate;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.due);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        fields.dueDate = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  Visibility(
                    visible: hasDate(),
                    child: Card(
                      elevation: 3.0,
                      color: Color.fromRGBO(76, 77, 105, 1.0),
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
                                                initialText: _getInputDisplay(fields.recurNumber),
                                                labelText: 'Num',
                                                fieldSetter: (value) => fields.recurNumber = _parseInt(value),
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
                                            initialValue: _getInputDisplay(fields.recurUnit),
                                            labelText: 'Unit',
                                            possibleValues: possibleRecurUnits,
                                            valueSetter: (value) => fields.recurUnit = value,
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
                                      initialValue: recurWaitToAnchorDate(fields.recurWait),
                                      labelText: 'Anchor',
                                      possibleValues: possibleAnchorDates,
                                      valueSetter: (value) => fields.recurWait = anchorDateToRecurWait(value!),
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
                    initialText: fields.description,
                    labelText: 'Notes',
                    fieldSetter: (value) => fields.description = value,
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
          child: Icon(widget.isEditing ? Icons.check : Icons.add),
          onPressed: () async {
            final form = formKey.currentState;

            if (!_repeatOn) {
              fields.recurUnit = null;
              fields.recurNumber = null;
              fields.recurWait = null;
              fields.recurrenceId = null;
              fields.recurIteration = null;
            }

            if (form != null && form.validate()) {
              form.save();

              if (widget.isEditing) {
                var editing = fields as TaskItemEdit;
                if (_repeatOn && editing.recurrenceId == null) {
                  editing.recurrenceId = editing.id;
                  editing.recurIteration = 1;
                }
                var updatedItem = await widget.taskHelper.updateTask(widget.taskItem, editing);
                var taskItemRefresher2 = widget.taskItemRefresher;
                if (taskItemRefresher2 != null) {
                  taskItemRefresher2(updatedItem);
                }
              } else {
                if (_repeatOn) {
                  fields.recurIteration = 1;
                }
                await widget.taskHelper.addTask(fields);
              }

              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

}

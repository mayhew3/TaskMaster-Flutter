
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
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

  @override
  void initState() {
    super.initState();

    _hasChanges = false;

    _initialRepeatOn = widget.taskItem.recurNumber.value != null;
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
      widget.taskItem.startDate.value != null ||
      widget.taskItem.targetDate.value != null ||
      widget.taskItem.urgentDate.value != null ||
      widget.taskItem.dueDate.value != null;
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

    DateTime _getPreviousDateOrNow(TaskDateType taskDateType) {
      var lastDate = widget.taskItem.getLastDateBefore(taskDateType);
      return lastDate == null ? DateTime.now() : lastDate;
    }

    DateTime _getOnePastPreviousDateOrNow(TaskDateType taskDateType) {
      var lastDate = widget.taskItem.getLastDateBefore(taskDateType);
      return lastDate == null ? DateTime.now() : lastDate.add(Duration(days: 1));
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
          onWillPop: () {
            return Future(() {
              widget.taskItem.revertAllChanges();
              return true;
            });
          },
          onChanged: () {
            setState(() {
              _hasChanges = true;
            });
          },
          child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  EditableTaskField(
                    initialText: widget.taskItem.name.value,
                    labelText: 'Name',
                    fieldSetter: (value) => widget.taskItem.name.setValueFromString(value),
                    inputType: TextInputType.multiline,
                    isRequired: true,
                    wordCaps: true,
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem.project.value,
                    labelText: 'Project',
                    possibleValues: possibleProjects,
                    valueSetter: (value) => widget.taskItem.project.setValueFromString(value),
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem.context.value,
                    labelText: 'Context',
                    possibleValues: possibleContexts,
                    valueSetter: (value) => widget.taskItem.context.setValueFromString(value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem.priority.getInputDisplay(),
                          labelText: 'Priority',
                          fieldSetter: (value) => widget.taskItem.priority.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem.gamePoints.getInputDisplay(),
                          labelText: 'Points',
                          fieldSetter: (value) => widget.taskItem.gamePoints.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem.duration.getInputDisplay(),
                          labelText: 'Length',
                          fieldSetter: (value) => widget.taskItem.duration.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  ClearableDateTimeField(
                    labelText: 'Start Date',
                    dateGetter: () {
                      return widget.taskItem.startDate.value;
                    },
                    initialPickerGetter: () {
                      return DateTime.now();
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        widget.taskItem.startDate.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Target Date',
                    dateGetter: () {
                      return widget.taskItem.targetDate.value;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.target);
                    },
                    firstDateGetter: () {
                      return widget.taskItem.startDate.value;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.target);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        widget.taskItem.targetDate.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Urgent Date',
                    dateGetter: () {
                      return widget.taskItem.urgentDate.value;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    firstDateGetter: () {
                      return widget.taskItem.startDate.value;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.urgent);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        widget.taskItem.urgentDate.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Due Date',
                    dateGetter: () {
                      return widget.taskItem.dueDate.value;
                    },
                    initialPickerGetter: () {
                      return _getOnePastPreviousDateOrNow(TaskDateTypes.due);
                    },
                    firstDateGetter: () {
                      return widget.taskItem.startDate.value;
                    },
                    currentDateGetter: () {
                      return _getPreviousDateOrNow(TaskDateTypes.due);
                    },
                    dateSetter: (DateTime? pickedDate) {
                      setState(() {
                        widget.taskItem.dueDate.value = pickedDate;
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
                                                initialText: widget.taskItem.recurNumber.getInputDisplay(),
                                                labelText: 'Num',
                                                fieldSetter: (value) => widget.taskItem.recurNumber.setValueFromString(value),
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
                                            initialValue: widget.taskItem.recurUnit.value,
                                            labelText: 'Unit',
                                            possibleValues: possibleRecurUnits,
                                            valueSetter: (value) => widget.taskItem.recurUnit.setValueFromString(value),
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
                                      initialValue: recurWaitToAnchorDate(widget.taskItem.recurWait.value),
                                      labelText: 'Anchor',
                                      possibleValues: possibleAnchorDates,
                                      valueSetter: (value) => widget.taskItem.recurWait.value = anchorDateToRecurWait(value!),
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
                    initialText: widget.taskItem.description.value,
                    labelText: 'Notes',
                    fieldSetter: (value) => widget.taskItem.description.value = value,
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
              widget.taskItem.recurUnit.value = null;
              widget.taskItem.recurNumber.value = null;
              widget.taskItem.recurWait.value = null;
              widget.taskItem.recurrenceId.value = null;
            }

            if (form != null && form.validate()) {
              form.save();

              if (widget.isEditing) {
                var updatedItem = await widget.taskHelper.updateTask(widget.taskItem);
                var taskItemRefresher2 = widget.taskItemRefresher;
                if (taskItemRefresher2 != null) {
                  taskItemRefresher2(updatedItem);
                }
              } else {
                await widget.taskHelper.addTask(widget.taskItem);
              }

              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

}

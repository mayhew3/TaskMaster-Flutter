
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';
import 'package:taskmaster/widgets/editable_task_field.dart';
import 'package:taskmaster/widgets/nullable_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskAdder taskAdder;
  final TaskUpdater taskUpdater;
  final TaskItemRefresher taskItemRefresher;

  const AddEditScreen({
    Key key,
    this.taskItem,
    this.taskAdder,
    this.taskUpdater,
    this.taskItemRefresher,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddEditScreenState();
}

class AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime _startDate;
  DateTime _targetDate;
  DateTime _dueDate;
  DateTime _urgentDate;

  List<String> possibleProjects;
  List<String> possibleContexts;
  List<String> possibleAnchorDates;
  List<String> possibleRecurUnits;

  bool _hasChanges;

  bool _repeatOn = false;
  bool _initialRepeatOn = false;

  String _anchorDate;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      assert(widget.taskUpdater != null);
    } else {
      assert(widget.taskAdder != null);
    }

    _hasChanges = false;

    _initialRepeatOn = widget.taskItem?.recurNumber != null;
    _repeatOn = _initialRepeatOn;

    _anchorDate = widget.taskItem?.recurWait == null ?
    '(none)' : !widget.taskItem.recurWait.value ? 'Schedule Dates' : 'Completed Date';

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
        _startDate != null ||
        _targetDate != null ||
        _urgentDate != null ||
        _dueDate != null;
  }

  void clearRepeatOn() {
    _repeatOn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          autovalidate: false,
          onWillPop: () {
            return Future(() => true);
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
                    initialText: widget.taskItem?.name?.value,
                    labelText: 'Name',
                    fieldSetter: (value) => widget.taskItem?.name?.setValueFromString(value),
                    inputType: TextInputType.multiline,
                    isRequired: true,
                    wordCaps: true,
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem?.project?.value,
                    labelText: 'Project',
                    possibleValues: possibleProjects,
                    valueSetter: (value) => widget.taskItem?.project?.setValueFromString(value),
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem?.context?.value,
                    labelText: 'Context',
                    possibleValues: possibleContexts,
                    valueSetter: (value) => widget.taskItem?.context?.setValueFromString(value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.urgency?.value.toString(),
                          labelText: 'Urgency',
                          fieldSetter: (value) => widget.taskItem?.urgency?.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.priority?.value.toString(),
                          labelText: 'Priority',
                          fieldSetter: (value) => widget.taskItem?.priority?.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.gamePoints?.value.toString(),
                          labelText: 'Points',
                          fieldSetter: (value) => widget.taskItem?.gamePoints?.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.duration?.value.toString(),
                          labelText: 'Length',
                          fieldSetter: (value) => widget.taskItem?.duration?.setValueFromString(value),
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  ClearableDateTimeField(
                    labelText: 'Start Date',
                    dateGetter: () {
                      return widget.taskItem?.startDate?.value;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        widget.taskItem?.startDate?.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Target Date',
                    dateGetter: () {
                      return widget.taskItem?.targetDate?.value;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        widget.taskItem?.targetDate?.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Due Date',
                    dateGetter: () {
                      return widget.taskItem?.dueDate?.value;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        widget.taskItem?.dueDate?.value = pickedDate;
                        if (!hasDate()) {
                          clearRepeatOn();
                        }
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Urgent Date',
                    dateGetter: () {
                      return widget.taskItem?.urgentDate?.value;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        widget.taskItem?.urgentDate?.value = pickedDate;
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
                                        style: Theme.of(context).textTheme.subhead,),
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
                                                initialText: widget.taskItem?.recurNumber?.value.toString(),
                                                labelText: 'Num',
                                                fieldSetter: (value) => widget.taskItem?.recurNumber?.setValueFromString(value),
                                                inputType: TextInputType.number,
                                                validator: (value) {
                                                  if (_repeatOn && value.isEmpty) {
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
                                            initialValue: widget.taskItem?.recurUnit?.value,
                                            labelText: 'Unit',
                                            possibleValues: possibleRecurUnits,
                                            valueSetter: (value) => widget.taskItem?.recurUnit?.setValueFromString(value),
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
                                      initialValue: _anchorDate,
                                      labelText: 'Anchor',
                                      possibleValues: possibleAnchorDates,
                                      valueSetter: (newValue) => _anchorDate = newValue,
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
                    initialText: widget.taskItem?.description?.value,
                    labelText: 'Notes',
                    fieldSetter: (value) => widget.taskItem?.description?.value = value,
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
            if (form.validate()) {
              form.save();

              if (isEditing) {
                var updatedItem = await widget.taskUpdater(widget.taskItem);
                if (widget.taskItemRefresher != null) {
                  widget.taskItemRefresher(updatedItem);
                }
              } else {
                await widget.taskAdder(widget.taskItem);
              }

              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  bool get isEditing => widget.taskItem != null;
}

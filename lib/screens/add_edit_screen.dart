
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

  String _name;
  String _description;
  String _project;
  String _context;

  String _urgency;
  String _priority;
  String _duration;

  DateTime _startDate;
  DateTime _targetDate;
  DateTime _dueDate;
  DateTime _urgentDate;

  String _gamePoints;

  String _recurNumber;
  String _recurUnit;

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

    _startDate = widget.taskItem?.startDate;
    _targetDate = widget.taskItem?.targetDate;
    _dueDate = widget.taskItem?.dueDate;
    _urgentDate = widget.taskItem?.urgentDate;

    _project = widget.taskItem?.project;
    _context = widget.taskItem?.context;

    _recurUnit = widget.taskItem?.recurUnit;

    _hasChanges = false;

    _initialRepeatOn = widget.taskItem?.recurNumber != null;
    _repeatOn = _initialRepeatOn;

    _anchorDate = widget.taskItem?.recurWait == null ?
    '(none)' : !widget.taskItem.recurWait ? 'Schedule Dates' : 'Completed Date';

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
                    initialText: widget.taskItem?.name,
                    labelText: 'Name',
                    fieldSetter: (value) => _name = value,
                    inputType: TextInputType.multiline,
                    isRequired: true,
                    wordCaps: true,
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem?.project,
                    labelText: 'Project',
                    possibleValues: possibleProjects,
                    valueSetter: (newValue) => _project = newValue,
                  ),
                  NullableDropdown(
                    initialValue: widget.taskItem?.context,
                    labelText: 'Context',
                    possibleValues: possibleContexts,
                    valueSetter: (newValue) => _context = newValue,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.urgency?.toString(),
                          labelText: 'Urgency',
                          fieldSetter: (value) => _urgency = value,
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.priority?.toString(),
                          labelText: 'Priority',
                          fieldSetter: (value) => _priority = value,
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.gamePoints?.toString(),
                          labelText: 'Points',
                          fieldSetter: (value) => _gamePoints = value,
                          inputType: TextInputType.number,
                        ),
                      ),
                      Expanded(
                        child: EditableTaskField(
                          initialText: widget.taskItem?.duration?.toString(),
                          labelText: 'Length',
                          fieldSetter: (value) => _duration = value,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  ClearableDateTimeField(
                    labelText: 'Start Date',
                    dateGetter: () {
                      return _startDate;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Target Date',
                    dateGetter: () {
                      return _targetDate;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        _targetDate = pickedDate;
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Due Date',
                    dateGetter: () {
                      return _dueDate;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        _dueDate = pickedDate;
                      });
                    },
                  ),
                  ClearableDateTimeField(
                    labelText: 'Urgent Date',
                    dateGetter: () {
                      return _urgentDate;
                    },
                    dateSetter: (DateTime pickedDate) {
                      setState(() {
                        _urgentDate = pickedDate;
                      });
                    },
                  ),
                  Card(
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
                                              initialText: widget.taskItem?.recurNumber?.toString(),
                                              labelText: 'Num',
                                              fieldSetter: (value) => _recurNumber = value,
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
                                          initialValue: widget.taskItem?.recurUnit,
                                          labelText: 'Unit',
                                          possibleValues: possibleRecurUnits,
                                          valueSetter: (newValue) => _recurUnit = newValue,
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
                  EditableTaskField(
                    initialText: widget.taskItem?.description,
                    labelText: 'Notes',
                    fieldSetter: (value) => _description = value,
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
                var updatedItem = await widget.taskUpdater(
                  taskItem: widget.taskItem,
                  name: _name,
                  description: _description,
                  project: _project,
                  context: _context,
                  urgency: _urgency == null || _urgency == '' ? 3 : num.parse(_urgency),
                  priority: _priority == null || _priority == '' ? 5 : num.parse(_priority),
                  duration: _duration == null || _duration == '' ? null : num.parse(_duration),
                  startDate: _startDate,
                  targetDate: _targetDate,
                  dueDate: _dueDate,
                  urgentDate: _urgentDate,
                  gamePoints: _gamePoints == null || _gamePoints == '' ? 1 : num.parse(_gamePoints),
                  recurNumber: !_repeatOn || _recurNumber == null || _recurNumber == '' ? null : num.parse(_recurNumber),
                  recurUnit: _repeatOn ? _recurUnit : null,
                  recurWait: !_repeatOn || _anchorDate == '(none)' ? null : (_anchorDate != 'Schedule Dates'),
                );
                if (widget.taskItemRefresher != null) {
                  widget.taskItemRefresher(updatedItem);
                }
              } else {
                var addedItem = TaskItem(
                  name: _name,
                  description: _description,
                  project: _project,
                  context: _context,
                  urgency: _urgency == null || _urgency == '' ? 3 : num.parse(_urgency),
                  priority: _priority == null || _priority == '' ? 5 : num.parse(_priority),
                  duration: _duration == null || _duration == '' ? null : num.parse(_duration),
                  startDate: _startDate,
                  targetDate: _targetDate,
                  dueDate: _dueDate,
                  urgentDate: _urgentDate,
                  gamePoints: _gamePoints == null || _gamePoints == '' ? 1 : num.parse(_gamePoints),
                  recurNumber: !_repeatOn || _recurNumber == null || _recurNumber == '' ? null : num.parse(_recurNumber),
                  recurUnit: _repeatOn ? _recurUnit : null,
                  recurWait: !_repeatOn || _anchorDate == '(none)' ? null : (_anchorDate != 'Schedule Dates'),
                );
                await widget.taskAdder(addedItem);
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

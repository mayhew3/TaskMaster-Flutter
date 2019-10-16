
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';

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

  int _recurNumber;
  String _recurUnit;
  bool _recurWait;

  List<String> possibleProjects;
  List<String> possibleContexts;

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

    _project = widget.taskItem == null ? '(none)' : wrapNullValue(widget.taskItem.project);
    _context = widget.taskItem == null ? '(none)' : wrapNullValue(widget.taskItem.context);

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
  }

  String wrapNullValue(String value) {
    return value ?? '(none)';
  }

  String unwrapNullValue(String value) {
    return value == '(none)' ? null : value;
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
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: null,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      filled: false,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.taskItem?.name,
                    onSaved: (value) => _name = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: DropdownButton<String>(
                    value: _project,
                    onChanged: (String newValue) {
                      setState(() {
                        _project = newValue;
                      });
                    },
                    items: possibleProjects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: DropdownButton<String>(
                    value: _context,
                    onChanged: (String newValue) {
                      setState(() {
                        _context = newValue;
                      });
                    },
                    items: possibleContexts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(7.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Urgency',
                            filled: false,
                            border: OutlineInputBorder(),
                          ),
                          initialValue: widget.taskItem?.urgency?.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _urgency = value,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(7.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            filled: false,
                            border: OutlineInputBorder(),
                          ),
                          initialValue: widget.taskItem?.priority?.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _priority = value,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(7.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Points',
                            filled: false,
                            border: OutlineInputBorder(),
                          ),
                          initialValue: widget.taskItem?.gamePoints?.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _gamePoints = value,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(7.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Length',
                            filled: false,
                            border: OutlineInputBorder(),
                          ),
                          initialValue: widget.taskItem?.duration?.toString(),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _duration = value,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: ClearableDateTimeField(
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
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: ClearableDateTimeField(
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
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: ClearableDateTimeField(
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
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: ClearableDateTimeField(
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
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      filled: false,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.taskItem?.description,
                    onSaved: (value) => _description = value,
                  ),
                ),

              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                  project: unwrapNullValue(_project),
                  context: unwrapNullValue(_context),
                  urgency: _urgency == null || _urgency == '' ? 3 : num.parse(_urgency),
                  priority: _priority == null || _priority == '' ? 5 : num.parse(_priority),
                  duration: _duration == null || _duration == '' ? null : num.parse(_duration),
                  startDate: _startDate,
                  targetDate: _targetDate,
                  dueDate: _dueDate,
                  urgentDate: _urgentDate,
                  gamePoints: _gamePoints == null || _gamePoints == '' ? 1 : num.parse(_gamePoints),
                  recurNumber: _recurNumber,
                  recurUnit: _recurUnit,
                  recurWait: _recurWait
              );
              if (widget.taskItemRefresher != null) {
                widget.taskItemRefresher(updatedItem);
              }
            } else {
              var addedItem = TaskItem(
                  name: _name,
                  description: _description,
                  project: unwrapNullValue(_project),
                  context: unwrapNullValue(_context),
                  urgency: _urgency == null || _urgency == '' ? 3 : num.parse(_urgency),
                  priority: _priority == null || _priority == '' ? 5 : num.parse(_priority),
                  duration: _duration == null || _duration == '' ? null : num.parse(_duration),
                  startDate: _startDate,
                  targetDate: _targetDate,
                  dueDate: _dueDate,
                  urgentDate: _urgentDate,
                  gamePoints: _gamePoints == null || _gamePoints == '' ? 1 : num.parse(_gamePoints),
                  recurNumber: _recurNumber,
                  recurUnit: _recurUnit,
                  recurWait: _recurWait
              );
              await widget.taskAdder(addedItem);
            }

            Navigator.pop(context);
          }
        },
      ),
    );
  }

  bool get isEditing => widget.taskItem != null;
}

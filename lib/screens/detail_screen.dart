
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';

class DetailScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskAdder taskAdder;
  final TaskUpdater taskUpdater;

  const DetailScreen({
    Key key,
    this.taskItem,
    this.taskAdder,
    this.taskUpdater,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
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
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      filled: false,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.taskItem?.project,
                    onSaved: (value) => _project = value,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Context',
                      filled: false,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.taskItem?.context,
                    onSaved: (value) => _context = value,
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
              await widget.taskUpdater(
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
                  recurNumber: _recurNumber,
                  recurUnit: _recurUnit,
                  recurWait: _recurWait
              );
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

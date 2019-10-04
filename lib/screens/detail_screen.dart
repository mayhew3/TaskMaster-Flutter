
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';

import 'package:taskmaster/widgets/date_time_picker.dart';

class DetailScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskUpdater taskUpdater;

  const DetailScreen({
    Key key,
    @required this.taskItem,
    @required this.taskUpdater,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailScreenState();
}

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atSeven = new DateTime(now.year, now.month, now.day, 19);
  return atSeven.add(new Duration(days: days));
}

class DetailScreenState extends State<DetailScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _name;
  String _description;
  DateTime _startDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: formKey,
            autovalidate: false,
            onWillPop: () {
              return Future(() => true);
            },
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.taskItem != null ? widget.taskItem.name : '',
                  style: Theme.of(context).textTheme.display1,
                  onSaved: (value) => _name = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.taskItem != null ? widget.taskItem.description : '',
                  style: Theme.of(context).textTheme.display1,
                  onSaved: (value) => _description = value,
                ),
                DateTimePicker(
                  labelText: 'Start',
                  defaultDate: daysFromNow(7),
                  dateGetter: () {
                    if (_startDate == null) {
                      _startDate = widget.taskItem.startDate;
                    }
                    return _startDate;
                  },
                  dateSetter: (DateTime pickedDate) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  },
                ),
                Text(
                  widget.taskItem.dateAdded.toString(),
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          final form = formKey.currentState;
          if (form.validate()) {
            form.save();

            final name = _name;
            final description = _description;
            final startDate = _startDate;

            widget.taskUpdater(widget.taskItem, name, description, startDate);

            Navigator.pop(context);
          }
        },
      ),
    );
  }

  bool get isEditing => widget.taskItem != null;
}
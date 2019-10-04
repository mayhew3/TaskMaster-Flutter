
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/clearable_date_time_field.dart';

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

class DetailScreenState extends State<DetailScreen> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _name;
  String _description;
  DateTime _startDate;
  DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.taskItem.startDate;
    _targetDate = widget.taskItem.targetDate;
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
            child: Column(
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
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(7.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      filled: false,
                      border: OutlineInputBorder(),
                    ),
                    initialValue: widget.taskItem?.description,
                    onSaved: (value) => _description = value,
                  ),
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
            final targetDate = _targetDate;

            widget.taskUpdater(widget.taskItem, name, description, startDate, targetDate);

            Navigator.pop(context);
          }
        },
      ),
    );
  }

  bool get isEditing => widget.taskItem != null;
}

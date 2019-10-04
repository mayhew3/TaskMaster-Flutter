
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
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
  DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _targetDate = widget.taskItem.targetDate;
  }

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
                  initialValue: widget.taskItem?.name,
                  onSaved: (value) => _name = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.taskItem?.description,
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
                BasicDateTimeField(
                  labelText: 'Target',
                  dateGetter: () {
                    return _targetDate;
                  },
                  dateSetter: (DateTime pickedDate) {
                    setState(() {
                      _targetDate = pickedDate;
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

final longDateFormat = DateFormat.yMMMMd().add_jm();

class BasicDateTimeField extends StatelessWidget {
  const BasicDateTimeField({
    Key key,
    this.labelText,
    this.dateGetter,
    this.dateSetter,
  }) : super(key: key);

  final String labelText;
  final ValueGetter<DateTime> dateGetter;
  final ValueChanged<DateTime> dateSetter;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      child: DateTimeField(
        format: longDateFormat,
        initialValue: dateGetter(),
        onChanged: (pickedDate) => dateSetter(pickedDate),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? daysFromNow(7),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? daysFromNow(7)),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    );
  }
}
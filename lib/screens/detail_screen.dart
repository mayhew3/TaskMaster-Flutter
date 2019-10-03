
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';

import 'package:taskmaster/widgets/date_time_picker.dart';

class DetailScreen extends StatefulWidget {
  final TaskItem taskItem;

  const DetailScreen({
    Key key,
    @required this.taskItem
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {

  DateTime combineDateWithTime(DateTime originalDate, int hour, int minute) {
    return new DateTime(originalDate.year, originalDate.month, originalDate.day,
        hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.taskItem.name,
                  style: Theme.of(context).textTheme.display1,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: widget.taskItem.description,
                  style: Theme.of(context).textTheme.display1,
                ),
                DateTimePicker(
                  labelText: 'Start',
                  initialDate: DateTime.now(),
                  selectedDate: widget.taskItem.startDate,
                  selectedTime: widget.taskItem.startDate == null ? null :
                    TimeOfDay(hour: widget.taskItem.startDate.hour,
                              minute: widget.taskItem.startDate.minute),
                  selectDate: (DateTime date) {
                    setState(() {
                      var originalDate = widget.taskItem.startDate;
                      widget.taskItem.startDate = originalDate == null ? date :
                        combineDateWithTime(date, originalDate.hour, originalDate.minute);
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      var originalDate = widget.taskItem.startDate;
                      widget.taskItem.startDate = originalDate == null ?
                      combineDateWithTime(DateTime.now(), time.hour, time.minute) :
                      combineDateWithTime(originalDate, time.hour, time.minute);
                    });
                  },
                ),
                Text(
                  widget.taskItem.dateAdded.toString(),
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            )
        )
    );
  }

}
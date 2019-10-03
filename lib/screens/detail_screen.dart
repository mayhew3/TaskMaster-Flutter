
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

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atSeven = new DateTime(now.year, now.month, now.day, 19);
  return atSeven.add(new Duration(days: days));
}

class DetailScreenState extends State<DetailScreen> {

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
                  defaultDate: daysFromNow(7),
                  objectDate: widget.taskItem.startDate,
                  dateSetter: (DateTime pickedDate) {
                    setState(() {
                      widget.taskItem.startDate = pickedDate;
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
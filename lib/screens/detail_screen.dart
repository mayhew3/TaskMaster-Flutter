
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

}

class DetailScreenState extends State<DetailScreen> {

  final TaskItem taskItem;
  
  const DetailScreenState({
    Key key, 
    @required this.taskItem
  }) : super(key: key);
  
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
                  initialValue: taskItem.name,
                  style: Theme.of(context).textTheme.display1,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                  initialValue: taskItem.description,
                  style: Theme.of(context).textTheme.display1,
                ),
                DateTimePicker(
                  labelText: 'Start',
                  selectedDate: taskItem.startDate,
                  selectedTime: taskItem.startDate == null ? null : TimeOfDay(hour: taskItem.startDate.hour, minute: taskItem.startDate.minute),
                  selectDate: (DateTime date) {
                    setState(() {
                      _fromDate = date;
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      _fromTime = time;
                    });
                  },
                ),
                Text(
                  taskItem.dateAdded.toString(),
                  style: Theme.of(context).textTheme.subhead,
                ),
              ],
            )
        )
    );
  }

}
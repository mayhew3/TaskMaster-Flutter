
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/widgets/readonly_task_field.dart';
import 'package:taskmaster/widgets/readonly_task_field_small.dart';
import 'package:timeago/timeago.dart' as timeago;

final longDateFormat = DateFormat.yMMMMd().add_jm();

class DetailScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;

  const DetailScreen({
    Key key,
    this.taskItem,
    this.taskAdder,
    this.taskUpdater,
    this.taskCompleter,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailScreenState();
  }

}

class DetailScreenState extends State<DetailScreen> {

  bool completed;

  @override
  void initState() {
    super.initState();
    completed = (widget.taskItem.completionDate != null);
  }

  String formatDateTime(DateTime dateTime) {
    return dateTime == null ? '' : timeago.format(dateTime, allowFromNow: true);
  }

  String formatNumber(num number) {
    return number == null ? '' : number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(widget.taskItem.name,
                      style: Theme.of(context).textTheme.headline,
                    )
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Checkbox(
                    value: completed,
                    onChanged: (complete) async {
                      await widget.taskCompleter(widget.taskItem, complete);
                      setState(() {
                        completed = complete;
                      });
                    },
                  ),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Project',
              textToShow: widget.taskItem.project,
            ),
            ReadOnlyTaskField(
              headerName: 'Context',
              textToShow: widget.taskItem.context,
            ),
            ReadOnlyTaskField(
              headerName: 'Start',
              textToShow: formatDateTime(widget.taskItem.startDate),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ReadOnlyTaskFieldSmall(
                  headerName: 'Urgency',
                  textToShow: formatNumber(widget.taskItem.urgency),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Priority',
                  textToShow: formatNumber(widget.taskItem.priority),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Points',
                  textToShow: formatNumber(widget.taskItem.gamePoints),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Length',
                  textToShow: formatNumber(widget.taskItem.duration),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: formatDateTime(widget.taskItem.urgentDate),
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: formatDateTime(widget.taskItem.targetDate),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: formatDateTime(widget.taskItem.dueDate),
            ),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: widget.taskItem.description,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Edit',
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddEditScreen(
                  taskUpdater: widget.taskUpdater,
                  taskAdder: widget.taskAdder,
                  taskItem: widget.taskItem,
                );
              },
            ),
          );
        },
      ),
    );
  }

}
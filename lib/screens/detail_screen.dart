
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/typedefs.dart';
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
    return DetailScreenState(taskItem);
  }

}

class DetailScreenState extends State<DetailScreen> {

  bool completed;
  TaskItem taskItem;

  DetailScreenState(TaskItem taskItem) {
    this.taskItem = taskItem;
  }

  @override
  void initState() {
    super.initState();
    completed = (taskItem.completionDate != null);
  }

  String formatDateTime(DateTime dateTime) {
    return dateTime == null ? '' : timeago.format(dateTime, allowFromNow: true);
  }

  String formatNumber(num number) {
    return number == null ? '' : number.toString();
  }

  Color getUrgentBackgroundColor() {
    var urgent = hasPassed(taskItem.urgentDate);
    return urgent ? TaskColors.urgentColor : TaskColors.cardColor;
  }

  Color getDueBackgroundColor() {
    var due = hasPassed(taskItem.dueDate);
    return due ? TaskColors.dueColor : TaskColors.cardColor;
  }

  Color getCompletedBackgroundColor() {
    var completed = hasPassed(taskItem.completionDate);
    return completed ? TaskColors.completedColor : TaskColors.cardColor;
  }

  void refreshLocalTaskItem(TaskItem taskItem) {
    setState(() {
      this.taskItem = taskItem;
      completed = (taskItem.completionDate != null);
    });
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
                Expanded(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(taskItem.name,
                        style: Theme.of(context).textTheme.headline,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Checkbox(
                    value: completed,
                    onChanged: (complete) async {
                      var updatedTask = await widget.taskCompleter(taskItem, complete);
                      refreshLocalTaskItem(updatedTask);
                    },
                  ),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Project',
              textToShow: taskItem.project,
            ),
            ReadOnlyTaskField(
              headerName: 'Context',
              textToShow: taskItem.context,
            ),
            ReadOnlyTaskField(
              headerName: 'Start',
              textToShow: formatDateTime(taskItem.startDate),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ReadOnlyTaskFieldSmall(
                  headerName: 'Urgency',
                  textToShow: formatNumber(taskItem.urgency),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Priority',
                  textToShow: formatNumber(taskItem.priority),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Points',
                  textToShow: formatNumber(taskItem.gamePoints),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Length',
                  textToShow: formatNumber(taskItem.duration),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: formatDateTime(taskItem.urgentDate),
              optionalBackgroundColor: getUrgentBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: formatDateTime(taskItem.targetDate),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: formatDateTime(taskItem.dueDate),
              optionalBackgroundColor: getDueBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Completed',
              textToShow: formatDateTime(taskItem.completionDate),
              optionalBackgroundColor: getCompletedBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Repeat',
              textToShow: taskItem.recurNumber == null ? null :
                        'Every ' + taskItem.recurNumber.toString() + ' ' + taskItem.recurUnit,
            ),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: taskItem.description,
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
                  taskItem: taskItem,
                  taskItemRefresher: refreshLocalTaskItem,
                );
              },
            ),
          );
        },
      ),
    );
  }

}
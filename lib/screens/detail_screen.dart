
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/pending_checkbox.dart';
import 'package:taskmaster/widgets/readonly_task_field.dart';
import 'package:taskmaster/widgets/readonly_task_field_small.dart';
import 'package:timeago/timeago.dart' as timeago;

final longDateFormat = DateFormat.yMMMMd().add_jm();

class DetailScreen extends StatefulWidget {
  final TaskItem taskItem;
  final TaskHelper taskHelper;

  const DetailScreen({
    Key key,
    this.taskItem,
    @required this.taskHelper,
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
    completed = (taskItem.completionDate.value != null);
  }

  String formatDateTime(DateTime dateTime) {
    return dateTime == null ? '' : timeago.format(dateTime, allowFromNow: true);
  }

  String formatNumber(num number) {
    return number == null ? '' : number.toString();
  }

  Color getUrgentBackgroundColor() {
    var urgent = taskItem.urgentDate.hasPassed();
    return urgent ? TaskColors.urgentColor : TaskColors.cardColor;
  }

  Color getDueBackgroundColor() {
    var due = taskItem.dueDate.hasPassed();
    return due ? TaskColors.dueColor : TaskColors.cardColor;
  }

  Color getCompletedBackgroundColor() {
    var completed = taskItem.completionDate.hasPassed();
    return completed ? TaskColors.completedColor : TaskColors.cardColor;
  }

  void refreshLocalTaskItem(TaskItem taskItem) {
    setState(() {
      this.taskItem = taskItem;
      completed = (taskItem.completionDate.value != null);
    });
  }

  String getFormattedRecurrence(TaskItem taskItem) {
    return 'Every ' + taskItem.recurNumber.value.toString() + ' ' + getFormattedRecurUnit(taskItem) + (taskItem.recurWait.value ? ' (after completion)' : '');
  }

  String getFormattedRecurUnit(TaskItem taskItem) {
    if (taskItem?.recurUnit?.value == null) {
      return '';
    }
    var unit = taskItem?.recurUnit?.value;
    if (taskItem.recurNumber.value == 1) {
      unit = unit.substring(0, unit.length-1);
    }
    return unit.toLowerCase();
  }

  Future<TaskItem> toggleAndUpdateCompleted(TaskItem taskItem, bool complete) async {
    var future = await widget.taskHelper.completeTask(taskItem, complete, (callback) => setState(() => callback()));
    setState(() {});
    return future;
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
                      child: Text(taskItem.name.value,
                        style: Theme.of(context).textTheme.headline,
                      )
                  ),
                ),
                Visibility(
                  visible: !taskItem.pendingCompletion,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: DelayedCheckbox(
                      initialState: completed ? CheckState.checked : CheckState.inactive,
                      checkCycleWaiter: (checkState) async {
                        var updatedTask = await toggleAndUpdateCompleted(taskItem, CheckState.inactive == checkState);
                        refreshLocalTaskItem(updatedTask);
                        return updatedTask.isCompleted() ? CheckState.checked : CheckState.inactive;
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: taskItem.pendingCompletion,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: PendingCheckbox(),
                  ),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Project',
              textToShow: taskItem.project.value,
            ),
            ReadOnlyTaskField(
              headerName: 'Context',
              textToShow: taskItem.context.value,
            ),
            ReadOnlyTaskField(
              headerName: 'Start',
              textToShow: formatDateTime(taskItem.startDate.value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ReadOnlyTaskFieldSmall(
                  headerName: 'Urgency',
                  textToShow: formatNumber(taskItem.urgency.value),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Priority',
                  textToShow: formatNumber(taskItem.priority.value),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Points',
                  textToShow: formatNumber(taskItem.gamePoints.value),
                ),
                ReadOnlyTaskFieldSmall(
                  headerName: 'Length',
                  textToShow: formatNumber(taskItem.duration.value),
                ),
              ],
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: formatDateTime(taskItem.urgentDate.value),
              optionalBackgroundColor: getUrgentBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: formatDateTime(taskItem.targetDate.value),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: formatDateTime(taskItem.dueDate.value),
              optionalBackgroundColor: getDueBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Completed',
              textToShow: formatDateTime(taskItem.getFinishedCompletionDate()),
              optionalBackgroundColor: getCompletedBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Repeat',
              textToShow: taskItem.recurNumber.value == null ? null :
                        getFormattedRecurrence(taskItem),
            ),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: taskItem.description.value,
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
                  taskItem: taskItem,
                  taskItemRefresher: refreshLocalTaskItem,
                  taskHelper: widget.taskHelper,
                  isEditing: true,
                );
              },
            ),
          );
        },
      ),
    );
  }

}
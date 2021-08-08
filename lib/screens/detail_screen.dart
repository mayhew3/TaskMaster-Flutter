
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/add_edit_screen.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:taskmaster/widgets/readonly_task_field.dart';
import 'package:taskmaster/widgets/readonly_task_field_small.dart';
import 'package:timeago/timeago.dart' as timeago;

final longDateFormat = DateFormat.yMMMMd().add_jm();

class DetailScreen extends StatefulWidget {
  final TaskItem/*!*/ taskItem;
  final TaskHelper/*!*/ taskHelper;

  const DetailScreen({
    Key key,
    this.taskItem,
    required this.taskHelper,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailScreenState(taskItem);
  }

}

class DetailScreenState extends State<DetailScreen> {

  bool completed;
  TaskItem/*!*/ taskItem;

  DetailScreenState(TaskItem/*!*/ taskItem) {
    this.taskItem = taskItem;
  }

  @override
  void initState() {
    super.initState();
    completed = (taskItem.completionDate.value != null);
  }

  String formatDateTime(DateTime dateTime) {
    if (dateTime == null) {
      return '';
    }
    var jiffy = Jiffy(dateTime);
    var isToday = jiffy.yMMMd == Jiffy().yMMMd;
    var isThisYear = jiffy.year == Jiffy().year;
    var jiffyTime = jiffy.format("h:mm a");
    var jiffyDate = isThisYear ? jiffy.format("MMMM do") : jiffy.format("MMMM do, yyyy");
    var formattedDate = isToday ?
        jiffyTime + ' today' :
        jiffyDate;
    return formattedDate;
  }

  String _getFormattedAgo(DateTime dateTime) {
    if (dateTime == null) {
      return null;
    }
    return "(" + timeago.format(dateTime, allowFromNow: true) + ")";
  }

  String formatNumber(num number) {
    return number == null ? '' : number.toString();
  }

  Color getStartTextColor() {
    var start = taskItem.startDate.hasPassed();
    return start ? Colors.white : TaskColors.scheduledText;
  }

  Color getStartOutlineColor() {
    var start = taskItem.startDate.hasPassed();
    return start ? null : TaskColors.scheduledOutline;
  }

  Color getStartBackgroundColor() {
    var start = taskItem.startDate.hasPassed();
    return start ? TaskColors.cardColor : TaskColors.scheduledColor;
  }

  Color getTargetBackgroundColor() {
    var target = taskItem.targetDate.hasPassed();
    return target ? TaskColors.targetColor : TaskColors.cardColor;
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
                        style: Theme.of(context).textTheme.headline5,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: DelayedCheckbox(
                    initialState: completed ? CheckState.checked : CheckState.inactive,
                    stateSetter: (callback) => setState(() => callback()),
                    checkCycleWaiter: (checkState) async {
                      var updatedTask = await toggleAndUpdateCompleted(taskItem, CheckState.inactive == checkState);
                      refreshLocalTaskItem(updatedTask);
                      return updatedTask.isCompleted() ? CheckState.checked : CheckState.inactive;
                    },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
              headerName: 'Start',
              textToShow: formatDateTime(taskItem.startDate.value),
              optionalSubText: _getFormattedAgo(taskItem.startDate.value),
              optionalTextColor: getStartTextColor(),
              optionalOutlineColor: getStartOutlineColor(),
              optionalBackgroundColor: getStartBackgroundColor(),
              hasShadow: false,
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: formatDateTime(taskItem.targetDate.value),
              optionalSubText: _getFormattedAgo(taskItem.targetDate.value),
              optionalTextColor: TaskDateTypes.target.textColor,
              optionalBackgroundColor: getTargetBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: formatDateTime(taskItem.urgentDate.value),
              optionalSubText: _getFormattedAgo(taskItem.urgentDate.value),
              optionalTextColor: TaskDateTypes.urgent.textColor,
              optionalBackgroundColor: getUrgentBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: formatDateTime(taskItem.dueDate.value),
              optionalSubText: _getFormattedAgo(taskItem.dueDate.value),
              optionalTextColor: TaskDateTypes.due.textColor,
              optionalBackgroundColor: getDueBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Completed',
              textToShow: formatDateTime(taskItem.getFinishedCompletionDate()),
              optionalSubText: _getFormattedAgo(taskItem.getFinishedCompletionDate()),
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
// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:taskmaster/redux/presentation/readonly_task_field.dart';
import 'package:taskmaster/redux/presentation/readonly_task_field_small.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:taskmaster/typedefs.dart';

import '../../keys.dart';
import '../../models/models.dart';
import '../../models/task_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jiffy/jiffy.dart';

import '../../models/task_date_type.dart';
import 'delayed_checkbox.dart';

class DetailsScreen extends StatelessWidget {
  final TaskItem taskItem;
  final Function onDelete;
  final CheckCycleWaiter toggleCompleted;
  final TimezoneHelper timezoneHelper;

  DetailsScreen({
    Key? key,
    required this.taskItem,
    required this.onDelete,
    required this.toggleCompleted,
    required this.timezoneHelper,
  }) : super(key: key ?? TaskMasterKeys.taskItemDetailsScreen);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Task Item Details"),
        actions: [
          IconButton(
            tooltip: "Delete Task Item",
            key: TaskMasterKeys.deleteTaskItemButton,
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context, taskItem);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: DelayedCheckbox(
                    taskName: taskItem.name,
                    initialState: taskItem.isCompleted() ? CheckState.checked : taskItem.pendingCompletion ? CheckState.pending : CheckState.inactive,
                    checkCycleWaiter: toggleCompleted,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
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
              headerName: 'Start',
              textToShow: formatDateTime(taskItem.startDate),
              optionalSubText: _getFormattedAgo(taskItem.startDate),
              optionalTextColor: getStartTextColor(),
              optionalOutlineColor: getStartOutlineColor(),
              optionalBackgroundColor: getStartBackgroundColor(),
              hasShadow: false,
            ),
            ReadOnlyTaskField(
              headerName: 'Target',
              textToShow: formatDateTime(taskItem.targetDate),
              optionalSubText: _getFormattedAgo(taskItem.targetDate),
              optionalTextColor: TaskDateTypes.target.textColor,
              optionalBackgroundColor: getTargetBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Urgent',
              textToShow: formatDateTime(taskItem.urgentDate),
              optionalSubText: _getFormattedAgo(taskItem.urgentDate),
              optionalTextColor: TaskDateTypes.urgent.textColor,
              optionalBackgroundColor: getUrgentBackgroundColor(),
            ),
            ReadOnlyTaskField(
              headerName: 'Due',
              textToShow: formatDateTime(taskItem.dueDate),
              optionalSubText: _getFormattedAgo(taskItem.dueDate),
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
              textToShow: taskItem.recurNumber == null ? null :
              getFormattedRecurrence(taskItem),
            ),
            ReadOnlyTaskField(
              headerName: 'Notes',
              textToShow: taskItem.description,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: TaskMasterKeys.editTaskItemFab,
        tooltip: "Edit Task Item",
        child: Icon(Icons.edit),
        onPressed: () {},
      ),
    );
  }


  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    var localTime = timezoneHelper.getLocalTime(dateTime);
    var jiffy = Jiffy(localTime);
    var isToday = jiffy.yMMMd == Jiffy().yMMMd;
    var isThisYear = jiffy.year == Jiffy().year;
    var jiffyTime = jiffy.format("h:mm a");
    var jiffyDate = isThisYear ? jiffy.format("MMMM do") : jiffy.format("MMMM do, yyyy");
    var formattedDate = isToday ?
    jiffyTime + ' today' :
    jiffyDate;
    return formattedDate;
  }

  String? _getFormattedAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return "(" + timeago.format(dateTime, allowFromNow: true) + ")";
  }

  String formatNumber(num? number) {
    return number == null ? '' : number.toString();
  }

  bool hasPassed(DateTime? dateTime) {
    return dateTime != null && dateTime.isBefore(DateTime.timestamp());
  }

  Color getStartTextColor() {
    var start = hasPassed(taskItem.startDate);
    return start ? Colors.white : TaskColors.scheduledText;
  }

  Color? getStartOutlineColor() {
    var start = hasPassed(taskItem.startDate);
    return start ? null : TaskColors.scheduledOutline;
  }

  Color getStartBackgroundColor() {
    var start = hasPassed(taskItem.startDate);
    return start ? TaskColors.cardColor : TaskColors.scheduledColor;
  }

  Color getTargetBackgroundColor() {
    var target = hasPassed(taskItem.targetDate);
    return target ? TaskColors.targetColor : TaskColors.cardColor;
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

  String getFormattedRecurrence(TaskItem taskItem) {
    var recurNumber = taskItem.recurNumber;
    var recurWait = taskItem.recurWait;
    if (recurNumber == null || recurWait == null) {
      return 'No recurrence.';
    }
    return 'Every ' + recurNumber.toString() + ' ' + getFormattedRecurUnit(taskItem) + (recurWait ? ' (after completion)' : '');
  }

  String getFormattedRecurUnit(TaskItem taskItem) {
    String? unit = taskItem.recurUnit;
    if (unit == null) {
      return '';
    }
    if (taskItem.recurNumber == 1) {
      unit = unit.substring(0, unit.length-1);
    }
    return unit.toLowerCase();
  }

}

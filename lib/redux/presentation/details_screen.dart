import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jiffy/jiffy.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/add_edit_screen.dart';
import 'package:taskmaster/redux/presentation/details_screen_viewmodel.dart';
import 'package:taskmaster/redux/presentation/readonly_task_field.dart';
import 'package:taskmaster/redux/presentation/readonly_task_field_small.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../keys.dart';
import '../../models/models.dart';
import '../../models/task_colors.dart';
import '../../models/task_date_type.dart';
import '../actions/task_item_actions.dart';
import '../selectors/selectors.dart';
import 'delayed_checkbox.dart';

class DetailsScreen extends StatelessWidget {
  final TaskItem taskItem;
  late final TaskRecurrence? taskRecurrence;

  DetailsScreen({
    Key? key,
    required this.taskItem,
  }) : super(key: key ?? TaskMasterKeys.taskItemDetailsScreen);

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (context, viewModel) {
          var recurrences = StoreProvider.of<AppState>(context).state.taskRecurrences;
          taskRecurrence = recurrenceForTaskItem(recurrences, taskItem);
          return Scaffold(
            appBar: AppBar(
              title: Text("Task Item Details"),
              actions: [
                IconButton(
                  tooltip: "Delete Task Item",
                  key: TaskMasterKeys.deleteTaskItemButton,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    StoreProvider.of<AppState>(context).dispatch(DeleteTaskItemAction(taskItem.id));
                    // todo: wait until action is completed
                    Navigator.pop(context, taskItem);
                  },
                )
              ],
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
                              style: Theme.of(context).textTheme.headlineSmall,
                            )
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: DelayedCheckbox(
                          taskName: taskItem.name,
                          initialState: taskItem.isCompleted() ? CheckState.checked : taskItem.pendingCompletion ? CheckState.pending : CheckState.inactive,
                          checkCycleWaiter: (checkState) {
                            StoreProvider.of<AppState>(context).dispatch(CompleteTaskItemAction(taskItem, CheckState.inactive == checkState));
                            return null;
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
                    textToShow: formatDateTime(taskItem.startDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.startDate),
                    optionalTextColor: getStartTextColor(),
                    optionalOutlineColor: getStartOutlineColor(),
                    optionalBackgroundColor: getStartBackgroundColor(),
                    hasShadow: false,
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Target',
                    textToShow: formatDateTime(taskItem.targetDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.targetDate),
                    optionalTextColor: TaskDateTypes.target.textColor,
                    optionalBackgroundColor: getTargetBackgroundColor(),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Urgent',
                    textToShow: formatDateTime(taskItem.urgentDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.urgentDate),
                    optionalTextColor: TaskDateTypes.urgent.textColor,
                    optionalBackgroundColor: getUrgentBackgroundColor(),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Due',
                    textToShow: formatDateTime(taskItem.dueDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.dueDate),
                    optionalTextColor: TaskDateTypes.due.textColor,
                    optionalBackgroundColor: getDueBackgroundColor(),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Completed',
                    textToShow: formatDateTime(taskItem.getFinishedCompletionDate(), viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.getFinishedCompletionDate()),
                    optionalBackgroundColor: getCompletedBackgroundColor(),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Repeat',
                    textToShow: getFormattedRecurrence(),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AddEditScreen(
                        taskItem: taskItem,
                        timezoneHelper: viewModel.timezoneHelper,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        converter: DetailsScreenViewModel.fromStore
    );

  }


  String formatDateTime(DateTime? dateTime, TimezoneHelper timezoneHelper) {
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

  String getFormattedRecurrence() {
    var recurrence = this.taskRecurrence;
    if (recurrence == null) {
      return 'No recurrence.';
    }
    var recurNumber = recurrence.recurNumber;
    var recurWait = recurrence.recurWait;
    return 'Every ' + recurNumber.toString() + ' ' + getFormattedRecurUnit(recurrence) + (recurWait ? ' (after completion)' : '');
  }

  String getFormattedRecurUnit(TaskRecurrence taskRecurrence) {
    String? unit = taskRecurrence.recurUnit;
    if (taskRecurrence.recurNumber == 1) {
      unit = unit.substring(0, unit.length-1);
    }
    return unit.toLowerCase();
  }

}

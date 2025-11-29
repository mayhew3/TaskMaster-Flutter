import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:jiffy/jiffy.dart';
import 'package:redux/redux.dart';
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
import '../../models/check_state.dart';
import '../actions/task_item_actions.dart';
import 'delayed_checkbox.dart';

class DetailsScreen extends StatelessWidget {
  final String taskItemId;

  const DetailsScreen({
    Key? key,
    required this.taskItemId,
  }) : super(key: key ?? TaskMasterKeys.taskItemDetailsScreen);

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (context, viewModel) {
          var taskItem = viewModel.taskItem;
          return Scaffold(
            appBar: AppBar(
              title: Text('Task Item Details'),
              actions: [
                IconButton(
                  tooltip: 'Delete Task Item',
                  key: TaskMasterKeys.deleteTaskItemButton,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    StoreProvider.of<AppState>(context).dispatch(DeleteTaskItemAction(taskItem));
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
                    optionalTextColor: getStartTextColor(taskItem),
                    optionalOutlineColor: getStartOutlineColor(taskItem),
                    optionalBackgroundColor: getStartBackgroundColor(taskItem),
                    hasShadow: false,
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Target',
                    textToShow: formatDateTime(taskItem.targetDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.targetDate),
                    optionalTextColor: TaskDateTypes.target.textColor,
                    optionalBackgroundColor: getTargetBackgroundColor(taskItem),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Urgent',
                    textToShow: formatDateTime(taskItem.urgentDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.urgentDate),
                    optionalTextColor: TaskDateTypes.urgent.textColor,
                    optionalBackgroundColor: getUrgentBackgroundColor(taskItem),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Due',
                    textToShow: formatDateTime(taskItem.dueDate, viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.dueDate),
                    optionalTextColor: TaskDateTypes.due.textColor,
                    optionalBackgroundColor: getDueBackgroundColor(taskItem),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Completed',
                    textToShow: formatDateTime(taskItem.getFinishedCompletionDate(), viewModel.timezoneHelper),
                    optionalSubText: _getFormattedAgo(taskItem.getFinishedCompletionDate()),
                    optionalBackgroundColor: getCompletedBackgroundColor(taskItem),
                  ),
                  ReadOnlyTaskField(
                    headerName: 'Repeat',
                    textToShow: getFormattedRecurrence(taskItem),
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
              tooltip: 'Edit Task Item',
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
        converter: (Store<AppState> store) {
          return DetailsScreenViewModel.fromStore(store, taskItemId);
        },
    );

  }


  String formatDateTime(DateTime? dateTime, TimezoneHelper timezoneHelper) {
    if (dateTime == null) {
      return '';
    }
    var localTime = timezoneHelper.getLocalTime(dateTime);
    var jiffy = Jiffy.parseFromDateTime(localTime);
    var isToday = jiffy.yMMMd == Jiffy.now().yMMMd;
    var isThisYear = jiffy.year == Jiffy.now().year;
    var jiffyTime = jiffy.format(pattern: 'h:mm a');
    var jiffyDate = isThisYear ? jiffy.format(pattern: 'MMMM do') : jiffy.format(pattern: 'MMMM do, yyyy');
    var formattedDate = isToday ?
    '$jiffyTime today' :
    jiffyDate;
    return formattedDate;
  }

  String? _getFormattedAgo(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return '(${timeago.format(dateTime, allowFromNow: true)})';
  }

  String formatNumber(num? number) {
    return number == null ? '' : number.toString();
  }

  bool hasPassed(DateTime? dateTime) {
    return dateTime != null && dateTime.isBefore(DateTime.timestamp());
  }

  Color getStartTextColor(TaskItem taskItem) {
    var start = hasPassed(taskItem.startDate);
    return start ? Colors.white : TaskColors.scheduledText;
  }

  Color? getStartOutlineColor(TaskItem taskItem) {
    var start = hasPassed(taskItem.startDate);
    return start ? null : TaskColors.scheduledOutline;
  }

  Color getStartBackgroundColor(TaskItem taskItem) {
    var start = hasPassed(taskItem.startDate);
    return start ? TaskColors.cardColor : TaskColors.scheduledColor;
  }

  Color getTargetBackgroundColor(TaskItem taskItem) {
    var target = hasPassed(taskItem.targetDate);
    return target ? TaskColors.targetColor : TaskColors.cardColor;
  }

  Color getUrgentBackgroundColor(TaskItem taskItem) {
    var urgent = hasPassed(taskItem.urgentDate);
    return urgent ? TaskColors.urgentColor : TaskColors.cardColor;
  }

  Color getDueBackgroundColor(TaskItem taskItem) {
    var due = hasPassed(taskItem.dueDate);
    return due ? TaskColors.dueColor : TaskColors.cardColor;
  }

  Color getCompletedBackgroundColor(TaskItem taskItem) {
    var completed = hasPassed(taskItem.completionDate);
    return completed ? TaskColors.completedColor : TaskColors.cardColor;
  }

  String getFormattedRecurrence(TaskItem taskItem) {
    var recurrence = taskItem.recurrence;
    if (recurrence == null) {
      return 'No recurrence.';
    }
    var recurNumber = recurrence.recurNumber;
    var recurWait = recurrence.recurWait;
    return 'Every $recurNumber ${getFormattedRecurUnit(recurrence)}${recurWait ? ' (after completion)' : ''}';
  }

  String getFormattedRecurUnit(TaskRecurrence taskRecurrence) {
    String? unit = taskRecurrence.recurUnit;
    if (taskRecurrence.recurNumber == 1) {
      unit = unit.substring(0, unit.length-1);
    }
    return unit.toLowerCase();
  }

}

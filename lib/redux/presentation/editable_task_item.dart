import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/sprint.dart';
import '../../models/task_item.dart';
import '../../typedefs.dart';
import 'delayed_checkbox.dart';

class EditableTaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;
  final GestureTapCallback? onTap;
  final CheckCycleWaiter? onTaskCompleteToggle;
  final ConfirmDismissCallback? onDismissed;
  final GestureLongPressCallback? onLongPress;
  final GestureForcePressStartCallback? onForcePress;
  final CheckState? initialCheckState;
  final Sprint? sprint;
  final bool highlightSprint;

  EditableTaskItemWidget({
    Key? key,
    required this.taskItem,
    this.sprint,
    required this.highlightSprint,
    this.onTaskCompleteToggle,
    this.onTap,
    this.initialCheckState,
    this.onDismissed,
    this.onLongPress,
    this.onForcePress,
  }) : super(key: key);

  bool hasPassed(DateTime? dateTime) {
    return dateTime == null ? false : dateTime.isBefore(DateTime.timestamp());
  }

  Color getBackgroundColor() {
    var pending = taskItem.pendingCompletion;
    var due = hasPassed(taskItem.dueDate);
    var urgent = hasPassed(taskItem.urgentDate);
    var target = hasPassed(taskItem.targetDate);
    var scheduled = taskItem.isScheduled();

    var tmpTaskItem = taskItem;
    var completed = tmpTaskItem.completionDate != null;

    if (pending) {
      return TaskColors.pendingBackground;
    } else if (completed) {
      return TaskColors.completedColor;
    } else if (due) {
      return TaskColors.dueColor;
    } else if (urgent) {
      return TaskColors.urgentColor;
    } else if (target) {
      return TaskColors.targetColor;
    } else if (scheduled) {
      return TaskColors.scheduledColor;
    } else {
      return TaskColors.cardColor;
    }
  }

  String getStringForDateType(TaskDateType taskDateType) {
    DateTime? dateValue = taskDateType.dateFieldGetter(taskItem);
    bool isPast = dateValue == null ? false : dateValue.isBefore(DateTime.now());
    String formatted = formatDateTime(dateValue);
    String label = taskDateType.label;

    if (dateValue == null) {
      return '';
    } else if ('now' == formatted) {
      return label + ' just now';
    } else if (isPast) {
      return label + ' ' + formatted + ' ago';
    } else {
      return label + ' in ' + formatted;
    }
  }

  String getDueDateString() {
    var dueDate = taskItem.dueDate;
    if (dueDate == null) {
      return '';
    } else if (taskItem.isPastDue()) {
      return 'Due ' + formatDateTime(dueDate) + ' ago';
    } else {
      return 'Due in ' + formatDateTime(dueDate);
    }
  }

  String formatDateTime(DateTime? dateTime) {
    var preliminaryString = dateTime == null ? '' : timeago.format(
        dateTime,
        locale: 'en_short',
        allowFromNow: true
    );
    return preliminaryString.replaceAll(' ', '').replaceAll('~', '');
  }

  bool dueInThreshold(int thresholdDays) {
    DateTime inXDays = DateTime.timestamp().add(Duration(days: thresholdDays));
    var dueDate = taskItem.dueDate;
    return dueDate != null && dueDate.isBefore(inXDays);
  }

  bool dateInFutureThreshold(TaskDateType taskDateType, int thresholdDays) {
    DateTime inXDays = DateTime.timestamp().add(Duration(days: thresholdDays));
    var dateField = taskDateType.dateFieldGetter(taskItem);
    var dateValue = dateField;
    return dateValue != null &&
        dateValue.isAfter(DateTime.now()) &&
        dateValue.isBefore(inXDays);
  }

  DelayedCheckbox _getCheckbox() {
    var tmpTaskItem = taskItem;
    var completed = tmpTaskItem.completionDate != null;

    var pending = tmpTaskItem.pendingCompletion;

    return DelayedCheckbox(
      taskName: taskItem.name,
      initialState: completed ? CheckState.checked : pending ? CheckState.pending : CheckState.inactive,
      checkCycleWaiter: onTaskCompleteToggle!,
    );
  }

  Widget _getDateWarnings() {
    List<Widget> dateWarnings = [];

    if (taskItem.isCompleted() && !taskItem.pendingCompletion) {
      dateWarnings.add(_getDateFromNow(TaskDateTypes.completed));
    }

    for (TaskDateType taskDateType in TaskDateTypes.allTypes) {
      if (!taskItem.isCompleted() &&
          taskDateType.inListBeforeDisplayThreshold(taskItem) &&
          dateWarnings.length < 1) {
        dateWarnings.add(_getDateFromNow(taskDateType));
      }
    }

    for (TaskDateType taskDateType in TaskDateTypes.allTypes.reversed) {
      if (!taskItem.isCompleted() &&
          taskDateType.inListAfterDisplayThreshold(taskItem) &&
          TaskDateTypes.start != taskDateType &&
          dateWarnings.length < 1) {
        dateWarnings.add(_getDateFromNow(taskDateType));
      }
    }

    return Column(
        children: dateWarnings
    );
  }

  Widget _getDateFromNow(TaskDateType taskDateType) {
    return Container(
      padding: EdgeInsets.only(
        top: 5.0,
        bottom: 5.0,
        right: 5.0,
        left: 5.0,
      ),
      child: Text(
        getStringForDateType(taskDateType),
        style: TextStyle(fontSize: 14.0, color: taskDateType.textColor),
      ),
    );
  }

  ShapeBorder _getBorder() {
    if  (highlightSprint) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: TaskColors.sprintColor,
          width: 1.0,
        ),
      );
    } else if (taskItem.isScheduled()) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
        side: BorderSide(
          color: TaskColors.scheduledOutline,
          width: 1.0,
        ),
      );
    } else {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      );
    }
  }

  TextStyle _getHeaderStyle() {
    if (taskItem.isScheduled()) {
      return TextStyle(
        fontSize: 17.0,
        color: TaskColors.scheduledText,
      );
    } else {
      return const TextStyle(fontSize: 17.0);
    }
  }

  Color _getShadowColor() {
    if (taskItem.isScheduled()) {
      // no shadow for scheduled task, by using 0 alpha
      return TaskColors.invisible;
    } else {
      return Colors.black;
    }
  }

  String getKey() {
    return taskItem.docId;
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: TaskMasterKeys.taskItem(getKey()),
      confirmDismiss: onDismissed,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onForcePressStart: (ForcePressDetails forcePressDetails) {
          print('Force Press detected!');
          if (onForcePress != null) {
            onForcePress!(forcePressDetails);
          }
        },
        child: Card(
          shadowColor: _getShadowColor(),
          color: getBackgroundColor(),
          shape: _getBorder(),
          elevation: 3.0,
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                )
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            taskItem.name,
                            style: _getHeaderStyle(),
                        ),
                        Visibility(
                          visible: taskItem.project != null,
                          child: Text(
                            taskItem.project == null ? '' : taskItem.project!,
                            style: const TextStyle(fontSize: 12.0,
                                color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _getDateWarnings(),
                Visibility(
                    visible: highlightSprint,
                    child: Icon(Icons.assignment, color: TaskColors.sprintColor),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 4.0,
                    bottom: 4.0,
                    right: 6.0,
                    left: 4.0,
                  ),
                  child: _getCheckbox(),
                )
              ],
            ),
          ),
        ),
      ),

    );

  }


}
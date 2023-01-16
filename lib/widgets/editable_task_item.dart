import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:timeago/timeago.dart' as timeago;

class EditableTaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;
  final GestureTapCallback? onTap;
  final CheckCycleWaiter? onTaskCompleteToggle;
  final CheckCycleWaiter? onTaskAssignmentToggle;
  final ConfirmDismissCallback? onDismissed;
  final GestureLongPressCallback? onLongPress;
  final GestureForcePressStartCallback? onForcePress;
  final bool addMode;
  final MyStateSetter stateSetter;
  final DateTime? endDate;
  final CheckState? initialCheckState;
  final Sprint? sprint;
  final bool highlightSprint;

  EditableTaskItemWidget({
    Key? key,
    required this.taskItem,
    this.onTap,
    this.onTaskCompleteToggle,
    this.onTaskAssignmentToggle,
    this.onDismissed,
    this.onLongPress,
    this.onForcePress,
    required this.addMode,
    required this.stateSetter,
    this.endDate,
    this.initialCheckState,
    required this.sprint,
    this.highlightSprint = false,
  }) : super(key: key);

  bool hasPassed(DateTime? dateTime) {
    var now = addMode ? this.endDate! : DateTime.now();
    return dateTime == null ? false : dateTime.isBefore(now);
  }

  Color getBackgroundColor() {
    var pending = taskItem.pendingCompletion;
    var due = hasPassed(taskItem.dueDate);
    var urgent = hasPassed(taskItem.urgentDate);
    var target = hasPassed(taskItem.targetDate);
    var scheduled = taskItem.isScheduled();
    var completed = taskItem.completionDate != null;

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
    DateTime inXDays = DateTime.now().add(Duration(days: thresholdDays));
    var dueDate = taskItem.dueDate;
    return dueDate != null && dueDate.isBefore(inXDays);
  }

  bool dateInFutureThreshold(TaskDateType taskDateType, int thresholdDays) {
    DateTime inXDays = DateTime.now().add(Duration(days: thresholdDays));
    var dateField = taskDateType.dateFieldGetter(taskItem);
    var dateValue = dateField;
    return dateValue != null &&
        dateValue.isAfter(DateTime.now()) &&
        dateValue.isBefore(inXDays);
  }

  DelayedCheckbox _getCheckbox() {
    if (addMode) {
      return DelayedCheckbox(
        initialState: initialCheckState!,
        stateSetter: stateSetter,
        checkCycleWaiter: onTaskAssignmentToggle!,
        checkedColor: Colors.green,
        inactiveIcon: Icons.add,
      );
    } else {
      var completed = taskItem.completionDate != null;

      return DelayedCheckbox(
        initialState: completed ? CheckState.checked : CheckState.inactive,
        stateSetter: stateSetter,
        checkCycleWaiter: onTaskCompleteToggle!,
      );
    }
  }

  bool showTarget(TaskDateType taskDateType) {
    return sprint == null || !(TaskDateTypes.target == taskDateType);
  }

  Widget _getDateWarnings() {
    List<Widget> dateWarnings = [];

    if (addMode) {
      var reversed = [
        TaskDateTypes.due,
        TaskDateTypes.urgent,
        TaskDateTypes.target,
        TaskDateTypes.start,
      ];

      for (TaskDateType taskDateType in reversed) {
        var dateValue = taskDateType.dateFieldGetter(taskItem);
        if (!taskItem.isCompleted() &&
            hasPassed(dateValue) &&
            dateValue != null &&
            dateValue.isAfter(DateTime.now()) &&
            dateWarnings.length < 1) {
          dateWarnings.add(_getDateFromNow(taskDateType));
        }
      }

    } else {
      if (taskItem.isCompleted() && !taskItem.pendingCompletion) {
        dateWarnings.add(_getDateFromNow(TaskDateTypes.completed));
      }

      for (TaskDateType taskDateType in TaskDateTypes.allTypes) {
        if (!taskItem.isCompleted() &&
            taskDateType.inListBeforeDisplayThreshold(taskItem) &&
            showTarget(taskDateType) &&
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
      return Color.fromRGBO(0, 0, 0, 0.0);
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.id.toString()),
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
                            taskItem.name!,
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
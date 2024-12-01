import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/sprint.dart';
import '../../models/sprint_display_task.dart';
import '../../typedefs.dart';
import 'delayed_checkbox.dart';

class PlanTaskItemWidget extends StatelessWidget {
  final SprintDisplayTask sprintDisplayTask;
  final CheckCycleWaiter? onTaskCompleteToggle;
  final CheckCycleWaiter? onTaskAssignmentToggle;
  // final MyStateSetter stateSetter;
  final DateTime? endDate;
  final CheckState? initialCheckState;
  final Sprint? sprint;
  final bool highlightSprint;

  const PlanTaskItemWidget({
    super.key,
    required this.sprintDisplayTask,
    this.endDate,
    this.sprint,
    required this.highlightSprint,
    this.onTaskCompleteToggle,
    this.onTaskAssignmentToggle,
    this.initialCheckState,
  });

  bool hasPassed(DateTime? dateTime) {
    return dateTime == null ? false : dateTime.isBefore(endDate!);
  }

  Color getBackgroundColor() {
    var due = hasPassed(sprintDisplayTask.dueDate);
    var urgent = hasPassed(sprintDisplayTask.urgentDate);
    var target = hasPassed(sprintDisplayTask.targetDate);
    var scheduled = sprintDisplayTask.isScheduled();

    if (due) {
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
    DateTime? dateValue = taskDateType.dateFieldGetter(sprintDisplayTask);
    bool isPast = dateValue == null ? false : dateValue.isBefore(DateTime.now());
    String formatted = formatDateTime(dateValue);
    String label = taskDateType.label;

    if (dateValue == null) {
      return '';
    } else if ('now' == formatted) {
      return '$label just now';
    } else if (isPast) {
      return '$label $formatted ago';
    } else {
      return '$label in $formatted';
    }
  }

  String getDueDateString() {
    var dueDate = sprintDisplayTask.dueDate;
    if (dueDate == null) {
      return '';
    } else if (sprintDisplayTask.isPastDue()) {
      return 'Due ${formatDateTime(dueDate)} ago';
    } else {
      return 'Due in ${formatDateTime(dueDate)}';
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
    var dueDate = sprintDisplayTask.dueDate;
    return dueDate != null && dueDate.isBefore(inXDays);
  }

  bool dateInFutureThreshold(TaskDateType taskDateType, int thresholdDays) {
    DateTime inXDays = DateTime.timestamp().add(Duration(days: thresholdDays));
    var dateField = taskDateType.dateFieldGetter(sprintDisplayTask);
    var dateValue = dateField;
    return dateValue != null &&
        dateValue.isAfter(DateTime.now()) &&
        dateValue.isBefore(inXDays);
  }

  DelayedCheckbox _getCheckbox() {
    return DelayedCheckbox(
      taskName: sprintDisplayTask.name,
      initialState: initialCheckState!,
      checkCycleWaiter: onTaskAssignmentToggle!,
      checkedColor: Colors.green,
      inactiveIcon: Icons.add,
    );
  }

  Widget _getDateWarnings() {
    List<Widget> dateWarnings = [];

    var reversed = [
      TaskDateTypes.due,
      TaskDateTypes.urgent,
      TaskDateTypes.target,
      TaskDateTypes.start,
    ];

    for (TaskDateType taskDateType in reversed) {
      var dateValue = taskDateType.dateFieldGetter(sprintDisplayTask);
      if (hasPassed(dateValue) &&
          dateValue != null &&
          dateValue.isAfter(DateTime.now()) &&
          dateWarnings.isEmpty) {
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
    } else if (sprintDisplayTask.isScheduled()) {
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
    if (sprintDisplayTask.isScheduled()) {
      return TextStyle(
        fontSize: 17.0,
        color: TaskColors.scheduledText,
      );
    } else {
      return const TextStyle(fontSize: 17.0);
    }
  }

  Color _getShadowColor() {
    if (sprintDisplayTask.isScheduled()) {
      // no shadow for scheduled task, by using 0 alpha
      return TaskColors.invisible;
    } else {
      return Colors.black;
    }
  }

  String getKey() {
    // var taskItemTmp = sprintDisplayTask;
    // return taskItemTmp is TaskItem ? taskItemTmp.id : taskItemTmp.tmpId;
    return sprintDisplayTask.docId;
  }

  @override
  Widget build(BuildContext context) {

    return Card(
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
                      sprintDisplayTask.name,
                      style: _getHeaderStyle(),
                    ),
                    Visibility(
                      visible: sprintDisplayTask.project != null,
                      child: Text(
                        sprintDisplayTask.project == null ? '' : sprintDisplayTask.project!,
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
    );

  }


}
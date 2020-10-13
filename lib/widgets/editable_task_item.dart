import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';
import 'package:timeago/timeago.dart' as timeago;

class EditableTaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;
  final GestureTapCallback onTap;
  final CheckCycleWaiter onTaskCompleteToggle;
  final CheckCycleWaiter onTaskAssignmentToggle;
  final DismissDirectionCallback onDismissed;
  final GestureLongPressCallback onLongPress;
  final GestureForcePressStartCallback onForcePress;
  final bool addMode;
  final MyStateSetter stateSetter;

  EditableTaskItemWidget({
    Key key,
    @required this.taskItem,
    this.onTap,
    this.onTaskCompleteToggle,
    this.onTaskAssignmentToggle,
    this.onDismissed,
    this.onLongPress,
    this.onForcePress,
    @required this.addMode,
    @required this.stateSetter,
  }) : super(key: key);

  bool hasPassed(DateTime dateTime) {
    var now = DateTime.now();
    return dateTime == null ? false : dateTime.isBefore(now);
  }

  Color getBackgroundColor() {
    var pending = taskItem.pendingCompletion;
    var due = hasPassed(taskItem.dueDate.value);
    var urgent = hasPassed(taskItem.urgentDate.value);
    var completed = taskItem.completionDate.value != null;

    if (pending) {
      return TaskColors.pendingBackground;
    } else if (completed) {
      return TaskColors.completedColor;
    } else if (due) {
      return TaskColors.dueColor;
    } else if (urgent) {
      return TaskColors.urgentColor;
    } else {
      return TaskColors.cardColor;
    }
  }

  String getStringForDateType(TaskDateType taskDateType) {
    var dateValue = taskDateType.dateFieldGetter(taskItem).value;
    var isPast = dateValue == null ? false : dateValue.isBefore(DateTime.now());
    if (dateValue == null) {
      return '';
    } else if (isPast) {
      return taskDateType.label + ' ' + formatDateTime(dateValue) + ' ago';
    } else {
      return taskDateType.label + ' in ' + formatDateTime(dateValue);
    }
  }

  String getDueDateString() {
    var dueDate = taskItem.dueDate.value;
    if (dueDate == null) {
      return '';
    } else if (taskItem.isPastDue()) {
      return 'Due ' + formatDateTime(dueDate) + ' ago';
    } else {
      return 'Due in ' + formatDateTime(dueDate);
    }
  }

  String formatDateTime(DateTime dateTime) {
    var preliminaryString = dateTime == null ? '' : timeago.format(
        dateTime,
        locale: 'en_short',
        allowFromNow: true
    );
    return preliminaryString.replaceAll(' ', '').replaceAll('~', '');
  }

  bool dueInThreshold(int thresholdDays) {
    DateTime inXDays = DateTime.now().add(Duration(days: thresholdDays));
    return taskItem.dueDate.value != null && taskItem.dueDate.value.isBefore(inXDays);
  }

  bool dateInFutureThreshold(TaskDateType taskDateType, int thresholdDays) {
    DateTime inXDays = DateTime.now().add(Duration(days: thresholdDays));
    var dateField = taskDateType.dateFieldGetter(taskItem);
    return dateField.value != null &&
        dateField.value.isAfter(DateTime.now()) &&
        dateField.value.isBefore(inXDays);
  }

  DelayedCheckbox _getCheckbox() {
    if (addMode) {
      return DelayedCheckbox(
        initialState: CheckState.inactive,
        stateSetter: stateSetter,
        checkCycleWaiter: onTaskAssignmentToggle,
        checkedColor: Colors.green,
        inactiveIcon: Icons.add,
      );
    } else {
      var completed = taskItem.completionDate.value != null;

      return DelayedCheckbox(
        initialState: completed ? CheckState.checked : CheckState.inactive,
        stateSetter: stateSetter,
        checkCycleWaiter: onTaskCompleteToggle,
      );
    }
  }

  Widget _getDateWarnings() {
    List<Widget> dateWarnings = [];
    
    if (taskItem.isCompleted()) {
      dateWarnings.add(_getDateFromNow(TaskDateTypes.completed));
    }
    
    for (TaskDateType taskDateType in TaskDateTypes.allTypes) {
      if (!taskItem.isCompleted() &&
          dateInFutureThreshold(taskDateType, 10) &&
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
        right: 15.0,
        left: 5.0,
      ),
      child: Text(
        getStringForDateType(taskDateType),
        style: TextStyle(fontSize: 14.0, color: taskDateType.textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.id.value.toString()),
      confirmDismiss: onDismissed,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onForcePressStart: (ForcePressDetails forcePressDetails) {
          print('Force Press detected!');
          onForcePress(forcePressDetails);
        },
        child: Card(
          color: getBackgroundColor(),
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
                            taskItem.name.value,
                            style: const TextStyle(fontSize: 17.0)
                        ),
                        Visibility(
                          visible: taskItem.project.value != null,
                          child: Text(
                            taskItem.project.value == null ? '' : taskItem.project.value,
                            style: const TextStyle(fontSize: 12.0,
                                color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _getDateWarnings(),
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
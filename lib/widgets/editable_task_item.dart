import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/task_colors.dart';
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

  DelayedCheckbox _getCheckbox() {
    if (addMode) {
      return DelayedCheckbox(
        initialState: CheckState.inactive,
        checkCycleWaiter: onTaskAssignmentToggle,
        checkedColor: Colors.green,
        inactiveIcon: Icons.add,
      );
    } else {
      var completed = taskItem.completionDate.value != null;

      return DelayedCheckbox(
        initialState: completed ? CheckState.checked : CheckState.inactive,
        checkCycleWaiter: onTaskCompleteToggle,
      );
    }
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
                Visibility(
                  visible: !taskItem.isCompleted() && dueInThreshold(10),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 5.0,
                      bottom: 5.0,
                      right: 15.0,
                      left: 5.0,
                    ),
                    child: Text(
                      getDueDateString(),
                      style: const TextStyle(fontSize: 14.0,
                          color: Color.fromRGBO(235, 167, 167, 1.0)),
                    ),
                  ),
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
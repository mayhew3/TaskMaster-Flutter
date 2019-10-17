import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models.dart';

class EditableTaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;
  final GestureTapCallback onTap;
  final ValueChanged<bool> onCheckboxChanged;
  final DismissDirectionCallback onDismissed;

  EditableTaskItemWidget({
    Key key,
    @required this.taskItem,
    @required this.onTap,
    @required this.onCheckboxChanged,
    @required this.onDismissed,
  }) : super(key: key);

  bool hasPassed(DateTime dateTime) {
    var now = DateTime.now();
    return dateTime == null ? false : dateTime.isBefore(now);
  }

  Color getBackgroundColor() {
    var due = hasPassed(taskItem.dueDate);
    var urgent = hasPassed(taskItem.urgentDate);
    var completed = taskItem.completionDate != null;

    if (completed) {
      return Color.fromRGBO(255, 0, 128, 0.2);
    } else if (due) {
      return Color.fromRGBO(255, 0, 0, 0.2);
    } else if (urgent) {
      return Color.fromRGBO(255, 128, 0, 0.2);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var completed = taskItem.completionDate != null;

    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.id.toString()),
      confirmDismiss: onDismissed,
      child: Container(
        color: getBackgroundColor(),
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: completed,
            onChanged: onCheckboxChanged,
          ),
          title: Text(
              taskItem.name,
              style: const TextStyle(fontSize: 18.0)
          ),
        ),
      ),
    );
  }


}
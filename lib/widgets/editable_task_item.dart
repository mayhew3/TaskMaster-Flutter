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
      return Color.fromRGBO(95, 49, 92, 1.0);
    } else if (due) {
      return Color.fromRGBO(95, 45, 63, 1.0);
    } else if (urgent) {
      return Color.fromRGBO(95, 71, 66, 1.0);
    } else {
      return Color.fromRGBO(76, 77, 105, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var completed = taskItem.completionDate != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Dismissible(
        key: TaskMasterKeys.taskItem(taskItem.id.toString()),
        confirmDismiss: onDismissed,
        child: Card(
          elevation: 1.0,
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
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
        ),
      ),
    );

  }


}
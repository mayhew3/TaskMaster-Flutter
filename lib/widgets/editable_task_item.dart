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

  @override
  Widget build(BuildContext context) {
    var completed = taskItem.completionDate != null;
    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.id.toString()),
      confirmDismiss: onDismissed,
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
    );
  }


}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;
  final GestureTapCallback onTap;
  final ValueChanged<bool> onCheckboxChanged;

  TaskItemWidget({
    Key key,
    @required this.taskItem,
    @required this.onTap,
    @required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var completed = taskItem.completionDate != null;
    return ListTile(
      onTap: onTap,
      leading: Checkbox(
        value: completed,
        onChanged: onCheckboxChanged,
      ),
      title: Text(
          taskItem.name,
          style: const TextStyle(fontSize: 18.0)
      ),
    );
  }


}
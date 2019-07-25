import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/keys.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskItem taskItem;

  TaskItemWidget({
    Key key,
    @required this.taskItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          taskItem.name,
          style: const TextStyle(fontSize: 18.0)
      ),
    );
  }


}
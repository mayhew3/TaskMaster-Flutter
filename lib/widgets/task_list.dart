import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/widgets/task_item.dart';
import 'package:taskmaster/keys.dart';

class TaskListWidget extends StatelessWidget {
  final List<TaskItem> taskItems;
  final bool loading;

  TaskListWidget({
    @required this.taskItems,
    @required this.loading,
  }) : super(key: TaskMasterKeys.todoList);

  ListView _buildListView(BuildContext context) {
    final Iterable<TaskItem> taskIterable = taskItems;
    final Iterable<TaskItemWidget> tiles = taskIterable.map<TaskItemWidget>(
        (TaskItem taskItem) {
          return TaskItemWidget(
            taskItem: taskItem,
          );
        }
    );

    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return ListView(children: divided);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ?
          Center(
            child: CircularProgressIndicator(
              key: TaskMasterKeys.todosLoading,
            )
          )
          : _buildListView(context)
    );
  }


}
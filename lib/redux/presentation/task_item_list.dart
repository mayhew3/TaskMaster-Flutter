
import 'package:flutter/material.dart';
import 'package:taskmaster/redux/presentation/task_item_item.dart';
import '../../keys.dart';
import '../../models/models.dart';
import '../containers/app_loading.dart';
import '../containers/task_item_details.dart';
import 'loading_indicator.dart';

class TaskItemList extends StatelessWidget {
  final List<TaskItem> taskItems;
  final Function(TaskItem, bool) onCheckboxChanged;
  final Function(TaskItem) onRemove;
  final Function(TaskItem) onUndoRemove;

  TaskItemList({
    Key? key,
    required this.taskItems,
    required this.onCheckboxChanged,
    required this.onRemove,
    required this.onUndoRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLoading(builder: (context, loading) {
      return loading
          ? LoadingIndicator(key: TaskMasterKeys.tasksLoading)
          : _buildListView();
    });
  }

  ListView _buildListView() {
    return ListView.builder(
      key: TaskMasterKeys.taskList,
      itemCount: taskItems.length,
      itemBuilder: (BuildContext context, int index) {
        final taskItem = taskItems[index];

        return TaskItemItem(
          taskItem: taskItem,
          onDismissed: (direction) {
            _removeTaskItem(context, taskItem);
          },
          onTap: () => _onTaskItemTap(context, taskItem),
          onCheckboxChanged: (complete) {
            if (complete != null) {
              onCheckboxChanged(taskItem, complete);
            }
          },
        );
      },
    );
  }

  void _removeTaskItem(BuildContext context, TaskItem taskItem) {
    onRemove(taskItem);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          taskItem.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => onUndoRemove(taskItem),
        )));
  }

  void _onTaskItemTap(BuildContext context, TaskItem taskItem) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => TaskItemDetails(id: taskItem.id),
    ))
        .then((removedTaskItem) {
      if (removedTaskItem != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            key: TaskMasterKeys.snackbar,
            duration: Duration(seconds: 2),
            content: Text(
              taskItem.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                onUndoRemove(taskItem);
              },
            )));
      }
    });
  }
}

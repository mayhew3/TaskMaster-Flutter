import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/screens/detail_screen.dart';

class TaskListWidget extends StatelessWidget {
  final AppState appState;
  final TaskCompleter taskCompleter;
  final TaskUpdater taskUpdater;
  final TaskDeleter taskDeleter;

  TaskListWidget({
    @required this.appState,
    @required this.taskCompleter,
    @required this.taskUpdater,
    @required this.taskDeleter,
  }) : super(key: TaskMasterKeys.taskList);

  EditableTaskItemWidget _createWidget(TaskItem taskItem, BuildContext context) {
    return EditableTaskItemWidget(
      taskItem: taskItem,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return DetailScreen(
              taskItem: taskItem,
              taskUpdater: taskUpdater,
              taskCompleter: taskCompleter,
            );
          }),
        );
      },
      onCheckboxChanged: (complete) {
        taskCompleter(taskItem, complete);
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          try {
            await taskDeleter(taskItem);
            displaySnackBar("Task Deleted!", context);
            return true;
          } catch(err) {
            return false;
          }
        }
        return false;
      },
    );
  }

  ListView _buildListView(BuildContext context) {
    appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> taskList = appState.taskItems.toList(growable: false);

    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context, index) {
      final item = taskList[index];
      return _createWidget(item, context);
    });
  }

  void displaySnackBar(String msg, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: appState.isLoading
          ?
          Center(
            child: CircularProgressIndicator(
              key: TaskMasterKeys.tasksLoading,
            )
          )
          : _buildListView(context),
    );
  }


}
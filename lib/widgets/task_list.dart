import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:taskmaster/widgets/editable_task_item.dart';
import 'package:taskmaster/keys.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/widgets/header_list_item.dart';

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

  List<TaskItem> moveSublist(List<TaskItem> superList, bool Function(TaskItem) condition) {
    List<TaskItem> subList = superList.where(condition).toList(growable: false);
    subList.forEach((task) => superList.remove(task));
    return subList;
  }

  ListView _buildListView(BuildContext context) {
    appState.notificationScheduler.updateHomeScreenContext(context);
    final List<TaskItem> otherTasks = List.from(appState.taskItems);

    final List<TaskItem> completedTasks = moveSublist(otherTasks, (task) => task.isCompleted());
    final List<TaskItem> dueTasks = moveSublist(otherTasks, (task) => task.isPastDue());
    final List<TaskItem> urgentTasks = moveSublist(otherTasks, (task) => task.isUrgent());

    List<StatelessWidget> tiles = [];

    if (dueTasks.isNotEmpty) {
      tiles.add(HeadingItem('Past Due'));
      dueTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (urgentTasks.isNotEmpty) {
      tiles.add(HeadingItem('Urgent'));
      urgentTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (otherTasks.isNotEmpty) {
      tiles.add(HeadingItem('Tasks'));
      otherTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    if (completedTasks.isNotEmpty) {
      tiles.add(HeadingItem('Completed'));
      completedTasks.forEach((task) => tiles.add(_createWidget(task, context)));
    }

    return ListView.builder(
        itemCount: tiles.length,
        itemBuilder: (context, index) {
      return tiles[index];
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
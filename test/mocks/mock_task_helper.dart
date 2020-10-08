import 'package:flutter/src/widgets/framework.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/typedefs.dart';
import 'package:mockito/mockito.dart';

class MockTaskHelper extends Mock implements TaskHelper {

  @override
  AppState appState;
  final TaskRepository taskRepository;

  MockTaskHelper({
    @required this.taskRepository,
  });

  @override
  void reloadTasks() {
  }

  @override
  Future<void> addTask(TaskItem taskItem) async {
  }

  @override
  Future<TaskItem> completeTask(TaskItem taskItem, bool completed) async {
    return Future.value(taskItem);
  }

  @override
  Future<void> deleteTask(TaskItem taskItem) async {
  }

  @override
  Future<TaskItem> updateTask(TaskItem taskItem) async {
    return Future.value(taskItem);
  }
}
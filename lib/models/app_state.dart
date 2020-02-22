import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/task_entity.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/typedefs.dart';

class AppState {
  bool isLoading;
  List<TaskItem> taskItems;
  TaskMasterAuth auth;
  GoogleSignInAccount currentUser;
  bool tokenRetrieved = false;
  int personId;
  NotificationScheduler notificationScheduler;
  String title;
  final NavHelper navHelper;

  AppState({
    this.isLoading = true,
    this.taskItems = const [],
    @required userUpdater: UserUpdater,
    @required idTokenUpdater: IdTokenUpdater,
    @required this.navHelper,
  }) {
    auth = TaskMasterAuth(
      updateCurrentUser: userUpdater,
      updateIdToken: idTokenUpdater,
    );
    title = 'TaskMaster 3000';
  }

  Future<IdTokenResult> getIdToken() async {
    try {
      return await auth.getIdToken();
    } catch (err) {
      print("Error getting ID token. Redirecting to signin screen.");
      this.navHelper.goToSignInScreen();
      throw err;
    }
  }

  List<TaskItem> getFilteredTasks(bool showScheduled, bool showCompleted) {
    List<TaskItem> filtered = taskItems.where((taskItem) {
      bool passesScheduleFilter = showScheduled || !taskItem.isScheduled();
      bool passesCompletedFilter = showCompleted || !taskItem.isCompleted();
      return passesScheduleFilter && passesCompletedFilter;
    }).toList();
    return filtered;
  }

  TaskItem findTaskItemWithId(int taskId) {
    var matching = taskItems.where((task) => task.id == taskId);
    return matching.isEmpty ? null : matching.first;
  }

  void updateNotificationScheduler(BuildContext context,
      AppState appState,
      TaskAdder taskAdder,
      TaskUpdater taskUpdater,
      TaskCompleter taskCompleter) {
    notificationScheduler = NotificationScheduler(
      context: context,
      appState: appState,
      taskAdder: taskAdder,
      taskUpdater: taskUpdater,
      taskCompleter: taskCompleter,
    );
  }

  void finishedLoading(List<TaskItem> taskItems) {
    isLoading = false;
    this.taskItems = taskItems;
  }

  TaskItem addNewTaskToList(TaskEntity taskEntity) {
    var taskItem = TaskItem.fromEntity(taskEntity);
    taskItems.add(taskItem);
    return taskItem;
  }

  void deleteTaskFromList(TaskItem taskItem) {
    taskItems.remove(taskItem);
  }

  TaskItem updateTaskListWithUpdatedTask(TaskEntity taskEntity) {
    var taskItem = TaskItem.fromEntity(taskEntity);
    var existingIndex = taskItems.indexWhere((element) => element.id == taskItem.id);
    taskItems[existingIndex] = taskItem;
    return taskItem;
  }

  bool isAuthenticated() {
    return currentUser != null && tokenRetrieved;
  }

  @override
  int get hashCode => taskItems.hashCode ^ isLoading.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              taskItems == other.taskItems &&
              isLoading == other.isLoading;

  @override
  String toString() {
    return 'AppState{taskItems: $taskItems, isLoading: $isLoading}';
  }
}

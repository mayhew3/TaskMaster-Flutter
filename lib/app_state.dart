import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/timezone_helper.dart';

class AppState {
  bool isLoading;
  List<TaskItem> _taskItems = [];
  List<Sprint> _sprints = [];
  final TaskMasterAuth auth;
  GoogleSignInAccount? currentUser;
  bool tokenRetrieved = false;
  late int personId;
  late NotificationScheduler notificationScheduler;
  late String title;
  late NavHelper navHelper;

  AppState({
    this.isLoading = true,
    List<TaskItem> taskItems = const [],
    List<Sprint> sprints = const [],
    required this.auth,
  }) {
    title = 'TaskMaster 3000';
    this._taskItems = taskItems;
    this._sprints = sprints;
    linkTasksToSprints();
  }

  void updateTasksAndSprints(List<TaskItem> taskItems, List<Sprint> sprints) {
    this._sprints = sprints;
    this._taskItems = taskItems;
    linkTasksToSprints();
  }

  void linkTasksToSprints() {
    for (var taskItem in _taskItems) {
      if (taskItem.sprintAssignments != null) {
        for (var sprintAssignment in taskItem.sprintAssignments!) {
          Iterable<Sprint> sprints = this._sprints.where((sprint) => sprint.id == sprintAssignment.sprintId);
          if (sprints.isNotEmpty) {
            var sprint = sprints.first;
            taskItem.sprints.add(sprint);
            sprint.addToTasks(taskItem);
          }
        }
      }
    }
  }

  void updateNavHelper(NavHelper navHelper) {
    this.navHelper = navHelper;
  }

  Future<String> getIdToken() async {
    try {
      return await auth.getIdToken();
    } catch (err) {
      print("Error getting ID token. Redirecting to signin screen.");
      this.navHelper.goToSignInScreen();
      throw err;
    }
  }

  // need getter function to pass as argument
  List<TaskItem> getAllTasks() {
    return _taskItems;
  }

  List<TaskItem> get taskItems {
    return _taskItems;
  }

  List<Sprint> get sprints {
    return _sprints;
  }

  List<TaskItem> getTasksForActiveSprint() {
    var activeSprint = getActiveSprint();
    return activeSprint == null ? [] : activeSprint.taskItems;
  }

  TaskItem? findTaskItemWithId(int taskId) {
    var matching = _taskItems.where((taskItem) => taskItem.id == taskId);
    return matching.isEmpty ? null : matching.first;
  }

  Sprint? findSprintWithId(int sprintId) {
    var matching = _sprints.where((sprint) => sprint.id == sprintId);
    return matching.isEmpty ? null : matching.first;
  }

  void updateNotificationScheduler(BuildContext context,
      TaskHelper taskHelper) {

    notificationScheduler = NotificationScheduler(
      context: context,
      appState: this,
      taskHelper: taskHelper,
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
      flutterBadgerWrapper: FlutterBadgerWrapper(),
      timezoneHelper: TimezoneHelper(),
    );

  }

  Future<void> syncAllNotifications() async {
    await notificationScheduler.cancelAllNotifications();
    await notificationScheduler.syncNotificationForTasksAndSprint(_taskItems, getActiveSprint());
  }

  Sprint? getActiveSprint() {
    DateTime now = DateTime.now();
    Iterable<Sprint> matching = this._sprints.where((sprint) =>
        sprint.startDate.isBefore(now) &&
        sprint.endDate.isAfter(now) &&
        sprint.closeDate == null);
    return matching.isEmpty ? null : matching.first;
  }

  Sprint? getLastCompletedSprint() {
    List<Sprint> matching = this._sprints.where((sprint) {
      return DateTime.now().isAfter(sprint.endDate);
    }).toList();
    matching.sort((a, b) => a.endDate.compareTo(b.endDate));
    return matching.isEmpty ? null : matching.last;
  }

  void finishedLoading() {
    isLoading = false;
  }

  TaskItem addNewTaskToList(TaskItem taskItem) {
    _taskItems.add(taskItem);
    return taskItem;
  }

  void deleteTaskFromList(TaskItem taskItem) {
    _taskItems.remove(taskItem);
  }

  bool isAuthenticated() {
    return currentUser != null && tokenRetrieved;
  }

  void signOut() {
    currentUser = null;
    tokenRetrieved = false;
  }

  @override
  int get hashCode => _taskItems.hashCode ^ isLoading.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              _taskItems == other._taskItems &&
              isLoading == other.isLoading;

  @override
  String toString() {
    return 'AppState{taskItems: $_taskItems, isLoading: $isLoading}';
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

class AppState {
  bool isLoading;
  List<TaskItem> taskItems;
  List<Sprint> sprints;
  final TaskMasterAuth auth;
  GoogleSignInAccount currentUser;
  bool tokenRetrieved = false;
  int personId;
  NotificationScheduler notificationScheduler;
  String title;
  NavHelper navHelper;

  AppState({
    this.isLoading = true,
    this.taskItems = const [],
    this.sprints = const [],
    @required this.auth,
  }) {
    title = 'TaskMaster 3000';
  }

  void updateNavHelper(NavHelper navHelper) {
    this.navHelper = navHelper;
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

  List<TaskItem> getAllTasks() {
    return taskItems;
  }

  List<TaskItem> getTasksForActiveSprint() {
    var activeSprint = getActiveSprint();
    return activeSprint == null ? [] : activeSprint.taskItems;
  }

  TaskItem findTaskItemWithId(int taskId) {
    var matching = taskItems.where((taskItem) => taskItem.id.value == taskId);
    return matching.isEmpty ? null : matching.first;
  }

  Sprint findSprintWithId(int sprintId) {
    var matching = sprints.where((sprint) => sprint.id.value == sprintId);
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
    );

  }

  Future<void> syncAllNotifications() async {
    await notificationScheduler.syncNotificationForTasksAndSprint(taskItems, getActiveSprint());
  }

  Sprint getActiveSprint() {
    DateTime now = DateTime.now();
    Iterable<Sprint> matching = this.sprints.where((sprint) =>
        sprint.startDate.value.isBefore(now) &&
        sprint.endDate.value.isAfter(now) &&
        sprint.closeDate.value == null);
    return matching.isEmpty ? null : matching.first;
  }

  Sprint getLastCompletedSprint() {
    List<Sprint> matching = this.sprints.where((sprint) {
      return DateTime.now().isAfter(sprint.endDate.value);
    }).toList();
    matching.sort((a, b) => a.endDate.value.compareTo(b.endDate.value));
    return matching.isEmpty ? null : matching.last;
  }

  void finishedLoading() {
    isLoading = false;
  }

  TaskItem addNewTaskToList(TaskItem taskItem) {
    taskItems.add(taskItem);
    return taskItem;
  }

  void deleteTaskFromList(TaskItem taskItem) {
    taskItems.remove(taskItem);
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

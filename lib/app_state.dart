import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/notification_scheduler.dart';

class AppState {
  bool isLoading;
  List<TaskItem> _taskItems = [];
  List<Sprint> _sprints = [];
  List<TaskRecurrence> _taskRecurrences = [];
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
    List<TaskRecurrence> taskRecurrences = const [],
    required this.auth,
  }) {
    title = 'TaskMaster 3000';
    this._taskItems = taskItems;
    this._sprints = sprints;
    linkTasksToSprints();
  }

  void updateTasksAndSprints(List<TaskItem> taskItems, List<Sprint> sprints, List<TaskRecurrence> taskRecurrences) {
    this._sprints = sprints;
    this._taskItems = taskItems;
    this._taskRecurrences = taskRecurrences;
    linkTasksToSprints();
    linkTasksToRecurrences();
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

  void linkTasksToRecurrences() {
    for (var taskItem in _taskItems) {
      if (taskItem.recurrenceId != null) {
        Iterable<TaskRecurrence> taskRecurrences = this._taskRecurrences.where((taskRecurrence) => taskRecurrence.id == taskItem.recurrenceId);
        if (taskRecurrences.isNotEmpty) {
          taskRecurrences.first.addToTaskItems(taskItem);
        }
      }
    }
  }

  void updateNavHelper(NavHelper navHelper) {
    this.navHelper = navHelper;
  }

  Future<String> getIdToken() async {
    try {
      var idToken = await auth.getIdToken();
      if (idToken == null) {
        throw new Exception("Null id token found.");
      }
      return idToken;
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

  void updateNotificationScheduler(NotificationScheduler notificationScheduler) {
    this.notificationScheduler = notificationScheduler;
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

  void replaceTaskRecurrence(TaskRecurrence oldRecurrence, TaskRecurrence newRecurrence) {
    for (TaskItem taskItem in oldRecurrence.taskItems) {
      var existing = taskItems.where((t) => t.id == taskItem.id).singleOrNull;
      if (existing != null) {
        newRecurrence.addToTaskItems(existing);
      }
    }

    var indexOf = _taskRecurrences.indexOf(oldRecurrence);
    _taskRecurrences[indexOf] = newRecurrence;
  }

  void replaceTaskItem(TaskItem oldTaskItem, TaskItem newTaskItem) {
    var indexOf = _taskItems.indexOf(oldTaskItem);
    _taskItems[indexOf] = newTaskItem;

    var activeSprint = getActiveSprint();
    var sprintItems = activeSprint?.taskItems;
    if (sprintItems != null) {
      var sprintIndexOf = sprintItems.indexOf(oldTaskItem);
      if (sprintIndexOf > -1) {
        sprintItems[sprintIndexOf] = newTaskItem;
      }
    }

    for (var recurrence in _taskRecurrences) {
      var recurIndex = recurrence.taskItems.indexOf(oldTaskItem);
      if (recurIndex >= 0) {
        recurrence.taskItems[recurIndex] = newTaskItem;
      }
    }
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

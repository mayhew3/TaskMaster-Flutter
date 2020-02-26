import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/screens/loading.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:jiffy/jiffy.dart';

class TaskMasterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskMasterAppState();
  }
}

class TaskMasterAppState extends State<TaskMasterApp> {
  AppState appState;
  TaskRepository repository;
  NavHelper navHelper;

  TaskMasterAppState() {
    appState = AppState(
      userUpdater: updateCurrentUser,
      idTokenUpdater: updateIdToken,
      navHelper: navHelper,
    );
    repository = TaskRepository(appState: appState);
    navHelper = NavHelper(
      appState: appState,
      taskRepository: repository,
      taskAdder: addTask,
      taskCompleter: completeTask,
      taskDeleter: deleteTask,
      taskUpdater: updateTask,
      taskListReloader: reloadTasks,
    );
  }

  @override
  void initState() {
    super.initState();
    appState.updateNotificationScheduler(
        context,
        appState,
        addTask,
        updateTask,
        completeTask);
    maybeKickOffSignIn();
  }

  void loadMainTaskUI() {
    navHelper.goToLoadingScreen('Loading tasks...');
    repository.loadTasks().then((loadedTasks) {
      setState(() {
        List<TaskItem> tasks = loadedTasks.map(TaskItem.fromEntity).toList();
        appState.finishedLoading(tasks);
      });
      navHelper.goToHomeScreen();
      appState.notificationScheduler.updateBadge();
      appState.taskItems.forEach((taskItem) =>
          appState.notificationScheduler.syncNotificationForTask(taskItem));
    }).catchError((err) {
      setState(() {
        appState.isLoading = false;
      });
    });
  }

  void reloadTasks() async {
    navHelper.goToLoadingScreen('Reloading tasks...');
    appState.isLoading = true;
    appState.taskItems = [];

    await appState.notificationScheduler.cancelAllNotifications();
    repository.loadTasks().then((loadedTasks) {
      setState(() {
        List<TaskItem> tasks = loadedTasks.map(TaskItem.fromEntity).toList();
        appState.finishedLoading(tasks);
      });
      appState.notificationScheduler.updateBadge();
      navHelper.goToHomeScreen();
      appState.taskItems.forEach((taskItem) =>
          appState.notificationScheduler.syncNotificationForTask(taskItem));
    }).catchError((err) {
      setState(() {
        appState.isLoading = false;
      });
    });
  }

  void maybeKickOffSignIn() {
    if (!appState.isAuthenticated()) {
      appState.auth.addGoogleListener().then((value) {
        if (value == null) {
          navHelper.goToSignInScreen();
        }
      });
    }
  }

  void updateCurrentUser(GoogleSignInAccount currentUser) {
    setState(() {
      appState.currentUser = currentUser;
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  void updateIdToken(IdTokenResult idToken) {
    setState(() {
      appState.tokenRetrieved = true;
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  void addTask(TaskItem taskItem) async {
    var inboundTask = await repository.addTask(taskItem);
    setState(() {
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(addedTask);
    });
    appState.notificationScheduler.updateBadge();
  }

  DateTime addToDate(DateTime previousDate, Duration duration) {
    if (previousDate == null) {
      return null;
    } else {
      return previousDate.add(duration);
    }
  }

  DateTime getAdjustedDate(DateTime dateTime, int recurNumber, String recurUnit) {
    if (dateTime == null) {
      return null;
    }
    switch (recurUnit) {
      case 'Days': return Jiffy(dateTime).add(days: recurNumber);
      case 'Weeks': return Jiffy(dateTime).add(weeks: recurNumber);
      case 'Months': return Jiffy(dateTime).add(months: recurNumber);
      case 'Years': return Jiffy(dateTime).add(years: recurNumber);
      default: return null;
    }
  }

  DateTime applyTimeToDate(DateTime dateWithTime, DateTime targetDate) {
    var jiffy = Jiffy([
      targetDate.year,
      targetDate.month,
      targetDate.day,
      dateWithTime.hour,
      dateWithTime.minute,
      dateWithTime.second]);
    return jiffy.dateTime;
  }

  DateTime getClosestDateForTime(DateTime dateWithTime, DateTime targetDate) {
    DateTime prev = applyTimeToDate(dateWithTime, Jiffy(targetDate).subtract(days:1));
    DateTime current = applyTimeToDate(dateWithTime, targetDate);
    DateTime next = applyTimeToDate(dateWithTime, Jiffy(targetDate).add(days:1));

    var prevDiff = prev.difference(targetDate).abs();
    var currDiff = current.difference(targetDate).abs();
    var nextDiff = next.difference(targetDate).abs();

    if (prevDiff < currDiff && prevDiff < nextDiff) {
      return prev;
    } else if (currDiff < nextDiff) {
      return current;
    } else {
      return next;
    }
  }

  Future<TaskItem> completeTask(TaskItem taskItem, bool completed) async {
    TaskItem nextScheduledTask;
    DateTime completionDate = completed ? DateTime.now() : null;

    if (taskItem.recurNumber != null && completed) {
      DateTime anchorDate = taskItem.getAnchorDate();
      DateTime nextAnchorDate;

      String anchorDateFieldName = taskItem.getAnchorDateFieldName();
      TaskDateHolder dateHolder = new TaskDateHolder(anchorDateFieldName: anchorDateFieldName);

      if (taskItem.recurWait) {
        nextAnchorDate = getAdjustedDate(completionDate, taskItem.recurNumber, taskItem.recurUnit);
      } else {
        nextAnchorDate = getAdjustedDate(anchorDate, taskItem.recurNumber, taskItem.recurUnit);
      }

      DateTime dateWithTime = getClosestDateForTime(anchorDate, nextAnchorDate);

      Duration duration = dateWithTime.difference(anchorDate);

      dateHolder.startDate = addToDate(taskItem.startDate, duration);
      dateHolder.targetDate = addToDate(taskItem.targetDate, duration);
      dateHolder.urgentDate = addToDate(taskItem.urgentDate, duration);
      dateHolder.dueDate = addToDate(taskItem.dueDate, duration);

      nextScheduledTask = TaskItem(
          personId: taskItem.personId,
          name: taskItem.name,
          description: taskItem.description,
          project: taskItem.project,
          context: taskItem.context,
          urgency: taskItem.urgency,
          priority: taskItem.priority,
          duration: taskItem.duration,
          dateAdded: DateTime.now(),
          startDate: dateHolder.startDate,
          targetDate: dateHolder.targetDate,
          dueDate: dateHolder.dueDate,
          completionDate: null,
          urgentDate: dateHolder.urgentDate,
          gamePoints: taskItem.gamePoints,
          recurNumber: taskItem.recurNumber,
          recurUnit: taskItem.recurUnit,
          recurWait: taskItem.recurWait
      );

    }
    var inboundTask = await repository.completeTask(taskItem, completionDate);
    TaskItem updatedTask;
    setState(() {
      updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
    });
    appState.notificationScheduler.updateBadge();

    if (nextScheduledTask != null) {
      addTask(nextScheduledTask);
    }

    return updatedTask;
  }

  void deleteTask(TaskItem taskItem) async {
    var taskId = taskItem.id;
    await repository.deleteTask(taskItem);
    print('Removal of task successful!');
    await appState.notificationScheduler.cancelNotificationsForTaskId(taskId);
    setState(() {
      appState.deleteTaskFromList(taskItem);
    });
    appState.notificationScheduler.updateBadge();
  }

  Future<TaskItem> updateTask({
    TaskItem taskItem,
    String name,
    String description,
    String project,
    String context,
    int urgency,
    int priority,
    int duration,
    DateTime startDate,
    DateTime targetDate,
    DateTime dueDate,
    DateTime urgentDate,
    int gamePoints,
    int recurNumber,
    String recurUnit,
    bool recurWait,
  }) async {
    var inboundTask = await repository.updateTask(
        taskItem: taskItem,
        name: name,
        description: description,
        project: project,
        context: context,
        urgency: urgency,
        priority: priority,
        duration: duration,
        startDate: startDate,
        targetDate: targetDate,
        dueDate: dueDate,
        urgentDate: urgentDate,
        gamePoints: gamePoints,
        recurNumber: recurNumber,
        recurUnit: recurUnit,
        recurWait: recurWait
    );
    TaskItem updatedTask;
    setState(() {
      updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
    });
    appState.notificationScheduler.updateBadge();
    return updatedTask;
  }

  @override
  Widget build(BuildContext context) {
    var myPink = Color.fromRGBO(217, 71, 142, 1.0);
    return MaterialApp(
      title: appState.title,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(102, 106, 186, 1.0),
        canvasColor: Color.fromRGBO(55, 56, 81, 1.0),
        accentColor: myPink,
        toggleableActiveColor: myPink,
      ),
      home: LoadingScreen(
        appState: appState,
        navHelper: navHelper,
        msg: 'Signing in...',
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/screens/home_screen.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TaskMasterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskMasterAppState();
  }
}

class TaskMasterAppState extends State<TaskMasterApp> {
  AppState appState;
  TaskRepository repository;
  NotificationScheduler notificationScheduler;

  TaskMasterAppState() {
    appState = AppState(userUpdater: updateCurrentUser, idTokenUpdater: updateIdToken);
    repository = TaskRepository(appState: appState);
    notificationScheduler = NotificationScheduler(context);
  }

  void loadMainTaskUI() {
    repository.loadTasks().then((loadedTasks) {
      setState(() {
        List<TaskItem> tasks = loadedTasks.map(TaskItem.fromEntity).toList();
        appState.finishedLoading(tasks);
        tasks.forEach((taskItem) => notificationScheduler.syncNotificationForTask(taskItem));
      });
    }).catchError((err) {
      setState(() {
        appState.isLoading = false;
      });
    });
  }

  void updateCurrentUser(GoogleSignInAccount currentUser) {
    setState(() {
      appState.currentUser = currentUser;
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  void updateIdToken(String idToken) {
    setState(() {
      appState.idToken = idToken;
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  void addTask(TaskItem taskItem) async {
    var inboundTask = await repository.addTask(taskItem);
    setState(() {
      appState.addNewTaskToList(inboundTask);
    });
  }

  void updateTask({
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
    setState(() {
      appState.updateTaskListWithUpdatedTask(inboundTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = "TaskMaster 3000";
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      routes: {
        TaskMasterRoutes.home: (context) {
          return HomeScreen(
            appState: appState,
            title: title,
            taskAdder: addTask,
            taskUpdater: updateTask,
          );
        }
      },
    );
  }

}
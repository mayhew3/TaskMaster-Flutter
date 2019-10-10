import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/screens/loading.dart';
import 'package:taskmaster/task_repository.dart';
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
  NavHelper navHelper;

  TaskMasterAppState() {
    appState = AppState(userUpdater: updateCurrentUser,
        idTokenUpdater: updateIdToken,
    loginFailedCallback: () {});
    repository = TaskRepository(appState: appState);
    navHelper = NavHelper(
      appState: appState,
      taskRepository: repository,
      taskAdder: addTask,
      taskCompleter: completeTask,
      taskUpdater: updateTask,
    );
  }

  void loadMainTaskUI() {
    navHelper.goToLoadingScreen();
    repository.loadTasks().then((loadedTasks) {
      setState(() {
        List<TaskItem> tasks = loadedTasks.map(TaskItem.fromEntity).toList();
        appState.finishedLoading(tasks);
        navHelper.goToHomeScreen();
        tasks.forEach((taskItem) => appState.notificationScheduler.syncNotificationForTask(taskItem));
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
      var addedTask = appState.addNewTaskToList(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(addedTask);
    });
  }

  void completeTask(TaskItem taskItem, bool completed) async {
    var inboundTask = await repository.completeTask(taskItem, completed);
    setState(() {
      var updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
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
      var updatedTask = appState.updateTaskListWithUpdatedTask(inboundTask);
      appState.notificationScheduler.syncNotificationForTask(updatedTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appState.title,
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      home: LoadingScreen(
        appState: appState,
        navHelper: navHelper,
        msg: 'Signing in...',
        loadListStarter: loadMainTaskUI,
      ),
    );
  }

}
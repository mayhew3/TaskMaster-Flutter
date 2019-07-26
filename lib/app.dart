import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/screens/home_screen.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/routes.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TaskMasterApp extends StatefulWidget {
  final TaskRepository repository;

  TaskMasterApp({@required this.repository});

  @override
  State<StatefulWidget> createState() {
    return TaskMasterAppState();
  }

}

class TaskMasterAppState extends State<TaskMasterApp> {
  AppState appState;

  TaskMasterAppState() {
    appState = AppState(userUpdater: updateCurrentUser);
  }

  void loadMainTaskUI() {
    widget.repository.loadTasks().then((loadedTasks) {
      setState(() {
        List<TaskItem> tasks = loadedTasks.map(TaskItem.fromEntity).toList();
        appState.finishedLoading(tasks);
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
          );
        }
      },
    );
  }

}
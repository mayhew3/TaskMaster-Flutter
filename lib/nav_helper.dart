import 'package:flutter/material.dart';
import 'package:taskmaster/models.dart';
import 'package:taskmaster/screens/home_screen.dart';
import 'package:taskmaster/screens/loading.dart';
import 'package:taskmaster/screens/sign_in.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/typedefs.dart';

class NavHelper {
  final AppState appState;
  final TaskRepository taskRepository;
  final TaskAdder taskAdder;
  final TaskCompleter taskCompleter;
  final TaskDeleter taskDeleter;
  final TaskUpdater taskUpdater;
  final TaskListReloader taskListReloader;

  BuildContext context;

  NavHelper({
    @required this.appState,
    @required this.taskRepository,
    @required this.taskAdder,
    @required this.taskCompleter,
    @required this.taskDeleter,
    @required this.taskUpdater,
    @required this.taskListReloader,
  });

  void updateContext(BuildContext context) {
    this.context = context;
  }

  void goToLoadingScreen(String msg) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) {
        return LoadingScreen(
          appState: appState,
          navHelper: this,
          msg: msg,
        );
      }),
    );
  }

  void goToSignInScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) {
        return SignInScreen(
          appState: appState,
          navHelper: this,
        );
      }),
    );
  }

  void goToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) {
        return HomeScreen(
          appState: appState,
          navHelper: this,
          taskAdder: taskAdder,
          taskCompleter: taskCompleter,
          taskDeleter: taskDeleter,
          taskUpdater: taskUpdater,
          taskListReloader: taskListReloader,
        );
      }),
    );
  }

}
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
  final TaskUpdater taskUpdater;

  BuildContext context;

  NavHelper({
    this.appState,
    this.taskRepository,
    this.taskAdder,
    this.taskCompleter,
    this.taskUpdater,
  });

  void updateContext(BuildContext context) {
    this.context = context;
  }

  void goToLoadingScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return LoadingScreen(
          appState: appState,
          navHelper: this,
          msg: 'Loading tasks...',
        );
      }),
    );
  }

  void goToSignInScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return SignInScreen(
          appState: appState,
        );
      }),
    );
  }

  void goToHomeScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) {
        return HomeScreen(
          appState: appState,
          taskAdder: taskAdder,
          taskCompleter: taskCompleter,
          taskUpdater: taskUpdater,
        );
      }),
    );
  }

}
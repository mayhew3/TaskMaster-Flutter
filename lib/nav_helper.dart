import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/screens/home_screen.dart';
import 'package:taskmaster/screens/loading.dart';
import 'package:taskmaster/screens/sign_in.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';

class NavHelper {
  final AppState appState;
  final TaskRepository taskRepository;
  final TaskHelper taskHelper;

  late BuildContext context;

  NavHelper({
    required this.appState,
    required this.taskRepository,
    required this.taskHelper,
  }) {
    this.appState.updateNavHelper(this);
  }

  void updateContext(BuildContext context) {
    this.context = context;
  }

  void goToLoadingScreen(String msg) {
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) {
        return HomeScreen(
          appState: appState,
          navHelper: this,
          taskHelper: taskHelper,
        );
      }),
    );
  }

}
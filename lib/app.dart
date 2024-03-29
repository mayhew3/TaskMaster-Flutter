import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/screens/loading.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';

class TaskMasterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskMasterAppState();
  }
}

class TaskMasterAppState extends State<TaskMasterApp> {
  late final AppState appState;
  late final TaskRepository repository;
  late final NavHelper navHelper;
  late final TaskMasterAuth auth;
  late final TaskHelper taskHelper;

  TaskMasterAppState() {
    auth = TaskMasterAuth(
      updateCurrentUser: updateCurrentUser,
      updateIdToken: updateIdToken,
    );
    appState = AppState(
      auth: auth,
    );
    repository = TaskRepository(
      appState: appState,
      client: http.Client(),
    );
    taskHelper = TaskHelper(
        appState: appState,
        repository: repository,
        auth: auth,
        stateSetter: (callback) => {
          setState(callback)
        });
    navHelper = NavHelper(
      appState: appState,
      taskRepository: repository,
      taskHelper: taskHelper,
    );
    taskHelper.navHelper = navHelper;
  }

  @override
  void initState() {
    super.initState();
    appState.updateNotificationScheduler(
        context,
        taskHelper);
    maybeKickOffSignIn();
  }

  void loadMainTaskUI() {
    navHelper.goToLoadingScreen('Loading tasks...');
    repository.loadTasks((callback) => setState(callback))
        .then((_) async {
      appState.finishedLoading();
      navHelper.goToHomeScreen();
      appState.notificationScheduler.updateBadge();
      appState.syncAllNotifications();
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

  void updateCurrentUser(GoogleSignInAccount? currentUser) {
    setState(() {
      appState.currentUser = currentUser;
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  void updateIdToken(String? idToken) {
    setState(() {
      appState.tokenRetrieved = (idToken != null);
    });
    if (appState.isAuthenticated()) {
      loadMainTaskUI();
    }
  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: TaskColors.menuColor,
      canvasColor: TaskColors.backgroundColor,
      toggleableActiveColor: TaskColors.highlight,
    );

    return MaterialApp(
      title: appState.title,
      theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: TaskColors.backgroundColor,
            secondary: TaskColors.highlight,
            surface: TaskColors.menuColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: TaskColors.menuColor
              )
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: TaskColors.menuColor
              )
          )
      ),
      home: LoadingScreen(
        appState: appState,
        navHelper: navHelper,
        msg: 'Signing in...',
      ),
    );
  }

}
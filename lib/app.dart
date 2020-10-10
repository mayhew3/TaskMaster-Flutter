import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/auth.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:http/http.dart' as http;
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
  AppState appState;
  TaskRepository repository;
  NavHelper navHelper;
  TaskMasterAuth auth;
  TaskHelper taskHelper;

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
        appState,
        taskHelper);
    maybeKickOffSignIn();
  }

  void loadMainTaskUI() {
    navHelper.goToLoadingScreen('Loading tasks...');
    repository.loadTasks().then((loadedTasks) {
      repository.loadSprints().then((loadedSprints) {
        setState(() {
          appState.finishedLoading(loadedTasks, loadedSprints);
        });
        navHelper.goToHomeScreen();
        appState.notificationScheduler.updateBadge();
        appState.taskItems.forEach((taskItem) =>
            appState.notificationScheduler.syncNotificationForTask(taskItem));
      });
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
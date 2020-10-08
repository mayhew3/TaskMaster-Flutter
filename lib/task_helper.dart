
import 'package:flutter/material.dart';
import 'package:taskmaster/task_repository.dart';

import 'auth.dart';
import 'models/app_state.dart';
import 'nav_helper.dart';

class TaskHelper {
  final AppState appState;
  final TaskRepository repository;
  NavHelper navHelper;
  final TaskMasterAuth auth;
  final StateSetter stateSetter;

  TaskHelper({
    @required this.appState,
    @required this.repository,
    this.navHelper,
    @required this.auth,
    @required this.stateSetter,
  });

  void reloadTasks() async {
    navHelper.goToLoadingScreen('Reloading tasks...');
    appState.isLoading = true;
    appState.taskItems = [];

    await appState.notificationScheduler.cancelAllNotifications();
    repository.loadTasks().then((loadedTasks) {
      stateSetter(() => appState.finishedLoading(loadedTasks));
      appState.notificationScheduler.updateBadge();
      navHelper.goToHomeScreen();
      appState.taskItems.forEach((taskItem) =>
          appState.notificationScheduler.syncNotificationForTask(taskItem));
    }).catchError((err) {
      stateSetter(() => appState.isLoading = false);
    });
  }

}
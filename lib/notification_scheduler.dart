import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/typedefs.dart';

class NotificationScheduler {

  AppState appState;
  TaskAdder taskAdder;
  TaskUpdater taskUpdater;
  TaskCompleter taskCompleter;

  BuildContext context;
  BuildContext homeScreenContext;
  int nextId = 0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationScheduler({
    @required BuildContext context,
    @required AppState appState,
    @required TaskAdder taskAdder,
    @required TaskUpdater taskUpdater,
    @required TaskCompleter taskCompleter,
  }) {
    this.context = context;
    this.appState = appState;
    this.taskAdder = taskAdder;
    this.taskUpdater = taskUpdater;

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void updateHomeScreenContext(BuildContext context) {
    homeScreenContext = context;
  }

  int getNumberOfUrgentTasks() {
    var urgentTasks = appState.taskItems.where((taskItem) =>
      (taskItem.urgentDate.hasPassed() || taskItem.dueDate.hasPassed()) && taskItem.completionDate.value == null);
    return urgentTasks.length;
  }

  void updateBadge() {
    var numberOfUrgentTasks = getNumberOfUrgentTasks();
    print('Updating badge with ${numberOfUrgentTasks.toString()} urgent tasks.');
    FlutterAppBadger.updateBadgeCount(numberOfUrgentTasks);
  }

  Future<void> goToDetailScreen({
    String payload,
    BuildContext incomingContext
  }) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    var parts = payload.split(":");
    var taskId = int.parse(parts[1]);
    var taskItem = appState.findTaskItemWithId(taskId);

    var contextToUse = incomingContext ?? homeScreenContext;

    await Navigator.push(
        contextToUse,
        MaterialPageRoute(builder: (context) {
          return DetailScreen(
            taskItem: taskItem,
            taskAdder: taskAdder,
            taskUpdater: taskUpdater,
          );
        })
    );
  }

  Future<void> onSelectNotification(String payload) async {
    updateBadge();
    await goToDetailScreen(payload: payload);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    updateBadge();
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await goToDetailScreen(payload: payload, incomingContext: context);
            },
          )
        ],
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    return flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationsForTaskId(int taskId) async {
    var taskSearch = 'task:$taskId';
    var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var existing = pendingNotificationRequests.where((notification) => notification.payload.startsWith(taskSearch));
    existing.forEach((notification) {
      print('Removing task: ${notification.payload}');
      flutterLocalNotificationsPlugin.cancel(notification.id);
    });
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> syncNotificationForTask(TaskItem taskItem) async {

    var taskSearch = 'task:${taskItem.id.value}';
    var removedDue = false;
    var removedUrgent = false;

    var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var existing = pendingNotificationRequests.where((notification) => notification.payload.startsWith(taskSearch));
    existing.forEach((notification) {
      if (notification.payload.endsWith('due')) {
        removedDue = true;
      }
      if (notification.payload.endsWith('urgent')) {
        removedUrgent = true;
      }
      print('Removing task: ${notification.payload}');
      flutterLocalNotificationsPlugin.cancel(notification.id);
    });

    DateTime dueDate = taskItem.dueDate.value;
    DateTime urgentDate = taskItem.urgentDate.value;
    DateTime completionDate = taskItem.completionDate.value;
    DateTime now = DateTime.now();

    var dueName = '${taskItem.name.value} (due)';
    if (dueDate != null && completionDate == null && now.isBefore(dueDate)) {
      var taskPayload = 'task:${taskItem.id.value}:due';
      await scheduleNotification(nextId, dueDate, dueName, taskPayload, 'due', removedDue);
      nextId++;
    } else if (removedDue) {
      consoleAndSnack('Notification removed for $dueName');
    }

    var urgentName = '${taskItem.name.value} (urgent)';
    if (urgentDate != null && completionDate == null && now.isBefore(urgentDate)) {
      var taskPayload = 'task:${taskItem.id.value}:urgent';
      await scheduleNotification(nextId, urgentDate, urgentName, taskPayload, 'urgent', removedUrgent);
      nextId++;
    } else if (removedUrgent) {
      consoleAndSnack('Notification removed for $urgentName');
    }
  }

  bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    int diffDays = dateTime1.difference(dateTime2).inDays;
    bool isSame = (diffDays == 0);
    return isSame;
  }

  Future<void> scheduleNotification(int id, DateTime scheduledTime, String name, String payload, String dateType, bool replacingOriginal) async {
    String verificationMessage;
    var opener = replacingOriginal ? 'Replaced' : 'Scheduled';
    if (isSameDay(DateTime.now(), scheduledTime)) {
      var formattedTime = DateFormat.jm().format(scheduledTime);
      verificationMessage = '$opener notification for task $name today at $formattedTime';
    } else {
      var formattedDay = DateFormat.MMMd().format(scheduledTime);
      verificationMessage = '$opener notification for task $name on $formattedDay';
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'taskmaster',
      'TaskMaster',
      'Notifications for the TaskMaster app',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.schedule(
        id,
        name,
        'Task has reached $dateType date',
        scheduledTime,
        platformChannelSpecifics,
        payload: payload,
        androidAllowWhileIdle: true);
    consoleAndSnack(verificationMessage);
  }

  void consoleAndSnack(msg) {
    print(msg);
    /*
    if (homeScreenContext != null) {
      Scaffold.of(homeScreenContext).showSnackBar(SnackBar(
        content: Text(msg),
      ));
    } else {
      print("Weird error: no home screen context for snack bar.");
    }
    */
  }

}
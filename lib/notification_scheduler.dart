import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/task_helper.dart';

class NotificationScheduler {

  final AppState appState;
  final TaskHelper taskHelper;

  final BuildContext context;
  BuildContext homeScreenContext;
  int nextId = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FlutterBadgerWrapper flutterBadgerWrapper;

  NotificationScheduler({
    @required this.context,
    @required this.appState,
    @required this.flutterLocalNotificationsPlugin,
    @required this.flutterBadgerWrapper,
    @required this.taskHelper,
  }) {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    this.flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  void updateHomeScreenContext(BuildContext context) {
    homeScreenContext = context;
  }

  void updateBadge() {
    var numberOfUrgentTasks = _getNumberOfUrgentTasks();
    print('Updating badge with ${numberOfUrgentTasks.toString()} urgent tasks.');
    flutterBadgerWrapper.updateBadgeCount(numberOfUrgentTasks);
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

    var dueName = '${taskItem.name.value} (due)';
    if (dueDate != null && completionDate == null && !taskItem.dueDate.hasPassed()) {
      var taskPayload = 'task:${taskItem.id.value}:due';
      await _scheduleNotification(nextId, dueDate, dueName, taskPayload, 'due', removedDue);
      nextId++;
    } else if (removedDue) {
      _consoleAndSnack('Notification removed for $dueName');
    }

    var urgentName = '${taskItem.name.value} (urgent)';
    if (urgentDate != null && completionDate == null && !taskItem.urgentDate.hasPassed()) {
      var taskPayload = 'task:${taskItem.id.value}:urgent';
      await _scheduleNotification(nextId, urgentDate, urgentName, taskPayload, 'urgent', removedUrgent);
      nextId++;
    } else if (removedUrgent) {
      _consoleAndSnack('Notification removed for $urgentName');
    }
  }



  // Private Methods

  int _getNumberOfUrgentTasks() {
    var urgentTasks = appState.taskItems.where((taskItem) =>
    (taskItem.urgentDate.hasPassed() || taskItem.dueDate.hasPassed()) && taskItem.completionDate.value == null);
    return urgentTasks.length;
  }

  Future<void> _goToDetailScreen({
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
            taskHelper: taskHelper,
          );
        })
    );
  }

  Future<void> _onSelectNotification(String payload) async {
    updateBadge();
    await _goToDetailScreen(payload: payload);
  }

  Future<void> _onDidReceiveLocalNotification(
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
              await _goToDetailScreen(payload: payload, incomingContext: context);
            },
          )
        ],
      ),
    );
  }

  bool _isSameDay(DateTime dateTime1, DateTime dateTime2) {
    int diffDays = dateTime1.difference(dateTime2).inDays;
    bool isSame = (diffDays == 0);
    return isSame;
  }

  Future<void> _scheduleNotification(int id, DateTime scheduledTime, String name, String payload, String dateType, bool replacingOriginal) async {
    String verificationMessage;
    var opener = replacingOriginal ? 'Replaced' : 'Scheduled';
    if (_isSameDay(DateTime.now(), scheduledTime)) {
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
    _consoleAndSnack(verificationMessage);
  }

  void _consoleAndSnack(msg) {
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/sprint.dart';

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
    _configureLocalTimeZone();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );
    this.flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
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
    print('Canceling all existing notifications and rebuilding...');
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

  Future<void> syncNotificationForSprint(Sprint sprint) async {
    String sprintSearch = 'sprint:${sprint.id.value}';
    String sprintName = 'Sprint ' + sprint.id.value.toString();

    var removedDay = false;
    var removedHour = false;
    var removedNow = false;

    print('Attempting to sync notifications for $sprintName.');

    var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    var existing = pendingNotificationRequests.where((notification) => notification.payload.startsWith(sprintSearch));
    existing.forEach((notification) {
      if (notification.payload.endsWith(':day')) {
        removedDay = true;
      }
      if (notification.payload.endsWith(':hour')) {
        removedHour = true;
      }
      if (notification.payload.endsWith(':now')) {
        removedNow = true;
      }
      print('Removing sprint: ${notification.payload}');
      flutterLocalNotificationsPlugin.cancel(notification.id);
    });

    DateTime exactTime = sprint.endDate.value;
    DateTime hourBefore = sprint.endDate.value.subtract(Duration(minutes: 60));
    DateTime dayBefore = sprint.endDate.value?.subtract(Duration(days: 1));

    await scheduleSprintNotification(dayBefore, '$sprintName (day)', 'Current sprint ends in 1 day!', removedDay, '$sprintSearch:day');
    await scheduleSprintNotification(hourBefore, '$sprintName (hour)', 'Current sprint ends in 1 hour!', removedHour, '$sprintSearch:hour');
    await scheduleSprintNotification(exactTime, '$sprintName (now)', 'Current sprint has ended!', removedNow, '$sprintSearch:now');
  }

  Future<void> scheduleSprintNotification(DateTime scheduleTime, String name, String message, bool removed, String sprintPayload) async {
    if (scheduleTime != null && scheduleTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
          nextId, scheduleTime, name, sprintPayload,
          '$name ends in 1 day!', removed);
      nextId++;
    } else if (removed) {
      _consoleAndSnack('Notification removed for $name');
    } else {
      _consoleAndSnack('No existing for $name to remove, and next schedule is before today. Skipping.');
    }
  }

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
      await _scheduleNotification(nextId, dueDate, dueName, taskPayload, 'Task has reached due date', removedDue);
      nextId++;
    } else if (removedDue) {
      _consoleAndSnack('Notification removed for $dueName');
    }

    var urgentName = '${taskItem.name.value} (urgent)';
    if (urgentDate != null && completionDate == null && !taskItem.urgentDate.hasPassed()) {
      var taskPayload = 'task:${taskItem.id.value}:urgent';
      await _scheduleNotification(nextId, urgentDate, urgentName, taskPayload, 'Task has reached urgent date', removedUrgent);
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

  Future<void> _scheduleNotification(int id, DateTime scheduledTime, String name, String payload, String message, bool replacingOriginal) async {
    String verificationMessage;
    var opener = replacingOriginal ? 'Replaced' : 'Scheduled';
    if (_isSameDay(DateTime.now(), scheduledTime)) {
      var formattedTime = DateFormat.jm().format(scheduledTime);
      verificationMessage = '$opener notification for $name today at $formattedTime';
    } else {
      var formattedDay = DateFormat.MMMd().format(scheduledTime);
      verificationMessage = '$opener notification for $name on $formattedDay';
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'taskmaster',
      'TaskMaster',
      'Notifications for the TaskMaster app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        name,
        message,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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
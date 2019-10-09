import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/widgets/second_screen.dart';
import 'package:intl/intl.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class NotificationScheduler {

  BuildContext context;
  BuildContext homeScreenContext;
  int nextId = 0;

  NotificationScheduler(BuildContext context) {
    this.context = context;
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void updateHomeScreenContext(BuildContext context) {
    homeScreenContext = context;
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }


  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> syncNotificationForTask(TaskItem taskItem) async {

    var taskSearch = 'task:${taskItem.id}';
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

    var dueDate = taskItem.dueDate;
    var urgentDate = taskItem.urgentDate;
    var now = DateTime.now();

    var dueName = '${taskItem.name} (due)';
    if (dueDate != null && now.isBefore(dueDate)) {
      var taskPayload = 'task:${taskItem.id}:due';
      await scheduleNotification(nextId, dueDate, dueName, taskPayload, 'due', removedDue);
      nextId++;
    } else if (removedDue) {
      consoleAndSnack('Notification removed for $dueName');
    }

    var urgentName = '${taskItem.name} (urgent)';
    if (urgentDate != null && now.isBefore(urgentDate)) {
      var taskPayload = 'task:${taskItem.id}:urgent';
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
    Scaffold.of(homeScreenContext).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

}
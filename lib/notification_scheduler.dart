import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/widgets/second_screen.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class NotificationScheduler {

  BuildContext context;
  BuildContext homeScreenContext;

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
    var scheduledNotificationDateTime = taskItem.dueDate;
    var now = DateTime.now();

    if (scheduledNotificationDateTime != null && now.isBefore(scheduledNotificationDateTime)) {
      var taskPayload = 'task:${taskItem.id}';

      var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      var existing = pendingNotificationRequests.where((notification) => notification.payload == taskPayload);
      existing.forEach((notification) {
        flutterLocalNotificationsPlugin.cancel(notification.id);
      });

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
          0,
          taskItem.name,
          'Task has reached due date',
          scheduledNotificationDateTime,
          platformChannelSpecifics,
          payload: taskPayload,
          androidAllowWhileIdle: true);
      print('Scheduled notification for task ${taskItem.name} at $scheduledNotificationDateTime');
      Scaffold.of(homeScreenContext).showSnackBar(SnackBar(
        content: Text('Scheduled notification for task ${taskItem.name} at $scheduledNotificationDateTime'),
      ));
    }
  }


  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> _scheduleNotification() async {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
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
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: 'item x',
        androidAllowWhileIdle: true);
  }

}
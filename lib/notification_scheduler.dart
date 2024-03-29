import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/screens/detail_screen.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/timezone_helper.dart';

import 'models/sprint.dart';

class NotificationScheduler {

  final AppState appState;
  final TaskHelper taskHelper;
  final TimezoneHelper timezoneHelper;

  final BuildContext context;
  late BuildContext homeScreenContext;
  int nextId = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FlutterBadgerWrapper flutterBadgerWrapper;

  NotificationScheduler({
    required this.context,
    required this.appState,
    required this.flutterLocalNotificationsPlugin,
    required this.flutterBadgerWrapper,
    required this.taskHelper,
    required this.timezoneHelper,
  }) {
    timezoneHelper.configureLocalTimeZone();

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );
    this.flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification);
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
    var existing = pendingNotificationRequests.where((notification) => notification.payload != null && notification.payload!.startsWith(taskSearch));
    for (PendingNotificationRequest notification in existing) {
      print('Removing task: ${notification.payload}');
      await flutterLocalNotificationsPlugin.cancel(notification.id);
    }
  }

  Future<void> syncNotificationForTasksAndSprint(List<TaskItem> taskItems, Sprint? sprint) async {
    List<PendingNotificationRequest> requests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (sprint != null) {
      await _syncNotificationForSprint(sprint, requests);
    }
    for (TaskItem taskItem in taskItems) {
      await _syncNotificationForTask(taskItem, requests);
    }
  }

  Future<void> updateNotificationForTask(TaskItem taskItem) async {
    List<PendingNotificationRequest> requests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (taskItem.isCompleted()) {
      await cancelNotificationsForTaskId(taskItem.id);
    } else {
      await _syncNotificationForTask(taskItem, requests);
    }
  }


  // Private Methods

  Future<void> _syncNotificationForSprint(Sprint sprint, List<PendingNotificationRequest> requests) async {
    String sprintSearch = 'sprint:${sprint.id}';
    String sprintName = 'Sprint ${sprint.sprintNumber}';

    DateTime exactTime = sprint.endDate;
    DateTime hourBefore = sprint.endDate.subtract(Duration(minutes: 60));
    DateTime dayBefore = sprint.endDate.subtract(Duration(days: 1));

    await _maybeReplaceNotification('$sprintSearch:day', requests, dayBefore, '$sprintName (day)', 'Current sprint ends in 1 day!');
    await _maybeReplaceNotification('$sprintSearch:hour', requests, hourBefore, '$sprintName (hour)', 'Current sprint ends in 1 hour!');
    await _maybeReplaceNotification('$sprintSearch:now', requests, exactTime, '$sprintName (now)', 'Current sprint has ended!');
  }

  Future<void> _syncNotificationForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    await _syncDueNotificationsForTask(taskItem, requests);
    await _syncUrgentNotificationsForTask(taskItem, requests);
  }

  Future<void> _syncUrgentNotificationsForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    DateTime? urgentDate = taskItem.urgentDate;
    DateTime? twoHoursBefore = urgentDate?.subtract(Duration(minutes: 120));

    if (taskItem.completionDate == null) {
      await _maybeReplaceNotification('task:${taskItem.id}:urgentTwoHours', requests, twoHoursBefore, '${taskItem.name} (urgent 2 hours)', 'Two hours until urgent!');
      await _maybeReplaceNotification('task:${taskItem.id}:urgent', requests, urgentDate, '${taskItem.name} (urgent)', 'Task has reached urgent date');
    }
  }

  Future<void> _syncDueNotificationsForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    DateTime? dueDate = taskItem.dueDate;
    DateTime? twoHoursBefore = dueDate?.subtract(Duration(minutes: 120));
    DateTime? oneDayBefore = dueDate?.subtract(Duration(days: 1));

    if (taskItem.completionDate == null) {
      await _maybeReplaceNotification('task:${taskItem.id}:dueOneDay', requests, oneDayBefore, '${taskItem.name} (due 1 day)', 'One day until due!');
      await _maybeReplaceNotification('task:${taskItem.id}:dueTwoHours', requests, twoHoursBefore, '${taskItem.name} (due 2 hours)', 'Two hours until due!');
      await _maybeReplaceNotification('task:${taskItem.id}:due', requests, dueDate, '${taskItem.name} (due)', 'Task has reached due date!');
    }
  }



  Future<bool> _maybeReplaceNotification(String identifier, List<PendingNotificationRequest> requests, DateTime? scheduleDate, String logName, String notificationMessage) async {
    var removed = false;

    var existing = requests.where((notification) => notification.payload == identifier);
    for (PendingNotificationRequest notification in existing) {
      removed = true;
      await flutterLocalNotificationsPlugin.cancel(notification.id);
    }

    // To keep the later dates from cluttering up the notifications, only schedule
    // for the next month. iOS can only have 64 notifications prepared.
    DateTime oneMonthFromNow = DateTime.now().add(Duration(days: 30));

    if (scheduleDate != null &&
        scheduleDate.isAfter(DateTime.now()) &&
        scheduleDate.isBefore(oneMonthFromNow)) {
      await _scheduleNotification(
          nextId, scheduleDate, logName, identifier,
          notificationMessage, removed);
      nextId++;
    } else if (removed) {
      print('Notification removed for $logName');
    }

    return removed;
  }

  int _getNumberOfUrgentTasks() {
    var urgentTasks = appState.taskItems.where((taskItem) =>
    (taskItem.isUrgent() || taskItem.isPastDue()) && taskItem.completionDate == null);
    return urgentTasks.length;
  }

  Future<void> _goToDetailScreen({
    String? payload,
    BuildContext? incomingContext
  }) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);

      var parts = payload.split(":");
      var taskId = int.parse(parts[1]);
      var taskItem = appState.findTaskItemWithId(taskId);

      if (taskItem != null) {
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
    }
  }

  Future<void> _onSelectNotification(NotificationResponse? response) async {
    updateBadge();
    await _goToDetailScreen(payload: response?.payload);
  }

  Future<void> _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
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

  Future<void> _scheduleNotification(int id, DateTime scheduledTime, String name, String payload, String message, bool replacingOriginal) async {
    String verificationMessage;
    var opener = replacingOriginal ? 'Replaced' : 'Scheduled';
    var formattedTime = timezoneHelper.getFormattedLocalTimeFromFormat(scheduledTime, DateFormat.jm());
    if (DateUtil.isSameDay(DateTime.now(), scheduledTime)) {
      verificationMessage = '$opener notification for $name today at $formattedTime';
    } else {
      var formattedDay = timezoneHelper.getFormattedLocalTimeFromFormat(scheduledTime, DateFormat.MMMd());
      verificationMessage = '$opener notification for $name on $formattedDay at $formattedTime';
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'taskmaster',
      'TaskMaster',
      channelDescription: 'Notifications for the TaskMaster app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
    );
    var localTime = timezoneHelper.getLocalTime(scheduledTime);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        name,
        message,
        localTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        androidAllowWhileIdle: true);
    print(verificationMessage);
  }

}
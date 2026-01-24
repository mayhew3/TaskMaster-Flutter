import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../date_util.dart';
import '../../models/sprint.dart';
import '../../models/task_item.dart';

/// Notification scheduling implementation.
/// Wired up via notificationSyncProvider in riverpod_app.dart (TM-314)
class NotificationHelperImpl {
  int nextId = 0;
  final FlutterLocalNotificationsPlugin plugin;

  NotificationHelperImpl({required this.plugin});

  static FlutterLocalNotificationsPlugin initializeNotificationPlugin() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
      // onDidReceiveLocalNotification: _onDidReceiveLocalNotification
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );
    var plugin = FlutterLocalNotificationsPlugin();
    plugin.initialize(initializationSettings,
      // onDidReceiveNotificationResponse: (response) => {}
    );
    // plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    return plugin;
  }

  Future<void> cancelAllNotifications() async {
    print('Canceling all existing notifications and rebuilding...');
    return plugin.cancelAll();
  }

  Future<void> cancelNotificationsForTaskId(String taskId) async {
    var taskSearch = 'task:$taskId';
    var pendingNotificationRequests = await plugin.pendingNotificationRequests();
    var existing = pendingNotificationRequests.where((notification) => notification.payload != null && notification.payload!.startsWith(taskSearch));
    for (PendingNotificationRequest notification in existing) {
      print('Removing task: ${notification.payload}');
      await plugin.cancel(notification.id);
    }
  }

  Future<void> syncNotificationForSprint(Sprint sprint) async {
    List<PendingNotificationRequest> requests = await plugin.pendingNotificationRequests();
    await _syncNotificationForSprint(sprint, requests);
  }

  Future<void> syncNotificationForTasksAndSprint(List<TaskItem> taskItems, Sprint? sprint) async {
    await cancelAllNotifications();
    List<PendingNotificationRequest> requests = await plugin.pendingNotificationRequests();

    if (sprint != null) {
      await _syncNotificationForSprint(sprint, requests);
    }
    for (TaskItem taskItem in taskItems) {
      await _syncNotificationForTask(taskItem, requests);
    }
  }

  Future<void> updateNotificationForTask(TaskItem taskItem) async {
    List<PendingNotificationRequest> requests = await plugin.pendingNotificationRequests();

    if (taskItem.isCompleted() || taskItem.retired != null) {
      await cancelNotificationsForTaskId(taskItem.docId);
    } else {
      await _syncNotificationForTask(taskItem, requests);
    }
  }

  Future<void> _syncNotificationForSprint(Sprint sprint, List<PendingNotificationRequest> requests) async {
    String sprintSearch = 'sprint:${sprint.docId}';
    String sprintName = 'Sprint ${sprint.sprintNumber}';

    DateTime exactTime = sprint.endDate;
    DateTime hourBefore = sprint.endDate.subtract(Duration(minutes: 60));
    DateTime dayBefore = sprint.endDate.subtract(Duration(days: 1));

    await _maybeReplaceNotification('$sprintSearch:day', requests, dayBefore, '$sprintName (day)', 'Current sprint ends in 1 day!');
    await _maybeReplaceNotification('$sprintSearch:hour', requests, hourBefore, '$sprintName (hour)', 'Current sprint ends in 1 hour!');
    await _maybeReplaceNotification('$sprintSearch:now', requests, exactTime, '$sprintName (now)', 'Current sprint has ended!');
  }

  Future<bool> _maybeReplaceNotification(
      String identifier,
      List<PendingNotificationRequest> requests,
      DateTime? scheduleDate,
      String logName,
      String notificationMessage,
      ) async {
    var removed = false;

    var existing = requests.where((notification) => notification.payload == identifier);
    for (PendingNotificationRequest notification in existing) {
      removed = true;
      await plugin.cancel(notification.id);
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

  Future<void> _syncNotificationForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    await _syncDueNotificationsForTask(taskItem, requests);
    await _syncUrgentNotificationsForTask(taskItem, requests);
  }

  Future<void> _syncUrgentNotificationsForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    DateTime? urgentDate = taskItem.urgentDate;
    DateTime? twoHoursBefore = urgentDate?.subtract(Duration(minutes: 120));

    if (taskItem.completionDate == null) {
      await _maybeReplaceNotification('task:${taskItem.docId}:urgentTwoHours', requests, twoHoursBefore, '${taskItem.name} (urgent 2 hours)', 'Two hours until urgent!');
      await _maybeReplaceNotification('task:${taskItem.docId}:urgent', requests, urgentDate, '${taskItem.name} (urgent)', 'Task has reached urgent date');
    }
  }

  Future<void> _syncDueNotificationsForTask(TaskItem taskItem, List<PendingNotificationRequest> requests) async {
    DateTime? dueDate = taskItem.dueDate;
    DateTime? twoHoursBefore = dueDate?.subtract(Duration(minutes: 120));
    DateTime? oneDayBefore = dueDate?.subtract(Duration(days: 1));

    if (taskItem.completionDate == null) {
      await _maybeReplaceNotification('task:${taskItem.docId}:dueOneDay', requests, oneDayBefore, '${taskItem.name} (due 1 day)', 'One day until due!');
      await _maybeReplaceNotification('task:${taskItem.docId}:dueTwoHours', requests, twoHoursBefore, '${taskItem.name} (due 2 hours)', 'Two hours until due!');
      await _maybeReplaceNotification('task:${taskItem.docId}:due', requests, dueDate, '${taskItem.name} (due)', 'Task has reached due date!');
    }
  }

  Future<void> _scheduleNotification(
      int id,
      DateTime scheduledTime,
      String name,
      String payload,
      String message,
      bool replacingOriginal,
      ) async {
    String verificationMessage;
    var opener = replacingOriginal ? 'Replaced' : 'Scheduled';
    var formattedTime = DateFormat.jm().format(scheduledTime.toLocal());
    if (DateUtil.isSameDay(DateTime.now(), scheduledTime)) {
      verificationMessage = '$opener notification for $name today at $formattedTime';
    } else {
      var formattedDay = DateFormat.MMMd().format(scheduledTime.toLocal());
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
    var localTime = tz.TZDateTime.from(scheduledTime, tz.local);
    await plugin.zonedSchedule(
        id,
        name,
        message,
        localTime,
        platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exact);
    print(verificationMessage);
  }


}
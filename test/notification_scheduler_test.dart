import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/app_state.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_app_state.dart';

import 'package:mockito/mockito.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_pending_notification_request.dart';

class MockAppBadger extends Mock implements FlutterBadgerWrapper {
  int badgeValue = 0;

  @override
  void updateBadgeCount(int count) {
    badgeValue = count;
  }
}

void main() {

  MockFlutterLocalNotificationsPlugin plugin;
  MockAppBadger flutterBadgerWrapper;
  AppState appState;

  TaskItem futureUrgentDue;
  TaskItem pastUrgentDue;

  setUp(() {
    futureUrgentDue = TaskItem();
    futureUrgentDue.id.initializeValue(30);
    futureUrgentDue.name.initializeValue('Give a Penny');
    futureUrgentDue.dueDate.initializeValue(DateTime.now().add(Duration(days: 4)));
    futureUrgentDue.urgentDate.initializeValue(DateTime.now().add(Duration(days: 2)));

    pastUrgentDue = TaskItem();
    pastUrgentDue.id.initializeValue(30);
    pastUrgentDue.name.initializeValue('Take a Penny');
    pastUrgentDue.dueDate.initializeValue(DateTime.now().subtract(Duration(days: 2)));
    pastUrgentDue.urgentDate.initializeValue(DateTime.now().subtract(Duration(days: 4)));
  });

  Future<NotificationScheduler> _createScheduler(List<TaskItem> taskItems) async {
    plugin = MockFlutterLocalNotificationsPlugin();
    flutterBadgerWrapper = MockAppBadger();
    appState = MockAppState(taskItems: taskItems);

    var notificationScheduler = new NotificationScheduler(
      context: null,
      appState: appState,
      taskAdder: (taskItem) => {},
      taskUpdater: (taskItem) => Future.value(taskItem),
      taskCompleter: (taskItem, completed) => Future.value(taskItem),
      flutterLocalNotificationsPlugin: plugin,
      flutterBadgerWrapper: flutterBadgerWrapper,
    );
    List<Future<void>> futures = [];
    appState.taskItems.forEach((taskItem) =>
      futures.add(notificationScheduler.syncNotificationForTask(taskItem))
    );
    await Future.wait(futures);

    return notificationScheduler;
  }

  test('construct with empty list', () {
    _createScheduler([]);
    expect(plugin.pendings.length, 0);
  });

  test('syncNotificationForTask first add', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.syncNotificationForTask(birthdayTask);
    expect(plugin.pendings.length, 1);
    MockPendingNotificationRequest request = plugin.pendings[0];
    expect(request.id, isNot(null));
    expect(request.payload, 'task:${birthdayTask.id.value}:due');
  });

  test('syncNotificationForTask adds nothing if no urgent or due date', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.syncNotificationForTask(pastTask);
    expect(plugin.pendings.length, 0);
  });

  test('syncNotificationForTask adds nothing if urgent and due date are past', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.syncNotificationForTask(pastUrgentDue);
    expect(plugin.pendings.length, 0);
  });

  test('syncNotificationForTask adds two notifications for urgent and due date', () async {
    var scheduler = await _createScheduler([]);

    await scheduler.syncNotificationForTask(futureUrgentDue);
    expect(plugin.pendings.length, 2);

    var duePayload = 'task:${futureUrgentDue.id.value}:due';
    var urgentPayload = 'task:${futureUrgentDue.id.value}:urgent';

    var dueNotification = plugin.pendings.singleWhere((notification) => notification.payload == duePayload);
    var urgentNotification = plugin.pendings.singleWhere((notification) => notification.payload == urgentPayload);

    expect(dueNotification, isNot(null));
    expect(urgentNotification, isNot(null));
    expect(dueNotification.id, isNot(urgentNotification.id));
  });

  test('cancelNotificationsForTaskId', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.syncNotificationForTask(birthdayTask);
    expect(plugin.pendings.length, 1);
    await scheduler.cancelNotificationsForTaskId(birthdayTask.id.value);
    expect(plugin.pendings.length, 0);
  });

  test('cancelAllNotifications', () async {
    var scheduler = await _createScheduler([futureUrgentDue, birthdayTask]);
    expect(plugin.pendings.length, 3);
    await scheduler.cancelAllNotifications();
    expect(plugin.pendings.length, 0);
  });

  test('updateBadge', () async {
    var scheduler = await _createScheduler([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge excludes completed', () async {
    pastUrgentDue.completionDate.initializeValue(DateTime.now());
    var scheduler = await _createScheduler([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 0);
  });

}
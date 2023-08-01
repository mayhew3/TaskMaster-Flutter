import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_build_context.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_pending_notification_request.dart';
import 'mocks/mock_timezone_helper.dart';
import 'notification_scheduler_test.mocks.dart';
import 'test_mock_helper.dart';

class MockAppBadger extends Fake implements FlutterBadgerWrapper {
  int badgeValue = 0;

  @override
  void updateBadgeCount(int count) {
    badgeValue = count;
  }
}

@GenerateNiceMocks([MockSpec<AppState>(), MockSpec<TaskRepository>(), MockSpec<TaskHelper>()])
void main() {

  late MockFlutterLocalNotificationsPlugin plugin;
  late MockAppBadger flutterBadgerWrapper;
  late MockAppState appState;
  late MockTaskHelper taskHelper;
  late MockTimezoneHelper timezoneHelper;
  late MockTaskRepository taskRepository;

  late TaskItem futureDue;
  late TaskItem futureUrgentDue;
  late TaskItem pastUrgentDue;
  late TaskItem straddledUrgentDue;

  setUp(() {
    futureDue = TaskItem(
        id: 30,
        personId: 1,
        name: 'Barf a Penny',
        dueDate: DateTime.now().add(Duration(days: 4)));

    futureUrgentDue = TaskItem(
        id: 31,
        personId: 1,
        name: 'Give a Penny',
        dueDate: DateTime.now().add(Duration(days: 4)),
        urgentDate: DateTime.now().add(Duration(days: 2))
    );

    pastUrgentDue = TaskItem(
        id: 32,
        personId: 1,
        name: 'Take a Penny',
        dueDate: DateTime.now().subtract(Duration(days: 2)),
        urgentDate: DateTime.now().subtract(Duration(days: 4))
    );

    straddledUrgentDue = TaskItem(
        id: 33,
        personId: 1,
        name: 'Eat a Penny',
        dueDate: DateTime.now().add(Duration(days: 7)),
        urgentDate: DateTime.now().subtract(Duration(days: 5))
    );
  });

  Future<NotificationScheduler> _createScheduler(List<TaskItem> taskItems) async {
    plugin = MockFlutterLocalNotificationsPlugin();
    flutterBadgerWrapper = MockAppBadger();
    appState = MockAppState();
    when(appState.taskItems).thenReturn(taskItems);
    taskHelper = MockTaskHelper();
    taskRepository = MockTaskRepository();
    when(taskHelper.repository).thenReturn(taskRepository);
    timezoneHelper = new MockTimezoneHelper();

    var notificationScheduler = new NotificationScheduler(
      context: new MockBuildContext(),
      taskHelper: taskHelper,
      flutterLocalNotificationsPlugin: plugin,
      flutterBadgerWrapper: flutterBadgerWrapper,
      timezoneHelper: timezoneHelper,
    );
    notificationScheduler.appState = appState;
    List<Future<void>> futures = [];
    taskItems.forEach((taskItem) =>
      futures.add(notificationScheduler.updateNotificationForTask(taskItem))
    );
    await Future.wait(futures);

    return notificationScheduler;
  }


  // helper methods

  void _verifyDueNotificationsExist(List<MockPendingNotificationRequest> requests, TaskItem taskItem) {
    var dueDate = taskItem.dueDate;
    DateTime? twoHoursBefore = dueDate?.subtract(Duration(minutes: 120));
    DateTime? oneDayBefore = dueDate?.subtract(Duration(days: 1));

    var dueRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.id}:due');
    expect(dueRequest, isNot(null));
    expect(dueRequest.notificationDate, dueDate?.toLocal());
    expect(dueRequest.title, '${taskItem.name} (due)');

    var twoHourRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.id}:dueTwoHours');
    expect(twoHourRequest, isNot(null));
    expect(twoHourRequest.notificationDate, twoHoursBefore?.toLocal());
    expect(twoHourRequest.title, '${taskItem.name} (due 2 hours)');

    var oneDayRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.id}:dueOneDay');
    expect(oneDayRequest, isNot(null));
    expect(oneDayRequest.notificationDate, oneDayBefore?.toLocal());
    expect(oneDayRequest.title, '${taskItem.name} (due 1 day)');
  }

  void _verifyUrgentNotificationsExist(List<MockPendingNotificationRequest> requests, TaskItem taskItem) {
    var urgentDate = taskItem.urgentDate;
    DateTime? twoHoursBefore = urgentDate?.subtract(Duration(minutes: 120));

    var urgentRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.id}:urgent');
    expect(urgentRequest, isNot(null));
    expect(urgentRequest.notificationDate, urgentDate);
    expect(urgentRequest.title, '${taskItem.name} (urgent)');

    var twoHourRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.id}:urgentTwoHours');
    expect(twoHourRequest, isNot(null));
    expect(twoHourRequest.notificationDate, twoHoursBefore);
    expect(twoHourRequest.title, '${taskItem.name} (urgent 2 hours)');

  }


  // test methods

  test('construct with empty list', () {
    _createScheduler([]);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask first add', () async {
    var taskItem = birthdayTask;
    var scheduler = await _createScheduler([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask adds nothing if no urgent or due date', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.updateNotificationForTask(pastTask);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds nothing if urgent and due date are past', () async {
    var scheduler = await _createScheduler([]);
    await scheduler.updateNotificationForTask(pastUrgentDue);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds five notifications for urgent and due date', () async {
    var scheduler = await _createScheduler([]);

    await scheduler.updateNotificationForTask(futureUrgentDue);
    expect(plugin.pendings.length, 5);

    _verifyDueNotificationsExist(plugin.pendings, futureUrgentDue);
    _verifyUrgentNotificationsExist(plugin.pendings, futureUrgentDue);
  });

  test('updateNotificationForTask adds three notification for past urgent and future due date', () async {
    var taskItem = straddledUrgentDue;

    var scheduler = await _createScheduler([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask replaces old due notification', () async {
    var taskItem = futureDue;

    var scheduler = await _createScheduler([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createCreateBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 8));
    var edited = TestMockHelper.mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, edited);
  });

  test('updateNotificationForTask removes old due notification if due date moved back', () async {
    var taskItem = futureDue;

    var scheduler = await _createScheduler([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createCreateBlueprint();
    blueprint.dueDate = DateTime.now().subtract(Duration(days: 8));
    var edited = TestMockHelper.mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask replaces old urgent and due notifications', () async {
    var taskItem = futureUrgentDue;

    var scheduler = await _createScheduler([taskItem]);
    expect(plugin.pendings.length, 5);

    var blueprint = taskItem.createCreateBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 12));
    blueprint.urgentDate = DateTime.now().add(Duration(days: 4));
    var edited = TestMockHelper.mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 5);

    _verifyDueNotificationsExist(plugin.pendings, edited);
    _verifyUrgentNotificationsExist(plugin.pendings, edited);
  });

  test('cancelNotificationsForTaskId cancels due notification', () async {
    var taskItem = futureDue;
    var scheduler = await _createScheduler([taskItem]);
    expect(plugin.pendings.length, 3);
    await scheduler.cancelNotificationsForTaskId(taskItem.id);
    expect(plugin.pendings.length, 0);
  });

  test('cancelNotificationsForTaskId cancels both urgent and due', () async {
    var taskItem = futureUrgentDue;
    var scheduler = await _createScheduler([taskItem]);
    expect(plugin.pendings.length, 5);
    await scheduler.cancelNotificationsForTaskId(taskItem.id);
    expect(plugin.pendings.length, 0);
  });

  test('cancelAllNotifications', () async {
    var scheduler = await _createScheduler([futureUrgentDue, birthdayTask]);
    expect(plugin.pendings.length, 8);
    await scheduler.cancelAllNotifications();
    expect(plugin.pendings.length, 0);
  });

  test('updateBadge', () async {
    var scheduler = await _createScheduler([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge includes task with past urgent and future due', () async {
    var scheduler = await _createScheduler([straddledUrgentDue]);
    expect(plugin.pendings.length, 3);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge includes only one task with past urgent and past due', () async {
    var scheduler = await _createScheduler([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge excludes completed', () async {
    var blueprint = pastUrgentDue.createCreateBlueprint();
    blueprint.completionDate = DateTime.now();
    var edited = TestMockHelper.mockEditTask(pastUrgentDue, blueprint);

    var scheduler = await _createScheduler([edited]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 0);
  });


}
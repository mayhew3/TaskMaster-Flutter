// import 'package:mockito/annotations.dart';
// import 'package:taskmaster/flutter_badger_wrapper.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
// import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/timezone_helper.dart';
// import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_pending_notification_request.dart';
import 'mocks/mock_timezone_helper.dart';
/*

class MockAppBadger extends Fake implements FlutterBadgerWrapper {
  int badgeValue = 0;

  @override
  void updateBadgeCount(int count) {
    badgeValue = count;
  }
}
*/

// @GenerateNiceMocks([MockSpec<AppState>(), MockSpec<TaskRepository>()])
void main() {

  late MockFlutterLocalNotificationsPlugin plugin;
  late TimezoneHelper timezoneHelper;

  late TaskItem futureDue;
  late TaskItem futureUrgentDue;
  late TaskItem pastUrgentDue;
  late TaskItem straddledUrgentDue;

  setUp(() {
    futureDue = TaskItem((t) => t
      ..id = 30
      ..personId = 1
      ..name = 'Barf a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 4)));

    futureUrgentDue = TaskItem((t) => t
      ..id = 31
      ..personId = 1
      ..name = 'Give a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 4))
      ..urgentDate = DateTime.now().add(Duration(days: 2))
    );

    pastUrgentDue = TaskItem((t) => t
      ..id = 32
      ..personId = 1
      ..name = 'Take a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().subtract(Duration(days: 2))
      ..urgentDate = DateTime.now().subtract(Duration(days: 4))
    );

    straddledUrgentDue = TaskItem((t) => t
      ..id = 33
      ..personId = 1
      ..name = 'Eat a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 7))
      ..urgentDate = DateTime.now().subtract(Duration(days: 5))
    );
  });

  Future<NotificationHelper> _createHelper(List<TaskItem> taskItems) async {
    plugin = MockFlutterLocalNotificationsPlugin();
    timezoneHelper = new MockTimezoneHelper();
    await timezoneHelper.configureLocalTimeZone();

    var notificationScheduler = new NotificationHelper(
      plugin: plugin,
      timezoneHelper: timezoneHelper,
    );
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

  TaskItem mockEditTask(TaskItem original, TaskItemBlueprint blueprint) {
    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    var recurrence = original.recurrence;
    TaskRecurrence? recurrenceCopy;
    if (recurrenceBlueprint != null && recurrence != null) {
      recurrenceCopy = new TaskRecurrence((r) => r
        ..id = recurrence.id
        ..personId = recurrence.personId
        ..name = recurrenceBlueprint.name ?? recurrence.name
        ..recurNumber = recurrenceBlueprint.recurNumber ?? recurrence.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit ?? recurrence.name
        ..recurWait = recurrenceBlueprint.recurWait ?? recurrence.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration ?? recurrence.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate ?? recurrence.anchorDate
        ..anchorType = recurrenceBlueprint.anchorType ?? recurrence.anchorType);
    }

    TaskItem taskItem = new TaskItem((t) => t
      ..name = original.name
      ..id = original.id
      ..personId = 1
      ..description = blueprint.description
      ..project = blueprint.project
      ..context = blueprint.context
      ..urgency = blueprint.urgency
      ..priority = blueprint.priority
      ..duration = blueprint.duration
      ..gamePoints = blueprint.gamePoints
      ..startDate = blueprint.startDate
      ..targetDate = blueprint.targetDate
      ..urgentDate = blueprint.urgentDate
      ..dueDate = blueprint.dueDate
      ..completionDate = blueprint.completionDate
      ..offCycle = blueprint.offCycle
      ..recurNumber = blueprint.recurNumber
      ..recurUnit = blueprint.recurUnit
      ..recurWait = blueprint.recurWait
      ..recurrenceId = blueprint.recurrenceId
      ..recurIteration = blueprint.recurIteration
      ..recurrence = recurrenceCopy?.toBuilder()
    );

    return taskItem;
  }


  // test methods

  test('construct with empty list', () {
    _createHelper([]);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask first add', () async {
    var taskItem = birthdayTask;
    var scheduler = await _createHelper([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask adds nothing if no urgent or due date', () async {
    var scheduler = await _createHelper([]);
    await scheduler.updateNotificationForTask(pastTask);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds nothing if urgent and due date are past', () async {
    var scheduler = await _createHelper([]);
    await scheduler.updateNotificationForTask(pastUrgentDue);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds five notifications for urgent and due date', () async {
    var scheduler = await _createHelper([]);

    await scheduler.updateNotificationForTask(futureUrgentDue);
    expect(plugin.pendings.length, 5);

    _verifyDueNotificationsExist(plugin.pendings, futureUrgentDue);
    _verifyUrgentNotificationsExist(plugin.pendings, futureUrgentDue);
  });

  test('updateNotificationForTask adds three notification for past urgent and future due date', () async {
    var taskItem = straddledUrgentDue;

    var scheduler = await _createHelper([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask replaces old due notification', () async {
    var taskItem = futureDue;

    var scheduler = await _createHelper([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 8));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 3);

    _verifyDueNotificationsExist(plugin.pendings, edited);
  });

  test('updateNotificationForTask removes old due notification if due date moved back', () async {
    var taskItem = futureDue;

    var scheduler = await _createHelper([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().subtract(Duration(days: 8));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask replaces old urgent and due notifications', () async {
    var taskItem = futureUrgentDue;

    var scheduler = await _createHelper([taskItem]);
    expect(plugin.pendings.length, 5);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 12));
    blueprint.urgentDate = DateTime.now().add(Duration(days: 4));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 5);

    _verifyDueNotificationsExist(plugin.pendings, edited);
    _verifyUrgentNotificationsExist(plugin.pendings, edited);
  });

  test('cancelNotificationsForTaskId cancels due notification', () async {
    var taskItem = futureDue;
    var scheduler = await _createHelper([taskItem]);
    expect(plugin.pendings.length, 3);
    await scheduler.cancelNotificationsForTaskId(taskItem.id);
    expect(plugin.pendings.length, 0);
  });

  test('cancelNotificationsForTaskId cancels both urgent and due', () async {
    var taskItem = futureUrgentDue;
    var scheduler = await _createHelper([taskItem]);
    expect(plugin.pendings.length, 5);
    await scheduler.cancelNotificationsForTaskId(taskItem.id);
    expect(plugin.pendings.length, 0);
  });

  test('cancelAllNotifications', () async {
    var scheduler = await _createHelper([futureUrgentDue, birthdayTask]);
    expect(plugin.pendings.length, 8);
    await scheduler.cancelAllNotifications();
    expect(plugin.pendings.length, 0);
  });
/*

  test('updateBadge', () async {
    var scheduler = await _createHelper([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge includes task with past urgent and future due', () async {
    var scheduler = await _createHelper([straddledUrgentDue]);
    expect(plugin.pendings.length, 3);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge includes only one task with past urgent and past due', () async {
    var scheduler = await _createHelper([pastUrgentDue]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 1);
  });

  test('updateBadge excludes completed', () async {
    var blueprint = pastUrgentDue.createBlueprint();
    blueprint.completionDate = DateTime.now();
    var edited = TestMockHelper.mockEditTask(pastUrgentDue, blueprint);

    var scheduler = await _createHelper([edited]);
    expect(plugin.pendings.length, 0);
    scheduler.updateBadge();
    expect(flutterBadgerWrapper.badgeValue, 0);
  });
*/


}
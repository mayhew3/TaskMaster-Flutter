import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_pending_notification_request.dart';
import 'mocks/mock_timezone_helper.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late TimezoneHelper timezoneHelper;

  late TaskItem futureDue;
  late TaskItem futureUrgentDue;
  late TaskItem pastUrgentDue;
  late TaskItem straddledUrgentDue;

  setUp(() {
    futureDue = TaskItem((t) => t
      ..docId = '30'
      ..dateAdded = DateTime.now().toUtc()
      ..personDocId = MockTaskItemBuilder.me
      ..name = 'Barf a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 4)));

    futureUrgentDue = TaskItem((t) => t
      ..docId = '31'
      ..dateAdded = DateTime.now().toUtc()
      ..personDocId = MockTaskItemBuilder.me
      ..name = 'Give a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 4))
      ..urgentDate = DateTime.now().add(Duration(days: 2))
    );

    pastUrgentDue = TaskItem((t) => t
      ..docId = '32'
      ..dateAdded = DateTime.now().toUtc()
      ..personDocId = MockTaskItemBuilder.me
      ..name = 'Take a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().subtract(Duration(days: 2))
      ..urgentDate = DateTime.now().subtract(Duration(days: 4))
    );

    straddledUrgentDue = TaskItem((t) => t
      ..docId = '33'
      ..dateAdded = DateTime.now().toUtc()
      ..personDocId = MockTaskItemBuilder.me
      ..name = 'Eat a Penny'
      ..offCycle = false
      ..dueDate = DateTime.now().add(Duration(days: 7))
      ..urgentDate = DateTime.now().subtract(Duration(days: 5))
    );
  });

  Future<NotificationHelper> createHelper(List<TaskItem> taskItems) async {
    plugin = MockFlutterLocalNotificationsPlugin();
    timezoneHelper = MockTimezoneHelper();
    await timezoneHelper.configureLocalTimeZone();

    var notificationScheduler = NotificationHelper(
      plugin: plugin,
      timezoneHelper: timezoneHelper,
    );
    List<Future<void>> futures = [];
    for (var taskItem in taskItems) {
      futures.add(notificationScheduler.updateNotificationForTask(taskItem));
    }
    await Future.wait(futures);

    return notificationScheduler;
  }


  // helper methods

  void verifyDueNotificationsExist(List<MockPendingNotificationRequest> requests, TaskItem taskItem) {
    var dueDate = taskItem.dueDate;
    DateTime? twoHoursBefore = dueDate?.subtract(Duration(minutes: 120));
    DateTime? oneDayBefore = dueDate?.subtract(Duration(days: 1));

    var dueRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.docId}:due');
    expect(dueRequest.notificationDate, dueDate?.toLocal());
    expect(dueRequest.title, '${taskItem.name} (due)');

    var twoHourRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.docId}:dueTwoHours');
    expect(twoHourRequest.notificationDate, twoHoursBefore?.toLocal());
    expect(twoHourRequest.title, '${taskItem.name} (due 2 hours)');

    var oneDayRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.docId}:dueOneDay');
    expect(oneDayRequest.notificationDate, oneDayBefore?.toLocal());
    expect(oneDayRequest.title, '${taskItem.name} (due 1 day)');
  }

  void verifyUrgentNotificationsExist(List<MockPendingNotificationRequest> requests, TaskItem taskItem) {
    var urgentDate = taskItem.urgentDate;
    DateTime? twoHoursBefore = urgentDate?.subtract(Duration(minutes: 120));

    var urgentRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.docId}:urgent');
    expect(urgentRequest.notificationDate, urgentDate);
    expect(urgentRequest.title, '${taskItem.name} (urgent)');

    var twoHourRequest = requests.singleWhere((notification) => notification.payload == 'task:${taskItem.docId}:urgentTwoHours');
    expect(twoHourRequest.notificationDate, twoHoursBefore);
    expect(twoHourRequest.title, '${taskItem.name} (urgent 2 hours)');

  }

  TaskItem mockEditTask(TaskItem original, TaskItemBlueprint blueprint) {
    var recurrenceBlueprint = blueprint.recurrenceBlueprint;
    var recurrence = original.recurrence;
    TaskRecurrence? recurrenceCopy;
    if (recurrenceBlueprint != null && recurrence != null) {
      recurrenceCopy = TaskRecurrence((r) => r
        ..docId = recurrence.docId
        ..personDocId = recurrence.personDocId
        ..name = recurrenceBlueprint.name ?? recurrence.name
        ..recurNumber = recurrenceBlueprint.recurNumber ?? recurrence.recurNumber
        ..recurUnit = recurrenceBlueprint.recurUnit ?? recurrence.name
        ..recurWait = recurrenceBlueprint.recurWait ?? recurrence.recurWait
        ..recurIteration = recurrenceBlueprint.recurIteration ?? recurrence.recurIteration
        ..anchorDate = recurrenceBlueprint.anchorDate ?? recurrence.anchorDate
        ..anchorType = recurrenceBlueprint.anchorType ?? recurrence.anchorType);
    }

    TaskItem taskItem = TaskItem((t) => t
      ..name = original.name
      ..docId = original.docId
      ..dateAdded = original.dateAdded
      ..personDocId = MockTaskItemBuilder.me
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
      ..recurrenceDocId = blueprint.recurrenceDocId
      ..recurIteration = blueprint.recurIteration
      ..recurrence = recurrenceCopy?.toBuilder()
    );

    return taskItem;
  }


  // test methods

  test('construct with empty list', () {
    createHelper([]);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask first add', () async {
    var taskItem = birthdayTask;
    var scheduler = await createHelper([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask adds nothing if no urgent or due date', () async {
    var scheduler = await createHelper([]);
    await scheduler.updateNotificationForTask(pastTask);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds nothing if urgent and due date are past', () async {
    var scheduler = await createHelper([]);
    await scheduler.updateNotificationForTask(pastUrgentDue);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask adds five notifications for urgent and due date', () async {
    var scheduler = await createHelper([]);

    await scheduler.updateNotificationForTask(futureUrgentDue);
    expect(plugin.pendings.length, 5);

    verifyDueNotificationsExist(plugin.pendings, futureUrgentDue);
    verifyUrgentNotificationsExist(plugin.pendings, futureUrgentDue);
  });

  test('updateNotificationForTask adds three notification for past urgent and future due date', () async {
    var taskItem = straddledUrgentDue;

    var scheduler = await createHelper([]);
    await scheduler.updateNotificationForTask(taskItem);
    expect(plugin.pendings.length, 3);

    verifyDueNotificationsExist(plugin.pendings, taskItem);
  });

  test('updateNotificationForTask replaces old due notification', () async {
    var taskItem = futureDue;

    var scheduler = await createHelper([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 8));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 3);

    verifyDueNotificationsExist(plugin.pendings, edited);
  });

  test('updateNotificationForTask removes old due notification if due date moved back', () async {
    var taskItem = futureDue;

    var scheduler = await createHelper([taskItem]);
    expect(plugin.pendings.length, 3);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().subtract(Duration(days: 8));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 0);
  });

  test('updateNotificationForTask replaces old urgent and due notifications', () async {
    var taskItem = futureUrgentDue;

    var scheduler = await createHelper([taskItem]);
    expect(plugin.pendings.length, 5);

    var blueprint = taskItem.createBlueprint();
    blueprint.dueDate = DateTime.now().add(Duration(days: 12));
    blueprint.urgentDate = DateTime.now().add(Duration(days: 4));
    var edited = mockEditTask(taskItem, blueprint);

    await scheduler.updateNotificationForTask(edited);
    expect(plugin.pendings.length, 5);

    verifyDueNotificationsExist(plugin.pendings, edited);
    verifyUrgentNotificationsExist(plugin.pendings, edited);
  });

  test('cancelNotificationsForTaskId cancels due notification', () async {
    var taskItem = futureDue;
    var scheduler = await createHelper([taskItem]);
    expect(plugin.pendings.length, 3);
    await scheduler.cancelNotificationsForTaskId(taskItem.docId);
    expect(plugin.pendings.length, 0);
  });

  test('cancelNotificationsForTaskId cancels both urgent and due', () async {
    var taskItem = futureUrgentDue;
    var scheduler = await createHelper([taskItem]);
    expect(plugin.pendings.length, 5);
    await scheduler.cancelNotificationsForTaskId(taskItem.docId);
    expect(plugin.pendings.length, 0);
  });

  test('cancelAllNotifications', () async {
    var scheduler = await createHelper([futureUrgentDue, birthdayTask]);
    expect(plugin.pendings.length, 8);
    await scheduler.cancelAllNotifications();
    expect(plugin.pendings.length, 0);
  });

}
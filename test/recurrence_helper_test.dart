
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_timezone_helper.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';


@GenerateNiceMocks([MockSpec<TaskRepository>(), MockSpec<Store>(), MockSpec<NotificationHelper>(),
  MockSpec<AppState>(), MockSpec<GlobalKey<NavigatorState>>(), MockSpec<NavigatorState>()])
void main() {

  MockTaskRepository taskRepository = MockTaskRepository();
  MockFlutterLocalNotificationsPlugin plugin = MockFlutterLocalNotificationsPlugin();
  MockTimezoneHelper timezoneHelper = MockTimezoneHelper();
  MockStore<AppState> store = MockStore<AppState>();
  MockAppState appState = MockAppState();
  MockNotificationHelper mockNotificationHelper = MockNotificationHelper();
  MockGlobalKey mockGlobalKey = MockGlobalKey();
  var mockNavigatorState = MockNavigatorState();

  // MockNotificationScheduler notificationScheduler = new MockNotificationScheduler();
  // StateSetter stateSetter = (callback) => callback();

  TaskItem mockComplete(TaskItem taskItem, DateTime? completionDate) {
    return taskItem.rebuild((t) => t.completionDate = completionDate);
  }

  void prepareMocks({List<TaskItem>? taskItems, List<Sprint>? sprints, List<TaskRecurrence>? recurrences}) {

    timezoneHelper.configureLocalTimeZone();
    provideDummy<AppState>(appState);

    when(store.state).thenReturn(appState);

    when(appState.personDocId).thenAnswer((_) => MockTaskItemBuilder.me);
    when(appState.timezoneHelper).thenAnswer((_) => timezoneHelper);
    when(appState.notificationHelper).thenAnswer((_) => mockNotificationHelper);

    when(appState.taskItems).thenAnswer((_) => taskItems?.toBuiltList() ?? BuiltList<TaskItem>());
    when(appState.sprints).thenAnswer((_) => sprints?.toBuiltList() ?? BuiltList<Sprint>());
    when(appState.taskRecurrences).thenAnswer((_) => recurrences?.toBuiltList() ?? BuiltList<TaskRecurrence>());

    when(mockGlobalKey.currentState).thenAnswer((_) => mockNavigatorState);
    when(mockNavigatorState.pushReplacementNamed(any)).thenAnswer((t) => Future.value(t));
/*

    when(taskRepository.completeTask(argThat(isA<TaskItem>()), argThat(isA<DateTime?>()))).thenAnswer((invocation) {
      TaskItem originalTask = invocation.positionalArguments[0];
      DateTime? completionDate = invocation.positionalArguments[1];
      TaskItem inboundTask = _mockComplete(originalTask, completionDate);
      return Future.value(inboundTask);
    });
    when(taskRepository.updateTaskRecurrence(argThat(isA<TaskRecurrencePreview>()))).thenAnswer((invocation) {
      TaskRecurrencePreview original = invocation.positionalArguments[0];
      return Future.value(TaskRecurrence(
          id: original.id,
          personDocId: original.personDocId,
          name: original.name,
          recurNumber: original.recurNumber,
          recurUnit: original.recurUnit,
          recurWait: original.recurWait,
          recurIteration: original.recurIteration,
          anchorDate: original.anchorDate,
          anchorType: original.anchorType));
    });
    when(taskRepository.addTaskIteration(argThat(isA<TaskItemPreview>()), any)).thenAnswer((invocation) {
      TaskItemPreview addedTask = invocation.positionalArguments[0];
      return Future.value(TestMockHelper.mockAddTask(addedTask, appState.taskItems.length + 1));
    });
*/

  }

  test('previewSnooze moves target and due dates', () {
    var blueprint = MockTaskItemBuilder.withDates()
      .create().createBlueprint();

    var originalTarget = blueprint.targetDate!;
    var originalDue = blueprint.dueDate!;

    RecurrenceHelper.generatePreview(blueprint, 6, 'Days', TaskDateTypes.target);

    var newTarget = DateUtil.withoutMillis(blueprint.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
    expect(newTarget.hour, originalTarget.hour, reason: 'Expect hour of target date to be unchanged.');

    var newDue = DateUtil.withoutMillis(blueprint.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be in 13 days.');
    expect(newDue.hour, originalDue.hour, reason: 'Expect hour of due date to be unchanged.');

  });

/*

  test('previewSnooze on task without a start date adds a start date', () {
    var taskItem = TaskItemBuilder
        .asDefault()
        .create().createBlueprint();

    var taskHelper = createTaskHelper();

    taskHelper.previewSnooze(taskItem, 4, 'Days', TaskDateTypes.start);

    var newStart = DateUtil.withoutMillis(taskItem.startDate!);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');

  });

  test('snoozeTask moves target and due dates', () async {
    var taskItem = TaskItemBuilder
        .withDates()
        .create();

    var now = DateTime.now();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalTarget = taskItem.targetDate;
    var originalAnchorDate = taskItem.getAnchorDate();
    expect(originalAnchorDate, taskItem.dueDate, reason: 'SANITY: Expect original anchor date to be due date, because there is no start date.');

    var blueprint = taskItem.createBlueprint();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((_) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, blueprint, 6, 'Days', TaskDateTypes.target, false, (_) => {});

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskId, returnedItem.id);
    expect(snooze.snoozeNumber, 6);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Target');
    expect(snooze.previousAnchor, originalTarget);
    expect(snooze.newAnchor, returnedItem.targetDate);
    expect(returnedItem.getAnchorDate(), returnedItem.dueDate, reason: 'Expect anchor date to be new due date.');

    var newTarget = DateUtil.withoutMillis(returnedItem.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');

    var newDue = DateUtil.withoutMillis(returnedItem.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be 13 days from now.');

  });

  test('snooze task with recur wait false, move remaining', () async {
    fail('To implement.');
  });

  test('snooze task with recur wait false one-off (resume schedule)', () async {
    var taskItem = TaskItemBuilder
        .withDates()
        .withRecur(recurWait: false)
        .create();

    var now = DateTime.now();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalTarget = taskItem.targetDate;
    var originalAnchorDate = taskItem.getAnchorDate();
    expect(originalAnchorDate, taskItem.dueDate, reason: 'SANITY: Expect original anchor date to be due date, because there is no start date.');

    var blueprint = taskItem.createBlueprint();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((_) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, blueprint, 6, 'Days', TaskDateTypes.target, true, (_) => {});

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskId, returnedItem.id);
    expect(snooze.snoozeNumber, 6);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Target');
    expect(snooze.previousAnchor, originalTarget);
    expect(snooze.newAnchor, returnedItem.targetDate);
    expect(returnedItem.getAnchorDate(), returnedItem.dueDate, reason: 'Expect anchor date to be new due date.');

    var newTarget = DateUtil.withoutMillis(returnedItem.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');

    var newDue = DateUtil.withoutMillis(returnedItem.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be 13 days from now.');

  });

  test('snooze task without a start date adds a start date', () async {
    TaskItem taskItem = TaskItemBuilder
        .asDefault()
        .create();

    var now = DateTime.now();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalStart = taskItem.startDate;

    var blueprint = taskItem.createBlueprint();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((_) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    expect(taskItem.startDate, null, reason: 'SANITY: Original task should have no start date.');

    var returnedItem = await taskHelper.snoozeTask(taskItem, blueprint, 4, 'Days', TaskDateTypes.start, false, (_) => {});

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskId, returnedItem.id);
    expect(snooze.snoozeNumber, 4);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Start');
    expect(snooze.previousAnchor, originalStart);
    expect(snooze.newAnchor, returnedItem.startDate);

    expect(returnedItem.startDate, isNot(null), reason: 'Snooze to start date should add start date');

    var newStart = DateUtil.withoutMillis(returnedItem.startDate!);
    var diffDue = newStart.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');

  });
*/

}
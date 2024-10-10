
import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/task_recurrence_blueprint.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/notification_helper.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/routes.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'app_state_test.dart';
import 'matchers/approximate_time_matcher.dart';
import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_flutter_plugin.dart';
import 'mocks/mock_timezone_helper.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';


@GenerateNiceMocks([MockSpec<TaskRepository>(), MockSpec<Store>(), MockSpec<NotificationHelper>(),
  MockSpec<AppState>(), MockSpec<GlobalKey<NavigatorState>>(), MockSpec<NavigatorState>()])
void main() {

  MockTaskRepository taskRepository = new MockTaskRepository();
  MockFlutterLocalNotificationsPlugin plugin = MockFlutterLocalNotificationsPlugin();
  MockTimezoneHelper timezoneHelper = MockTimezoneHelper();
  MockStore<AppState> store = MockStore<AppState>();
  MockAppState appState = new MockAppState();
  MockNotificationHelper mockNotificationHelper = new MockNotificationHelper();
  MockGlobalKey mockGlobalKey = new MockGlobalKey();
  var mockNavigatorState = new MockNavigatorState();

  const String idToken = "token";
  const int personId = 1;
  // MockNotificationScheduler notificationScheduler = new MockNotificationScheduler();
  // StateSetter stateSetter = (callback) => callback();

  TaskItem _mockComplete(TaskItem taskItem, DateTime? completionDate) {
    return taskItem.rebuild((t) => t.completionDate = completionDate);
  }

  void prepareMocks({List<TaskItem>? taskItems, List<Sprint>? sprints, List<TaskRecurrence>? recurrences}) {

    timezoneHelper.configureLocalTimeZone();
    provideDummy<AppState>(appState);

    when(store.state).thenReturn(appState);

    when(appState.personId).thenAnswer((_) => personId);
    when(appState.getIdToken()).thenAnswer((_) => Future.value(idToken));
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
          personId: original.personId,
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

  test('addTask', () async {
    prepareMocks();

    var taskItem = TaskItem.fromJson(birthdayJSON);
    var taskItemBlueprint = taskItem.createBlueprint();
    var action = new AddTaskItemAction(blueprint: taskItemBlueprint);

    when(taskRepository.addTask(taskItemBlueprint, idToken)).thenAnswer((_) => Future.value((taskItem: taskItem, recurrence: null)));

    await createNewTaskItem(taskRepository)(store, action, (_) => {});
    expect(taskItem.personId, 1);
    verify(appState.personId);
    verify(appState.getIdToken());
    verify(taskRepository.addTask(taskItemBlueprint, idToken));
    verify(store.dispatch(argThat(isA<TaskItemAddedAction>())));
    verify(mockNotificationHelper.updateNotificationForTask(taskItem));
  });

  test('addTask with recurrence', () async {
    prepareMocks(taskItems: [birthdayTask]);

    var taskRecurrence = TaskRecurrence.fromJson(catLitterRecurrenceJSON);
    var taskRecurrenceBlueprint = taskRecurrence.createBlueprint();

    var taskItem = TaskItem.fromJson(catLitterJSON);
    var taskItemBlueprint = taskItem.createBlueprint();

    taskItemBlueprint.recurrenceBlueprint = taskRecurrenceBlueprint;

    var action = new AddTaskItemAction(blueprint: taskItemBlueprint);

    when(taskRepository.addTask(taskItemBlueprint, idToken)).thenAnswer((_) => Future.value((taskItem: taskItem, recurrence: taskRecurrence)));

    await createNewTaskItem(taskRepository)(store, action, (_) => {});

    expect(taskItem.personId, 1);
    expect(taskRecurrence.personId, 1);
    verify(appState.personId);
    verify(appState.getIdToken());
    verify(taskRepository.addTask(taskItemBlueprint, idToken));
    verify(store.dispatch(argThat(isA<TaskItemAddedAction>())));
    verify(mockNotificationHelper.updateNotificationForTask(taskItem));
  });

  test('reloadTasks', () async {
    prepareMocks();

    await loadData(taskRepository, mockGlobalKey)(store, LoadDataAction(), (_) => {});;
    verify(mockGlobalKey.currentState);
    verify(mockNavigatorState.pushReplacementNamed(TaskMasterRoutes.loading));
    verify(appState.personId);
    verify(appState.getIdToken());
    verify(taskRepository.loadTasks(personId, idToken));
    verify(store.dispatch(argThat(isA<DataLoadedAction>())));
  });



  test('completeTask no recur', () async {
    prepareMocks(taskItems: [birthdayTask]);

    expect(birthdayTask.recurrence, null);

    TaskItem? resultTask;
    TaskItemBlueprint? blueprint;

    when(taskRepository.updateTask(birthdayTask.id, any, idToken)).thenAnswer((invocation) {
      blueprint = invocation.positionalArguments[1];
      resultTask = TestMockHelper.mockEditTask(birthdayTask, blueprint!);
      return Future.value((taskItem: resultTask!, recurrence: null));
    });

    await completeTaskItem(taskRepository)(store, CompleteTaskItemAction(birthdayTask, true), (_) => {});
    verifyNever(taskRepository.addTask(any, any));

    verify(appState.personId);
    verify(appState.getIdToken());
    verify(taskRepository.updateTask(birthdayTask.id, blueprint, idToken));
    verify(mockNotificationHelper.updateNotificationForTask(resultTask));
    verify(store.dispatch(argThat(isA<TaskItemCompletedAction>())));
  });

/*
  test('completeTask uncomplete no recur', () async {
    var originalTask = burnTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var inboundTask = _mockComplete(originalTask, null);

    when(taskRepository.completeTask(originalTask, null)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(originalTask, false, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(originalTask));
    verify(notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, originalTask);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, null);
    expect(returnedTask.taskRecurrencePreview, null);

  });

  test('completeTask recur schedule (recurWait is false)', () async {
    timezoneHelper.configureLocalTimeZone();

    var taskItem = TaskItemBuilder
        .withDates()
        .withRecur(recurWait: false)
        .create();

    var taskHelper = createTaskHelper(taskItems: [taskItem], sprints: [currentSprint], recurrences: [taskItem.recurrence!]);
    expect(notificationScheduler, isNot(null));

    var taskRecurrence = taskItem.recurrence;
    expect(taskRecurrence, isNot(null));
    expect(taskRecurrence!.recurIteration, 1);
    expect(taskRecurrence.anchorType, 'Due');

    var now = DateTime.now();

    var originalId = taskItem.id;
    var originalDue = DateUtil.withoutMillis(taskItem.dueDate!);
    var originalAnchor = DateUtil.withoutMillis(taskRecurrence.anchorDate);

    var returnedTask = await taskHelper.completeTask(taskItem, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(returnedTask));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.addTaskIteration(any, any));
    expect(returnedTask.id, originalId);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, isApproximately(now));

    var returnedRecurrence = returnedTask.getExistingRecurrence();
    expect(returnedRecurrence, isNot(null));
    expect(returnedRecurrence!.id, taskRecurrence.id);
    expect(returnedRecurrence.taskItems.length, 2);
    expect(returnedRecurrence.recurIteration, 2);

    TaskItem addedTask = returnedRecurrence.getMostRecentIteration();

    verify(notificationScheduler.updateNotificationForTask(addedTask));

    expect(addedTask, isNot(null), reason: 'Expect new task to be created based on recur.');
    expect(addedTask.id, isNot(returnedTask.id));
    expect(addedTask.completionDate, null);
    expect(addedTask.pendingCompletion, false);

    var addedItemRecurrence = addedTask.recurrence;
    expect(addedItemRecurrence, isNot(null));
    expect(addedItemRecurrence, returnedRecurrence);
    expect(addedItemRecurrence!.recurIteration, 2);

    var newDue = DateUtil.withoutMillis(addedTask.dueDate!);
    var diff = newDue.difference(originalDue).inHours;
    var newAnchor = DateUtil.withoutMillis(addedTask.recurrence!.anchorDate);
    var anchorDiff = newAnchor.difference(originalAnchor).inHours;

    var exactly42 = 42 * 24;
    var lowerBound = exactly42 - 1;
    var upperBound = exactly42 + 1;

    expect(diff, inInclusiveRange(lowerBound, upperBound), reason: 'Recurrence of 6 weeks should make new task 42 days after original.');
    expect(anchorDiff, inInclusiveRange(lowerBound, upperBound), reason: 'Recurrence of 6 weeks should increment recurrence anchor date to 42 days after original.');
  });

  test('completeTask recur completed (recurWait is true)', () async {
    timezoneHelper.configureLocalTimeZone();

    var taskItem = TaskItemBuilder
        .withDates()
        .withRecur(recurWait: true)
        .create();

    var taskHelper = createTaskHelper(taskItems: [taskItem], sprints: [currentSprint], recurrences: [taskItem.recurrence!]);
    expect(notificationScheduler, isNot(null));

    var taskRecurrence = taskItem.recurrence;
    expect(taskRecurrence, isNot(null));

    var now = DateTime.now();

    var originalId = taskItem.id;

    var returnedTask = await taskHelper.completeTask(taskItem, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(returnedTask));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.addTaskIteration(any, any));
    expect(returnedTask.id, originalId);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, isApproximately(now));

    var returnedRecurrence = returnedTask.recurrence;
    expect(returnedRecurrence, isNot(null));
    expect(returnedRecurrence!.id, taskRecurrence!.id);

    TaskItem addedTask = returnedRecurrence.getMostRecentIteration();

    verify(notificationScheduler.updateNotificationForTask(addedTask));

    expect(addedTask, isNot(null), reason: 'Expect new task to be created based on recur.');
    expect(addedTask.id, isNot(returnedTask.id));
    expect(addedTask.completionDate, null);
    expect(addedTask.pendingCompletion, false);

    var addedItemRecurrence = addedTask.recurrence;
    expect(addedItemRecurrence, isNot(null));
    expect(addedItemRecurrence!, returnedRecurrence);
    expect(addedItemRecurrence.recurIteration, 2);
    expect(addedItemRecurrence.anchorDate, addedTask.dueDate);

    var newDue = DateUtil.withoutMillis(addedTask.dueDate!);
    var diff = newDue.difference(now).inHours;
    var anchorDiff = addedItemRecurrence.anchorDate.difference(now).inHours;

    var exactly42 = 42 * 24;
    var lowerBound = exactly42 - 3;
    var upperBound = exactly42 + 3;

    expect(diff, inInclusiveRange(lowerBound, upperBound), reason: 'Recurrence of 6 weeks should make new task 42 days after now.');
    expect(anchorDiff, inInclusiveRange(lowerBound, upperBound), reason: 'Recurrence of 6 weeks should increment recurrence to task 42 days after now.');
  });

  test('completeTask uncomplete recur should not recur', () async {
    timezoneHelper.configureLocalTimeZone();

    var taskItem = TaskItemBuilder
        .withDates()
        .withRecur(recurWait: false)
        .create();

    var taskHelper = createTaskHelper(taskItems: [taskItem], sprints: [currentSprint], recurrences: [taskItem.recurrence!]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var completedTask = await taskHelper.completeTask(taskItem, true, stateSetter);
    expect(completedTask.recurrence!.recurIteration, 2);

    var returnedTask = await taskHelper.completeTask(completedTask, false, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(completedTask));
    verify(notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, taskItem);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, null);

    expect(returnedTask.recurrence!.recurIteration, 1);
    expect(returnedTask.recurrence!.anchorDate, completedTask.dueDate);
  });

  test('deleteTask', () async {
    var originalTask = catLitterTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var notificationScheduler = appState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    await taskHelper.deleteTask(originalTask, stateSetter);
    verify(notificationScheduler.cancelNotificationsForTaskId(originalTask.id));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.deleteTask(originalTask));

    expect(appState.taskItems, []);
  });


  test('updateTask', () async {
    var taskItem = birthdayTask.createCopy();
    var blueprint = taskItem.createBlueprint();

    var taskHelper = createTaskHelper(taskItems: [taskItem]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var changedDescription = "Just kidding";
    var changedTarget = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);
    blueprint.description = changedDescription;
    blueprint.targetDate = changedTarget.toLocal();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((realInvocation) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.updateTask(birthdayTask, blueprint, (_) => {});

    verify(taskRepository.updateTask(taskItem, blueprint));
    verify(notificationScheduler.updateNotificationForTask(returnedItem));
    verify(notificationScheduler.updateBadge());

    expect(returnedItem.id, taskItem.id);
    expect(returnedItem.description, changedDescription);
    expect(returnedItem.targetDate, changedTarget.toLocal());
  });

  test('previewSnooze moves target and due dates', () {
    var taskItem = TaskItemBuilder
        .withDates()
        .create().createBlueprint();

    var taskHelper = createTaskHelper();

    taskHelper.previewSnooze(taskItem, 6, 'Days', TaskDateTypes.target);

    var newTarget = DateUtil.withoutMillis(taskItem.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');

    var newDue = DateUtil.withoutMillis(taskItem.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be in 13 days.');

  });


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

  test('addSprintAndTasks', () async {
    List<TaskItem> taskItems = [
      ((TaskItemBuilder.asDefault()..id=1).create()),
      ((TaskItemBuilder.asDefault()..id=2).create()),
      ((TaskItemBuilder.asDefault()..id=3).create()),
    ];
    Sprint sprint = currentSprint;

    TaskHelper taskHelper = createTaskHelper(taskItems: taskItems, sprints: [pastSprint]);
    var notificationScheduler = appState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    // when(taskRepository.addSprint(sprint)).thenAnswer((_) => Future.value(Sprint.fromJson(sprint.toJson())));

    Sprint returnedSprint = await taskHelper.addSprintAndTasks(sprint, taskItems);

    // verify(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));

    expect(appState.sprints, [pastSprint, returnedSprint]);
    expect(returnedSprint.sprintNumber, 6);
  });

  test('addTaskToSprint', () async {
    List<TaskItem> taskItems = [
      ((TaskItemBuilder.asDefault()..id=1).create()),
      ((TaskItemBuilder.asDefault()..id=2).create()),
      ((TaskItemBuilder.asDefault()..id=3).create()),
    ];
    Sprint sprint = currentSprint;

    TaskHelper taskHelper = createTaskHelper(taskItems: taskItems, sprints: [pastSprint]);
    var notificationScheduler = appState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    Sprint returnedSprint = await taskHelper.addTasksToSprint(sprint, taskItems);

    // verifyNever(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));

    expect(appState.sprints, [pastSprint]);
  });
*/

}
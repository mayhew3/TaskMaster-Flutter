
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/snooze.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/models/task_item_preview.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_task_master_auth.dart';
import 'mocks/mock_timezone_helper.dart';
import 'task_helper_test.mocks.dart';
import 'test_mock_helper.dart';

@GenerateNiceMocks([MockSpec<NavHelper>(), MockSpec<AppState>(), MockSpec<TaskRepository>(), MockSpec<NotificationScheduler>()])
void main() {

  MockTaskRepository taskRepository = new MockTaskRepository();
  MockNavHelper navHelper = MockNavHelper();
  MockTimezoneHelper timezoneHelper = MockTimezoneHelper();
  MockAppState appState = MockAppState();
  MockNotificationScheduler notificationScheduler = new MockNotificationScheduler();
  StateSetter stateSetter = (callback) => callback();

  TaskHelper createTaskHelper({List<TaskItem>? taskItems, List<Sprint>? sprints}) {
    when(taskRepository.appState).thenReturn(appState);
    when(appState.notificationScheduler).thenReturn(notificationScheduler);

    var taskHelper = TaskHelper(
        appState: appState,
        repository: taskRepository,
        auth: MockTaskMasterAuth(),
        stateSetter: stateSetter);
    taskHelper.navHelper = navHelper;
    return taskHelper;
  }

  TaskItem _mockComplete(TaskItem taskItem, DateTime? completionDate) {
    var blueprint = taskItem.createEditBlueprint();
    blueprint.completionDate = completionDate;
    return TestMockHelper.mockEditTask(taskItem, blueprint);
  }
  
  test('reloadTasks', () async {
    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    await taskHelper.reloadTasks();
    verify(navHelper.goToLoadingScreen('Reloading tasks...'));

    verify(taskRepository.loadTasks(stateSetter));
    verify(mockAppState.finishedLoading());
    verify(notificationScheduler.updateBadge());
    verify(navHelper.goToHomeScreen());
  });

  test('addTask', () async {
    var taskHelper = createTaskHelper(taskItems: [catLitterTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));
    var taskItem = TaskItem.fromJson(birthdayJSON);
    var taskItemBlueprint = TaskItemBlueprint.fromJson(birthdayJSON);

    when(taskRepository.addTask(taskItemBlueprint)).thenAnswer((_) => Future.value(taskItem));
    when(mockAppState.addNewTaskToList(taskItem)).thenReturn(taskItem);

    await taskHelper.addTask(taskItemBlueprint);
    verify(taskRepository.addTask(taskItemBlueprint));
    verify(mockAppState.addNewTaskToList(taskItem));
    verify(notificationScheduler.updateNotificationForTask(birthdayTask));
    verify(notificationScheduler.updateBadge());
  });

  test('completeTask no recur', () async {
    var taskHelper = createTaskHelper(taskItems: [birthdayTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var now = DateTime.now();
    var inboundTask = _mockComplete(birthdayTask, now);

    when(taskRepository.completeTask(birthdayTask, any)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(birthdayTask, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(returnedTask));
    verify(notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask.id, birthdayTask.id);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, now);
    expect(returnedTask.completionDate, now);

  });

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

  });

  test('completeTask recur', () async {
    timezoneHelper.configureLocalTimeZone();

    var originalTask = pastTask;
    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    expect(notificationScheduler, isNot(null));

    var now = DateTime.now();
    var inboundTask = _mockComplete(originalTask, now);

    TaskItemPreview? addedTask;

    when(taskRepository.completeTask(originalTask, any)).thenAnswer((_) => Future.value(inboundTask));
    when(taskRepository.addTaskIteration(argThat(isA<TaskItemPreview>()))).thenAnswer((invocation) {
      addedTask = invocation.positionalArguments[0];
      return Future.value(TestMockHelper.mockAddTask(addedTask!));
    });
    when(appState.addNewTaskToList(argThat(isA<TaskItem>()))).thenAnswer((invocation) => invocation.positionalArguments[0]);

    var originalId = originalTask.id;
    var originalStart = DateUtil.withoutMillis(originalTask.startDate!);

    var returnedTask = await taskHelper.completeTask(originalTask, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(returnedTask));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.addTaskIteration(any));
    verify(appState.addNewTaskToList(any));
    verify(notificationScheduler.updateNotificationForTask(any));

    expect(returnedTask.id, originalId);
    expect(returnedTask.pendingCompletion, false);
    expect(returnedTask.completionDate, now);

    expect(addedTask, isNot(null), reason: 'Expect new task to be created based on recur.');
    expect(addedTask, isNot(returnedTask));
    expect(addedTask!.pendingCompletion, false);

    var newStart = DateUtil.withoutMillis(addedTask!.startDate!);
    var diff = newStart.difference(originalStart).inHours;

    var exactly42 = 42 * 24;
    var lowerBound = exactly42 - 1;
    var upperBound = exactly42 + 1;

    expect(diff, inInclusiveRange(lowerBound, upperBound), reason: 'Recurrence of 6 weeks should make new task 42 days after original.');
  });

  test('completeTask uncomplete recur should not recur', () async {
    var originalTask = catLitterTask;

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
  });

  test('deleteTask', () async {
    var originalTask = catLitterTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    await taskHelper.deleteTask(originalTask, stateSetter);
    verify(notificationScheduler.cancelNotificationsForTaskId(originalTask.id));
    verify(mockAppState.deleteTaskFromList(originalTask));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.deleteTask(originalTask));

  });


  test('updateTask', () async {
    var taskItem = birthdayTask.createCopy();
    var blueprint = taskItem.createEditBlueprint();

    var taskHelper = createTaskHelper(taskItems: [taskItem]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var changedDescription = "Just kidding";
    var changedTarget = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);
    blueprint.description = changedDescription;
    blueprint.targetDate = changedTarget.toLocal();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((realInvocation) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.updateTask(birthdayTask, blueprint);

    verify(taskRepository.updateTask(taskItem, blueprint));
    verify(notificationScheduler.updateNotificationForTask(returnedItem));
    verify(notificationScheduler.updateBadge());

    expect(returnedItem.id, taskItem.id);
    expect(returnedItem.description, changedDescription);
    expect(returnedItem.targetDate, changedTarget.toLocal());
  });

  test('previewSnooze move multiple', () {
    var taskItem = TaskItemBuilder
        .withDates()
        .create().createEditBlueprint();

    var taskHelper = createTaskHelper();

    taskHelper.previewSnooze(taskItem, 6, 'Days', TaskDateTypes.target);

    var newTarget = DateUtil.withoutMillis(taskItem.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');

    var newDue = DateUtil.withoutMillis(taskItem.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be in 13 days.');

  });


  test('previewSnooze add start', () {
    var taskItem = TaskItemBuilder
        .asDefault()
        .create().createEditBlueprint();

    var taskHelper = createTaskHelper();

    taskHelper.previewSnooze(taskItem, 4, 'Days', TaskDateTypes.start);

    var newStart = DateUtil.withoutMillis(taskItem.startDate!);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');

  });

  test('snoozeTask move multiple', () async {
    var taskItem = TaskItemBuilder
        .withDates()
        .create();

    var now = DateTime.now();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalTarget = taskItem.targetDate;

    var blueprint = taskItem.createEditBlueprint();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((_) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, blueprint, 6, 'Days', TaskDateTypes.target);

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskId, returnedItem.id);
    expect(snooze.snoozeNumber, 6);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Target');
    expect(snooze.previousAnchor, originalTarget);
    expect(snooze.newAnchor, returnedItem.targetDate);

    var newTarget = DateUtil.withoutMillis(returnedItem.targetDate!);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');

    var newDue = DateUtil.withoutMillis(returnedItem.dueDate!);
    var diffDue = newDue.difference(DateUtil.withoutMillis(now)).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be 13 days from now.');

  });


  test('snooze task add start', () async {
    TaskItem taskItem = TaskItemBuilder
        .asDefault()
        .create();

    var now = DateTime.now();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalStart = taskItem.startDate;

    var blueprint = taskItem.createEditBlueprint();

    when(taskRepository.updateTask(taskItem, blueprint)).thenAnswer((_) => Future.value(TestMockHelper.mockEditTask(taskItem, blueprint)));

    var returnedItem = await taskHelper.snoozeTask(taskItem, blueprint, 4, 'Days', TaskDateTypes.start);

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskId, returnedItem.id);
    expect(snooze.snoozeNumber, 4);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Start');
    expect(snooze.previousAnchor, originalStart);
    expect(snooze.newAnchor, returnedItem.startDate);

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
    AppState mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    when(taskRepository.addSprint(sprint)).thenAnswer((_) => Future.value(Sprint.fromJson(sprint.toJson())));

    Sprint returnedSprint = await taskHelper.addSprintAndTasks(sprint, taskItems);

    verify(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));
    verify(mockAppState.sprints.add(sprint));
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
    AppState appState = taskHelper.appState;
    var notificationScheduler = appState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    Sprint returnedSprint = await taskHelper.addTasksToSprint(sprint, taskItems);

    verifyNever(taskRepository.addSprint(sprint));
    verify(taskRepository.addTasksToSprint(taskItems, returnedSprint));
    verifyNever(appState.sprints.add(sprint));

  });

}
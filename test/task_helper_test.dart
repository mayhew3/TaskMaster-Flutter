
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/date_util.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_edit.dart';
import 'package:taskmaster/nav_helper.dart';
import 'package:taskmaster/notification_scheduler.dart';
import 'package:taskmaster/task_helper.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_data.dart';
import 'mocks/mock_data_builder.dart';
import 'mocks/mock_task_master_auth.dart';
import 'task_helper_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NavHelper>(), MockSpec<AppState>(), MockSpec<TaskRepository>(), MockSpec<NotificationScheduler>()])
void main() {

  MockTaskRepository taskRepository = new MockTaskRepository();
  late MockNavHelper navHelper;
  StateSetter stateSetter = (callback) => callback();

  TaskHelper createTaskHelper({List<TaskItemEdit>? taskItems, List<Sprint>? sprints}) {

    MockAppState mockAppState = MockAppState();
    MockNotificationScheduler mockNotificationScheduler = new MockNotificationScheduler();

    when(taskRepository.appState).thenReturn(mockAppState);
    when(mockAppState.notificationScheduler).thenReturn(mockNotificationScheduler);

    navHelper = MockNavHelper();
    var taskHelper = TaskHelper(
        appState: mockAppState,
        repository: taskRepository,
        auth: MockTaskMasterAuth(),
        stateSetter: stateSetter);
    taskHelper.navHelper = navHelper;
    return taskHelper;
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

    when(taskRepository.addTask(taskItem)).thenAnswer((_) => Future.value(taskItem));
    when(mockAppState.addNewTaskToList(taskItem)).thenReturn(taskItem);

    await taskHelper.addTask(taskItem);
    verify(taskRepository.addTask(taskItem));
    verify(mockAppState.addNewTaskToList(taskItem));
    verify(notificationScheduler.updateNotificationForTask(birthdayTask));
    verify(notificationScheduler.updateBadge());
  });

  test('completeTask no recur', () async {
    var taskHelper = createTaskHelper(taskItems: [birthdayTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var inboundTask = TaskItem.fromJson(birthdayJSON);
    var now = DateTime.now();
    inboundTask.completionDate = now;

    when(taskRepository.completeTask(birthdayTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(birthdayTask, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(birthdayTask));
    verify(notificationScheduler.updateBadge());
    verifyNever(taskRepository.addTask(any));

    expect(returnedTask, birthdayTask);
    expect(birthdayTask.pendingCompletion, false);
    expect(birthdayTask.completionDate, now);
    expect(birthdayTask.completionDate, now);

  });

  test('completeTask uncomplete no recur', () async {
    var originalTask = burnTask;
    var originalJSON = burnJSON;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var inboundTask = TaskItem.fromJson(originalJSON);
    inboundTask.completionDate = null;

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(originalTask, false, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(originalTask));
    verify(notificationScheduler.updateBadge());
    // verifyNever(taskRepository.addTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate, null);
    expect(originalTask.completionDate, null);

  });

  test('completeTask recur', () async {
    var originalTask = pastTask;
    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var inboundTask = TaskItem.fromJson(pastJSON);
    var now = DateTime.now();
    inboundTask.completionDate = now;

    TaskItem addedTask;

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));
    /*when(taskRepository.addTask(argThat(isA<TaskItem>()))).thenAnswer((invocation) {
      addedTask = invocation.positionalArguments[0];
      return Future.value(addedTask);
    });
    when(mockAppState.addNewTaskToList(argThat(isA<TaskItem>()))).thenAnswer((invocation) => invocation.positionalArguments[0]);
*/
    var returnedTask = await taskHelper.completeTask(originalTask, true, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(originalTask));
    verify(notificationScheduler.updateBadge());
    // verify(taskRepository.addTask(any));
    // verify(mockAppState.addNewTaskToList(any));
    // verify(mockAppState.notificationScheduler.updateNotificationForTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate, now);
    expect(originalTask.completionDate, now);

    // expect(addedTask, isNot(null), reason: 'Expect new task to be created based on recur.');
    // expect(addedTask, isNot(returnedTask));
    // expect(addedTask.pendingCompletion, false);
    // expect(addedTask.completionDate, null, reason: 'New recurrence should not have completion date.');
    // expect(addedTask.completionDate, null, reason: 'New recurrence should not have completion date.');

    var originalStart = DateUtil.withoutMillis(originalTask.startDate!);
    // var newStart = DateUtil.withoutMillis(addedTask.startDate);
    // var diff = newStart.difference(originalStart).inDays;
    // expect(diff, 42, reason: 'Recurrence of 6 weeks should make new task 42 days after original.');
  });

  test('completeTask uncomplete recur should not recur', () async {
    var originalTask = catLitterTask;
    var originalJSON = catLitterJSON;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var inboundTask = TaskItem.fromJson(originalJSON);
    inboundTask.completionDate = null;

    when(taskRepository.completeTask(originalTask)).thenAnswer((_) => Future.value(inboundTask));

    var returnedTask = await taskHelper.completeTask(originalTask, false, stateSetter);
    verify(notificationScheduler.updateNotificationForTask(originalTask));
    verify(notificationScheduler.updateBadge());
    // verifyNever(taskRepository.addTask(any));

    expect(returnedTask, originalTask);
    expect(originalTask.pendingCompletion, false);
    expect(originalTask.completionDate, null);
    expect(originalTask.completionDate, null);
  });

  test('deleteTask', () async {
    var originalTask = catLitterTask;

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    await taskHelper.deleteTask(originalTask, stateSetter);
    verify(notificationScheduler.cancelNotificationsForTaskId(originalTask.id!));
    verify(mockAppState.deleteTaskFromList(originalTask));
    verify(notificationScheduler.updateBadge());
    verify(taskRepository.deleteTask(originalTask));

  });


  test('updateTask', () async {
    var originalTask = birthdayTask.createEditTemplate();

    var taskHelper = createTaskHelper(taskItems: [originalTask]);
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var changedDescription = "Just kidding";
    var changedTarget = DateTime.utc(2019, 8, 30, 17, 32, 14, 674);
    originalTask.description = changedDescription;

    originalTask.targetDate = changedTarget.toLocal();

    when(taskRepository.updateTask(originalTask)).thenAnswer((realInvocation) => Future.value(TaskItem.fromJson(originalTask.toJson())));

    var returnedItem = await taskHelper.updateTask(birthdayTask, originalTask);

    verify(taskRepository.updateTask(originalTask));
    verify(notificationScheduler.updateNotificationForTask(returnedItem));
    verify(notificationScheduler.updateBadge());

    expect(returnedItem.id, originalTask.id);
    expect(originalTask.description, changedDescription);
    expect(originalTask.targetDate, changedTarget.toLocal());
  });

  test('previewSnooze move multiple', () {
    var taskItem = TaskItemBuilder
        .withDates()
        .create().createEditTemplate();

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
        .create().createEditTemplate();

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

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalTarget = taskItem.targetDate;

    var taskItemEdit = taskItem.createEditTemplate();

    when(taskRepository.updateTask(taskItemEdit)).thenAnswer((_) => Future.value(TaskItem.fromJson(taskItem.toJson())));

    var returnedItem = await taskHelper.snoozeTask(taskItem, taskItemEdit, 6, 'Days', TaskDateTypes.target);
/*

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskID, returnedItem.id);
    expect(snooze.snoozeNumber, 6);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Target');
    expect(snooze.previousAnchor, originalTarget);
    expect(snooze.newAnchor, returnedItem.targetDate);

    var newTarget = DateUtil.withoutMillis(returnedItem.targetDate);
    var diffTarget = newTarget.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffTarget, 6, reason: 'Expect Target date to be in 6 days.');
    expect(returnedItem.targetDate, newTarget);

    var newDue = DateUtil.withoutMillis(returnedItem.dueDate);
    var diffDue = newDue.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 13, reason: 'Expect Due date to be 13 days from now.');
    expect(returnedItem.dueDate, newDue);
*/

  });


  test('snooze task add start', () async {
    TaskItem taskItem = TaskItemBuilder
        .asDefault()
        .create();

    var taskHelper = createTaskHelper();
    var mockAppState = taskHelper.appState;
    var notificationScheduler = mockAppState.notificationScheduler;
    expect(notificationScheduler, isNot(null));

    var originalStart = taskItem.startDate;

    var taskItemEdit = taskItem.createEditTemplate();

    when(taskRepository.updateTask(taskItemEdit)).thenAnswer((_) => Future.value(TaskItem.fromJson(taskItem.toJson())));

    var returnedItem = await taskHelper.snoozeTask(taskItem, taskItemEdit, 4, 'Days', TaskDateTypes.start);
/*

    Snooze snooze = verify(taskRepository.addSnooze(captureThat(isA<Snooze>()))).captured.single;

    expect(snooze.taskID, returnedItem.id);
    expect(snooze.snoozeNumber, 4);
    expect(snooze.snoozeUnits, 'Days');
    expect(snooze.snoozeAnchor, 'Start');
    expect(snooze.previousAnchor, originalStart);
    expect(snooze.newAnchor, returnedItem.startDate);

    var newStart = DateUtil.withoutMillis(returnedItem.startDate);
    var diffDue = newStart.difference(DateUtil.withoutMillis(DateTime.now())).inDays;

    expect(diffDue, 4, reason: 'Expect Start date to be 4 days from now.');
    expect(returnedItem.startDate, newStart);
*/

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
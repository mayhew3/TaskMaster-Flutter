import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

final taskItemsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, TaskItemAddedAction>(_taskItemAdded),
  TypedReducer<AppState, TaskItemDeletedAction>(_onDeleteTaskItem),
  TypedReducer<AppState, TaskItemUpdatedAction>(_taskItemUpdated),
  TypedReducer<AppState, CompleteTaskItemAction>(_completeTaskItem),
  TypedReducer<AppState, RecurringTaskItemCompletedAction>(_onCompleteRecurringTaskItem),
  TypedReducer<AppState, TaskItemCompletedAction>(_onCompleteTaskItem),
  TypedReducer<AppState, DataLoadedAction>(_onDataLoaded),
  TypedReducer<AppState, DataNotLoadedAction>(_onDataNotLoaded),
  TypedReducer<AppState, LogOutAction>(_onDataNotLoaded),
  TypedReducer<AppState, ClearRecentlyCompletedAction>(_clearRecentlyCompleted),
  TypedReducer<AppState, SnoozeExecuted>(_onSnoozeExecuted),
  TypedReducer<AppState, GoOffline>(goOffline),
  TypedReducer<AppState, GoOnline>(goOnline),
  TypedReducer<AppState, TasksAddedAction>(onTaskItemsAdded),
  TypedReducer<AppState, TaskRecurrencesAddedAction>(onTaskRecurrencesAdded),
];

@visibleForTesting
AppState listenersInitialized(AppState state, ListenersInitializedAction action) {
  return state.rebuild((s) => s
    ..taskListener = action.taskListener
    ..sprintListener = action.sprintListener
    ..taskRecurrenceListener = action.taskRecurrenceListener
  );
}

AppState _taskItemAdded(AppState state, TaskItemAddedAction action) {
  var taskRecurrence = action.taskRecurrence;
  return state.rebuild((s) {
    s.taskItems = state.taskItems.toBuilder()..add(action.taskItem);
    if (taskRecurrence != null) {
      s.taskRecurrences = state.taskRecurrences.toBuilder()..add(taskRecurrence);
    }
    return s;
  });
}

AppState _clearRecentlyCompleted(AppState state, ClearRecentlyCompletedAction action) {
  return state.rebuild((s) => s..recentlyCompleted = ListBuilder());
}

AppState _taskItemUpdated(AppState state, TaskItemUpdatedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.docId == action.updatedTaskItem.docId ? action.updatedTaskItem.rebuild((t) {
      return t
        ..pendingCompletion = false
        ..sprintAssignments = taskItem.sprintAssignments.toBuilder();
    }) : taskItem);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
  );
}

AppState _completeTaskItem(AppState state, CompleteTaskItemAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.docId == action.taskItem.docId ? action.taskItem.rebuild((t) => t..pendingCompletion = true) : taskItem);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
  );
}

AppState _onCompleteRecurringTaskItem(AppState state, RecurringTaskItemCompletedAction action) {
  var taskItemListBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.docId == action.completedTaskItem.docId ?
    taskItem.rebuild((t) => t
      ..pendingCompletion = false
      ..completionDate = action.completedTaskItem.completionDate
      ..recurrence = action.recurrence.toBuilder()) :
    taskItem)
    ..add(action.addedTaskItem.rebuild((t) => t.recurrence = action.recurrence.toBuilder()))
  ;
  var recentListBuilder = state.recentlyCompleted.toBuilder()..add(taskItemListBuilder.build().where((t) => t.docId == action.completedTaskItem.docId).first);
  var recurrenceBuilder = state.taskRecurrences.toBuilder()
    ..map((recurrence) => recurrence.docId == action.recurrence.docId ? action.recurrence : recurrence);
  return state.rebuild((s) => s
    ..taskItems = taskItemListBuilder
    ..taskRecurrences = recurrenceBuilder
    ..recentlyCompleted = recentListBuilder
  );
}

AppState _onCompleteTaskItem(AppState state, TaskItemCompletedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) =>
    taskItem.docId == action.taskItem.docId ? taskItem.rebuild((t) =>
    t
      ..pendingCompletion = false
      ..completionDate = action.taskItem.completionDate
    ) : taskItem);
  var recentListBuilder;
  if (action.complete) {
    recentListBuilder = state.recentlyCompleted.toBuilder()
      ..add(listBuilder
          .build()
          .where((t) => t.docId == action.taskItem.docId)
          .first);
  } else {
    recentListBuilder = state.recentlyCompleted.toBuilder()
        ..removeWhere((t) => t.docId == action.taskItem.docId);
  }
  return state.rebuild((s) =>
  s
    ..taskItems = listBuilder
    ..recentlyCompleted = recentListBuilder
  );
}

AppState _onDeleteTaskItem(AppState state, TaskItemDeletedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..removeWhere((t) => t.docId == action.deletedTaskId);
  var recentListBuilder = state.recentlyCompleted.toBuilder()
    ..removeWhere((t) => t.docId == action.deletedTaskId);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
    ..recentlyCompleted = recentListBuilder
  );
}

AppState _onDataLoaded(AppState state, DataLoadedAction action) {
  return state.rebuild((s) {
    // s.taskItems = ListBuilder(action.dataPayload.taskItems.map((taskItem) => taskItem.rebuild((t) => t
    //   ..recurrence = action.dataPayload.taskRecurrences.where((r) => r.id == t.recurrenceId).singleOrNull?.toBuilder())));
    s.sprints = ListBuilder(action.dataPayload.sprints);
    s.taskRecurrences = ListBuilder(action.dataPayload.taskRecurrences);
    return s;
  });
}

@visibleForTesting
AppState onTaskItemsAdded(AppState state, TasksAddedAction action) {
  var recurrences = state.taskRecurrences;

  var nonExistingItems = action.addedItems.where((t) => !state.taskItems.map((ti) => ti.docId).contains(t.docId));

  var withRecurrences = nonExistingItems.map((taskItem) => taskItem.rebuild((t) => t
    ..recurrence = recurrences.where((r) => r.docId == t.recurrenceDocId).singleOrNull?.toBuilder()
  ));

  var rebuiltList = state.taskItems.toBuilder()..addAll(withRecurrences);

  return state.rebuild((s) {
    return s
      ..taskItems = rebuiltList
      ..tasksLoading = false
    ;
  });
}

@visibleForTesting
AppState onTaskRecurrencesAdded(AppState state, TaskRecurrencesAddedAction action) {
  var rebuiltRecurrenceList = state.taskRecurrences.toBuilder()..addAll(action.addedRecurrences);

  var withRecurrences = state.taskItems.map((taskItem) => taskItem.rebuild((t) => t
    ..recurrence = rebuiltRecurrenceList.build().where((r) => r.docId == t.recurrenceDocId).singleOrNull?.toBuilder()
  ));

  return state.rebuild((s) => s
    ..taskRecurrences = rebuiltRecurrenceList
    ..taskItems = ListBuilder(withRecurrences)
    ..taskRecurrencesLoading = false
  );
}

AppState _onDataNotLoaded(AppState state, dynamic action) {
  print("Removing data and listeners.");
  state.taskListener?.cancel();
  state.sprintListener?.cancel();
  state.taskRecurrenceListener?.cancel();
  return state.rebuild((s) => s
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..recentlyCompleted = ListBuilder()
    ..taskListener = null
    ..sprintListener = null
    ..taskRecurrenceListener = null
    ..tasksLoading = true
    ..sprintsLoading = true
    ..taskRecurrencesLoading = true
  );
}

AppState _onSnoozeExecuted(AppState state, SnoozeExecuted action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.docId == action.taskItem.docId ? action.taskItem.rebuild((s) => s..sprintAssignments = taskItem.sprintAssignments.toBuilder()) : taskItem);
  return state.rebuild((s) => s
    ..taskItems = listBuilder
  );
}

AppState goOffline(AppState state, GoOffline action) {
  return state.rebuild((s) => s..offlineMode = true);
}

AppState goOnline(AppState state, GoOnline action) {
  return state.rebuild((s) => s..offlineMode = false);
}
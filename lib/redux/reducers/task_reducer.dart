import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/sprint_assignment.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';

import '../../models/task_item.dart';
import '../actions/task_item_actions.dart';
import '../app_state.dart';

final log = Logger('TaskReducer');

final taskItemsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, TasksDeletedAction>(onDeleteTaskItems).call,
  TypedReducer<AppState, CompleteTaskItemAction>(_completeTaskItem).call,
  TypedReducer<AppState, RecurringTaskItemCompletedAction>(_onCompleteRecurringTaskItem).call,
  TypedReducer<AppState, TaskItemCompletedAction>(_onCompleteTaskItem).call,
  TypedReducer<AppState, DataNotLoadedAction>(_onDataNotLoaded).call,
  TypedReducer<AppState, LogOutAction>(_onDataNotLoaded).call,
  TypedReducer<AppState, ClearRecentlyCompletedAction>(_clearRecentlyCompleted).call,
  TypedReducer<AppState, SnoozeExecuted>(_onSnoozeExecuted).call,
  TypedReducer<AppState, GoOffline>(goOffline).call,
  TypedReducer<AppState, GoOnline>(goOnline).call,
  TypedReducer<AppState, TasksAddedAction>(onTaskItemsAdded).call,
  TypedReducer<AppState, TaskRecurrencesAddedAction>(onTaskRecurrencesAdded).call,
  TypedReducer<AppState, TasksModifiedAction>(onTaskItemsModified).call,
  TypedReducer<AppState, TaskRecurrencesModifiedAction>(onTaskRecurrencesModified).call,
  TypedReducer<AppState, SprintAssignmentsAddedAction>(onSprintAssignmentsAdded).call,
];

@visibleForTesting
AppState listenersInitialized(AppState state, ListenersInitializedAction action) {
  return state.rebuild((s) => s
    ..taskListener = action.taskListener
    ..sprintListener = action.sprintListener
    ..taskRecurrenceListener = action.taskRecurrenceListener
    ..sprintAssignmentListeners = action.sprintAssignmentListeners
  );
}

AppState _clearRecentlyCompleted(AppState state, ClearRecentlyCompletedAction action) {
  return state.rebuild((s) => s..recentlyCompleted = ListBuilder());
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
  ListBuilder<TaskItem> recentListBuilder;
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

@visibleForTesting
AppState onDeleteTaskItems(AppState state, TasksDeletedAction action) {
  var listBuilder = state.taskItems.toBuilder()
    ..removeWhere((t) => action.deletedTaskIds.contains(t.docId));
  var recentListBuilder = state.recentlyCompleted.toBuilder()
    ..removeWhere((t) => action.deletedTaskIds.contains(t.docId));
  return state.rebuild((s) => s
    ..taskItems = listBuilder
    ..recentlyCompleted = recentListBuilder
  );
}

@visibleForTesting
AppState onTaskItemsAdded(AppState state, TasksAddedAction action) {
  var recurrences = state.taskRecurrences;

  var nonExistingItems = action.addedItems.where((t) => !state.taskItems.map((ti) => ti.docId).contains(t.docId));

  for (var t in nonExistingItems) {
    updateNotificationForItem(state, t);
  }

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
AppState onTaskItemsModified(AppState state, TasksModifiedAction action) {
  var recurrences = state.taskRecurrences;
  for (var t in action.modifiedItems) {
    updateNotificationForItem(state, t);
  }

  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) {
      var modifiedMatch = action.modifiedItems.where((t) => t.docId == taskItem.docId).firstOrNull;
      if (modifiedMatch == null) {
        return taskItem;
      } else {
        return modifiedMatch.rebuild((t) {
          var recurrence = modifiedMatch.recurrenceDocId == null ?
            null :
            taskItem.recurrence == null ?
              recurrences.where((r) => r.docId == modifiedMatch.recurrenceDocId).singleOrNull?.toBuilder() :
              taskItem.recurrence?.toBuilder();
          return t
          ..recurrence = recurrence
          ..pendingCompletion = false;
        });
      }
    });

  return state.rebuild((s) => s
    ..taskItems = listBuilder
  );
}

@visibleForTesting
AppState onTaskRecurrencesAdded(AppState state, TaskRecurrencesAddedAction action) {
  var rebuiltRecurrenceList = state.taskRecurrences.toBuilder()..addAll(action.addedRecurrences);

  var withRecurrences = state.taskItems.map((taskItem) => taskItem.rebuild((t) {
    var matchingRecurrences = rebuiltRecurrenceList.build().where((r) => r.docId == t.recurrenceDocId);
    var recurrenceBuilder = matchingRecurrences.singleOrNull?.toBuilder();
    return t
    ..recurrence = recurrenceBuilder;
  }
  ));

  return state.rebuild((s) => s
    ..taskRecurrences = rebuiltRecurrenceList
    ..taskItems = ListBuilder(withRecurrences)
    ..taskRecurrencesLoading = false
  );
}

@visibleForTesting
AppState onTaskRecurrencesModified(AppState state, TaskRecurrencesModifiedAction action) {
  var recurrenceListBuilder = state.taskRecurrences.toBuilder()
    ..map((taskRecurrence) {
      var modifiedMatch = action.modifiedRecurrences.where((r) => r.docId == taskRecurrence.docId).firstOrNull;
      if (modifiedMatch == null) {
        return taskRecurrence;
      } else {
        return modifiedMatch;
      }
    });
  var taskListBuilder = state.taskItems.toBuilder()
    ..map((taskItem) {
      var modifiedMatch = action.modifiedRecurrences.where((r) => r.docId == taskItem.recurrenceDocId).firstOrNull;
      if (modifiedMatch == null) {
        return taskItem;
      } else {
        return taskItem.rebuild((t) => t.recurrence = modifiedMatch.toBuilder());
      }
    });
  return state.rebuild((s) => s
    ..taskRecurrences = recurrenceListBuilder
    ..taskItems = taskListBuilder
  );
}

@visibleForTesting
AppState onSprintAssignmentsAdded(AppState state, SprintAssignmentsAddedAction action) {
  var sprintAssignments = action.addedSprintAssignments;
  var sprintListBuilder = state.sprints.toBuilder()
  ..map((sprint) {
    var sprintAssignmentsForSprint = sprintAssignments.where((sa) => sa.sprintDocId == sprint.docId);
    return sprint.rebuild((s) {
      var existingSprintAssignments = sprint.sprintAssignments;
      var listBuilder = ListBuilder<SprintAssignment>(existingSprintAssignments);
      for (var sa in sprintAssignmentsForSprint) {
        var existing = existingSprintAssignments.where((s) => s.taskDocId == sa.taskDocId).firstOrNull;
        if (existing == null) {
          listBuilder.add(sa);
        }
      }
      s.sprintAssignments = listBuilder;
      return s;
    });
  });
  return state.rebuild((s) => s
    ..sprints = sprintListBuilder
  );
}

AppState _onDataNotLoaded(AppState state, dynamic action) {
  print('Removing data and listeners.');
  state.taskListener?.cancel();
  state.sprintListener?.cancel();
  state.taskRecurrenceListener?.cancel();
  state.sprintAssignmentListeners?.values.forEach((listener) => listener.cancel());
  cancelAllNotifications(state);
  return state.rebuild((s) => s
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..recentlyCompleted = ListBuilder()
    ..taskListener = null
    ..sprintListener = null
    ..taskRecurrenceListener = null
    ..sprintAssignmentListeners = <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{}
    ..tasksLoading = true
    ..sprintsLoading = true
    ..taskRecurrencesLoading = true
  );
}

AppState _onSnoozeExecuted(AppState state, SnoozeExecuted action) {
  var listBuilder = state.taskItems.toBuilder()
    ..map((taskItem) => taskItem.docId == action.taskItem.docId ? action.taskItem : taskItem);
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

void updateNotificationForItem(AppState state, TaskItem taskItem) {
  state.notificationHelper.updateNotificationForTask(taskItem);
}

void cancelAllNotifications(AppState state) {
  state.notificationHelper.cancelAllNotifications();
}
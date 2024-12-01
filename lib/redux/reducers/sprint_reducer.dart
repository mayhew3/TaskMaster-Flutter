import 'package:built_collection/built_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../models/sprint.dart';

final sprintsReducer = <AppState Function(AppState, dynamic)>[
  // TypedReducer<AppState, SprintCreatedAction>(_sprintCreated),
  // TypedReducer<AppState, TaskItemsAddedToExistingSprint>(_taskItemsAddedToExistingSprint),
  TypedReducer<AppState, SprintsAddedAction>(sprintsAdded).call,
];
/*

AppState _sprintCreated(AppState state, SprintCreatedAction action) {
  var sprintBuilder = state.sprints.toBuilder()..add(action.sprint);
  var taskItemBuilder = state.taskItems.toBuilder()
    ..addAll(action.addedTasks.rebuild((list) =>
        list.map((t) => t.rebuild((taskItem) =>
          taskItem..recurrence = state.taskRecurrences.where((r) =>
            r.docId == t.recurrenceDocId).singleOrNull?.toBuilder()))))
    ..map((taskItem) {
      var sprintAssignment = action.sprintAssignments.where((sa) => sa.taskDocId == taskItem.docId).singleOrNull;
      if (sprintAssignment != null) {
        return taskItem.rebuild((t) => t.sprintAssignments.add(sprintAssignment));
      } else {
        return taskItem;
      }
    })
  ;
  return state.rebuild((s) => s
    ..sprints = sprintBuilder
    ..taskItems = taskItemBuilder
  );
}
*/

@visibleForTesting
AppState sprintsAdded(AppState state, SprintsAddedAction action) {
  var sprintBuilder = state.sprints.toBuilder()..addAll(action.addedSprints);

  var addedSprints = ListBuilder<Sprint>(action.addedSprints).build();
  var activeSprint = activeSprintSelector(addedSprints);
  if (activeSprint != null) {
    state.notificationHelper.syncNotificationForSprint(activeSprint);
  }

  return state.rebuild((s) => s
    ..sprints = sprintBuilder
    ..sprintsLoading = false
  );
}

/*
AppState _taskItemsAddedToExistingSprint(AppState state, TaskItemsAddedToExistingSprint action) {
  var taskItemBuilder = state.taskItems.toBuilder()
    ..addAll(action.addedTasks.rebuild((list) =>
        list.map((t) => t.rebuild((taskItem) =>
          taskItem..recurrence = state.taskRecurrences.where((r) =>
            r.docId == t.recurrenceDocId).singleOrNull?.toBuilder()))))
    ..map((taskItem) {
      var sprintAssignment = action.sprintAssignments.where((sa) => sa.taskDocId == taskItem.docId).singleOrNull;
      if (sprintAssignment != null) {
        return taskItem.rebuild((t) => t.sprintAssignments.add(sprintAssignment));
      } else {
        return taskItem;
      }
    })
  ;
  return state.rebuild((s) => s
    ..taskItems = taskItemBuilder
  );
}
*/

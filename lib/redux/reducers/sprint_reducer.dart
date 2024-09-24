import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/redux/app_state.dart';

final sprintsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, SprintCreatedAction>(_sprintCreated),
  TypedReducer<AppState, TaskItemsAddedToExistingSprint>(_taskItemsAddedToExistingSprint),

  TypedReducer<AppState, CreateSprintWithTaskItems>(_setUpdating),
  TypedReducer<AppState, AddTaskItemsToExistingSprint>(_setUpdating),
];

AppState _setUpdating(AppState state, dynamic action) {
  return state.rebuild((s) => s.updating = true);
}

AppState _sprintCreated(AppState state, SprintCreatedAction action) {
  var sprintBuilder = state.sprints.toBuilder()..add(action.sprint);
  var taskItemBuilder = state.taskItems.toBuilder()
    ..addAll(action.addedTasks.rebuild((list) =>
        list.map((t) => t.rebuild((taskItem) =>
          taskItem..recurrence = state.taskRecurrences.where((r) =>
            r.id == t.recurrenceId).singleOrNull?.toBuilder()))))
    ..map((taskItem) {
      var sprintAssignment = action.sprintAssignments.where((sa) => sa.taskId == taskItem.id).singleOrNull;
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
    ..updating = false
  );
}

AppState _taskItemsAddedToExistingSprint(AppState state, TaskItemsAddedToExistingSprint action) {
  var taskItemBuilder = state.taskItems.toBuilder()
    ..addAll(action.addedTasks.rebuild((list) =>
        list.map((t) => t.rebuild((taskItem) =>
          taskItem..recurrence = state.taskRecurrences.where((r) =>
            r.id == t.recurrenceId).singleOrNull?.toBuilder()))))
    ..map((taskItem) {
      var sprintAssignment = action.sprintAssignments.where((sa) => sa.taskId == taskItem.id).singleOrNull;
      if (sprintAssignment != null) {
        return taskItem.rebuild((t) => t.sprintAssignments.add(sprintAssignment));
      } else {
        return taskItem;
      }
    })
  ;
  return state.rebuild((s) => s
    ..taskItems = taskItemBuilder
    ..updating = false
  );
}

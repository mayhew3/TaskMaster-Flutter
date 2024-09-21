import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/sprint_actions.dart';
import 'package:taskmaster/redux/app_state.dart';

final sprintsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, SprintCreatedAction>(_sprintCreated),
];

AppState _sprintCreated(AppState state, SprintCreatedAction action) {
  var sprintBuilder = state.sprints.toBuilder()..add(action.sprint);
  var taskItemBuilder = state.taskItems.toBuilder()..map((taskItem) {
    var sprintAssignment = action.sprintAssignments.where((sa) => sa.taskId == taskItem.id).singleOrNull;
    if (sprintAssignment != null) {
      return taskItem.rebuild((t) => t.sprintAssignments.add(sprintAssignment));
    } else {
      return taskItem;
    }
  })
  ..addAll(action.addedTasks.rebuild((list) =>
      list.map((t) => t.rebuild((taskItem) =>
        taskItem..recurrence = state.taskRecurrences.where((r) =>
          r.id == t.recurrenceId).singleOrNull?.toBuilder()))))
  ;
  return state.rebuild((s) => s
    ..sprints = sprintBuilder
    ..taskItems = taskItemBuilder
  );
}

import 'package:redux/redux.dart';
import '../actions/actions.dart';
import '../../models/models.dart';

final sprintVisibilityReducer = combineReducers<VisibilityFilter>([
  TypedReducer<VisibilityFilter, UpdateSprintFilterAction>(_sprintFilterReducer),
]);

VisibilityFilter _sprintFilterReducer(
    VisibilityFilter activeFilter, UpdateSprintFilterAction action) {
  return action.newFilter;
}

final taskVisibilityReducer = combineReducers<VisibilityFilter>([
  TypedReducer<VisibilityFilter, UpdateTaskFilterAction>(_taskFilterReducer),
]);

VisibilityFilter _taskFilterReducer(
    VisibilityFilter activeFilter, UpdateTaskFilterAction action) {
  return action.newFilter;
}

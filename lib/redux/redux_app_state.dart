import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

import '../models/models.dart';

part 'redux_app_state.g.dart';

abstract class ReduxAppState implements Built<ReduxAppState, ReduxAppStateBuilder> {
  bool get isLoading;
  BuiltList<TaskItem> get taskItems;
  BuiltList<Sprint> get sprints;
  BuiltList<TaskRecurrence> get taskRecurrences;
  AppTab get activeTab;
  VisibilityFilter get sprintListFilter;
  VisibilityFilter get taskListFilter;

/*
  ReduxAppState({
    this.isLoading = false,
    this.taskItems = const [],
    this.sprints = const [],
    this.taskRecurrences = const [],
    this.activeTab = AppTab.plan,
    this.sprintListFilter = const VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true),
    this.taskListFilter = const VisibilityFilter.init(),
  });
*/

  // factory ReduxAppState.loading() => ReduxAppState(isLoading: true);

  ReduxAppState._();
  factory ReduxAppState([Function(ReduxAppStateBuilder) updates]) = _$ReduxAppState;

  factory ReduxAppState.init({bool loading = false}) => ReduxAppState((appState) => appState
    ..isLoading = loading
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..activeTab = AppTab.plan
    ..sprintListFilter = VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true).toBuilder()
    ..taskListFilter = VisibilityFilter.init().toBuilder()
  );
}
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

import '../models/models.dart';

part 'app_state.g.dart';

abstract class AppState implements Built<AppState, AppStateBuilder> {
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

  AppState._();
  factory AppState([Function(AppStateBuilder) updates]) = _$AppState;

  factory AppState.init({bool loading = false}) => AppState((appState) => appState
    ..isLoading = loading
    ..taskItems = ListBuilder()
    ..sprints = ListBuilder()
    ..taskRecurrences = ListBuilder()
    ..activeTab = AppTab.plan
    ..sprintListFilter = VisibilityFilter.init(showScheduled: true, showCompleted: true, showActiveSprint: true).toBuilder()
    ..taskListFilter = VisibilityFilter.init().toBuilder()
  );
}
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../app_state.dart';

part 'plan_task_list_viewmodel.g.dart';

abstract class PlanTaskListViewModel implements Built<PlanTaskListViewModel, PlanTaskListViewModelBuilder> {
  BuiltList<TaskItem> get allTaskItems;
  BuiltList<Sprint> get allSprints;
  BuiltList<TaskItem> get recentlyCompleted;
  Sprint? get lastSprint;
  Sprint? get activeSprint;
  int get personId;

  PlanTaskListViewModel._();

  factory PlanTaskListViewModel([void Function(PlanTaskListViewModelBuilder) updates]) = _$PlanTaskListViewModel;

  static PlanTaskListViewModel fromStore(Store<AppState> store) {
    return PlanTaskListViewModel((c) => c
      ..allTaskItems = store.state.taskItems.toBuilder()
      ..allSprints = store.state.sprints.toBuilder()
      ..recentlyCompleted = store.state.recentlyCompleted.toBuilder()
      ..lastSprint = lastCompletedSprintSelector(store.state.sprints)?.toBuilder()
      ..activeSprint = activeSprintSelector(store.state.sprints)?.toBuilder()
      ..personId = store.state.personId
    );
  }
}
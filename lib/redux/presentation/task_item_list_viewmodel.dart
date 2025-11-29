import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/presentation/delayed_checkbox.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../models/sprint.dart';
import '../../models/task_item.dart';
import '../../models/check_state.dart';
import '../actions/task_item_actions.dart';
import '../app_state.dart';

part 'task_item_list_viewmodel.g.dart';

abstract class TaskItemListViewModel implements Built<TaskItemListViewModel, TaskItemListViewModelBuilder> {
  BuiltList<TaskItem> get taskItems;
  BuiltList<TaskItem> get recentlyCompleted;
  Sprint? get activeSprint;
  bool get isLoading;
  bool get loadFailed;
  CheckState? Function(TaskItem, CheckState) get onCheckboxClicked;

  TaskItemListViewModel._();

  factory TaskItemListViewModel([void Function(TaskItemListViewModelBuilder) updates]) = _$TaskItemListViewModel;

  static TaskItemListViewModel fromStore(Store<AppState> store) {
    return TaskItemListViewModel((c) => c
      ..taskItems = ListBuilder(store.state.taskItems)
      ..recentlyCompleted = ListBuilder(store.state.recentlyCompleted)
      ..isLoading = store.state.isLoading
      ..loadFailed = store.state.loadFailed
      ..onCheckboxClicked = (taskItem, checkState) {
        if (checkState != CheckState.pending) {
          store.dispatch(CompleteTaskItemAction(
              taskItem, CheckState.inactive == checkState));
        }
        return null;
      }
      ..activeSprint = activeSprintSelector(store.state.sprints)?.toBuilder()
    );
  }
}
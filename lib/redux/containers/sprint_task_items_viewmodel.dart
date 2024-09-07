
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../models/task_item.dart';
import '../../models/visibility_filter.dart';
import '../app_state.dart';

// ignore: prefer_double_quotes
part 'sprint_task_items_viewmodel.g.dart';

abstract class SprintTaskItemsViewModel implements Built<SprintTaskItemsViewModel, SprintTaskItemsViewModelBuilder> {
  Sprint? get activeSprint;
  BuiltList<TaskItem> get taskItems;
  bool get loading;
  // Function(TaskItem) onRemove;
  // Function(TaskItem) onUndoRemove;

  SprintTaskItemsViewModel._();

  factory SprintTaskItemsViewModel([void Function(SprintTaskItemsViewModelBuilder) updates]) = _$SprintTaskItemsViewModel;

  static SprintTaskItemsViewModel fromStore(Store<AppState> store) {
    return SprintTaskItemsViewModel((c) => c
      ..taskItems = filteredTaskItemsSelector(store.state.taskItems, store.state.recentlyCompleted, activeSprintSelector(store.state.sprints), store.state.sprintListFilter)
      ..loading = store.state.isLoading
      ..activeSprint = activeSprintSelector(store.state.sprints)?.toBuilder()
    );
  }

}


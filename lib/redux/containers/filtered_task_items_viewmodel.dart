
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../models/task_item.dart';
import '../app_state.dart';

// ignore: prefer_double_quotes
part 'filtered_task_items_viewmodel.g.dart';

abstract class FilteredTaskItemsViewModel implements Built<FilteredTaskItemsViewModel, FilteredTaskItemsViewModelBuilder> {
  BuiltList<TaskItem> get taskItems;
  bool get loading;
  // Function(TaskItem) onRemove;
  // Function(TaskItem) onUndoRemove;

  FilteredTaskItemsViewModel._();

  factory FilteredTaskItemsViewModel([void Function(FilteredTaskItemsViewModelBuilder) updates]) = _$FilteredTaskItemsViewModel;

  static FilteredTaskItemsViewModel fromStore(Store<AppState> store) {
    return FilteredTaskItemsViewModel((c) => c
      ..taskItems = filteredTaskItemsSelector(store.state.taskItems, store.state.recentlyCompleted, null, store.state.taskListFilter)
      ..loading = store.state.isLoading
    );
  }

}


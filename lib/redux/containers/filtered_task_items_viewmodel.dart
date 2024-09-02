
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../../models/task_item.dart';
import '../../models/visibility_filter.dart';
import '../app_state.dart';

// ignore: prefer_double_quotes
part 'filtered_task_items_viewmodel.g.dart';

abstract class FilteredTaskItemsViewModel implements Built<FilteredTaskItemsViewModel, FilteredTaskItemsViewModelBuilder> {
  BuiltList<TaskItem> get taskItems;
  bool get loading;
  // Function(TaskItem, bool) onCheckboxChanged;
  // Function(TaskItem) onRemove;
  // Function(TaskItem) onUndoRemove;

  FilteredTaskItemsViewModel._();

  factory FilteredTaskItemsViewModel([void Function(FilteredTaskItemsViewModelBuilder) updates]) = _$FilteredTaskItemsViewModel;

  static FilteredTaskItemsViewModel fromStore(Store<AppState> store) {
    return FilteredTaskItemsViewModel((c) => c
      ..taskItems = filterTaskItems(store.state.taskItems, store.state.recentlyCompleted, store.state.taskListFilter)
      ..loading = store.state.isLoading
    );
  }

  static ListBuilder<TaskItem> filterTaskItems(BuiltList<TaskItem> taskItems, BuiltList<TaskItem> recentlyCompleted, VisibilityFilter visibilityFilter) {
    var filteredTasks = taskItems.where((taskItem) {
      var startDate = taskItem.startDate;

      var completedPredicate = taskItem.completionDate == null || visibilityFilter.showCompleted;
      var scheduledPredicate = startDate == null || startDate.isBefore(DateTime.now()) || visibilityFilter.showScheduled;
      var isRecentlyCompleted = recentlyCompleted.map((t) => t.id).contains(taskItem.id);
      // todo: active predicate, when sprint getter is complete

      return (completedPredicate && scheduledPredicate) || isRecentlyCompleted;
    });
    return ListBuilder<TaskItem>(filteredTasks);
  }

}


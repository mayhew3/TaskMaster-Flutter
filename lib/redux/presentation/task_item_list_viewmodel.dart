import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../../models/task_item.dart';
import '../app_state.dart';

// ignore: prefer_double_quotes
part 'task_item_list_viewmodel.g.dart';

abstract class TaskItemListViewModel implements Built<TaskItemListViewModel, TaskItemListViewModelBuilder> {
  BuiltList<TaskItem> get taskItems;
  bool get isLoading;
  bool get loadFailed;
  // Function(TaskItem, bool) onCheckboxChanged;
  // Function(TaskItem) onRemove;
  // Function(TaskItem) onUndoRemove;

  TaskItemListViewModel._();

  factory TaskItemListViewModel([void Function(TaskItemListViewModelBuilder) updates]) = _$TaskItemListViewModel;

  static TaskItemListViewModel fromStore(Store<AppState> store) {
    return TaskItemListViewModel((c) => c
      ..taskItems = ListBuilder(store.state.taskItems)
      ..isLoading = store.state.isLoading
      ..loadFailed = store.state.loadFailed
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../models/models.dart';

import '../actions/actions.dart';
import '../redux_app_state.dart';

class FilteredTaskItems extends StatelessWidget {
  FilteredTaskItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ReduxAppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return TaskItemList(
          taskItems: vm.taskItems,
          onCheckboxChanged: vm.onCheckboxChanged,
          onRemove: vm.onRemove,
          onUndoRemove: vm.onUndoRemove,
        );
      },
    );
  }
}

class _ViewModel {
  final List<TaskItem> taskItems;
  final bool loading;
  final Function(TaskItem, bool) onCheckboxChanged;
  final Function(TaskItem) onRemove;
  final Function(TaskItem) onUndoRemove;

  _ViewModel({
    required this.taskItems,
    required this.loading,
    required this.onCheckboxChanged,
    required this.onRemove,
    required this.onUndoRemove,
  });

  static _ViewModel fromStore(Store<ReduxAppState> store) {
    return _ViewModel(
      taskItems: filteredTaskItemsSelector(
        taskItemsSelector(store.state),
        activeFilterSelector(store.state),
      ),
      loading: store.state.isLoading,
      onCheckboxChanged: (taskItem, complete) {
        store.dispatch(UpdateTaskItemAction(
          taskItem.id,
          taskItem.copyWith(completionDate: taskItem.completionDate == null ? DateTime.now() : null),
        ));
      },
      onRemove: (taskItem) {
        store.dispatch(DeleteTaskItemAction(taskItem.id));
      },
      onUndoRemove: (taskItem) {
        store.dispatch(AddTaskItemAction(taskItem));
      },
    );
  }
}

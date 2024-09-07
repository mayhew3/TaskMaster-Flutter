
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/sprint_task_items_viewmodel.dart';

import '../app_state.dart';
import '../presentation/task_item_list.dart';
import 'filtered_task_items_viewmodel.dart';


class SprintTaskItems extends StatelessWidget {
  SprintTaskItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SprintTaskItemsViewModel>(
      converter: SprintTaskItemsViewModel.fromStore,
      builder: (context, vm) {
        return TaskItemList(
          taskItems: vm.taskItems,
          // onRemove: vm.onRemove,
          // onUndoRemove: vm.onUndoRemove,
        );
      },
    );
  }
}

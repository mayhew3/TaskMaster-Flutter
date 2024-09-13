
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/sprint_task_items_viewmodel.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';
import '../presentation/filter_button.dart';
import '../presentation/task_item_list.dart';
import '../presentation/task_main_menu.dart';


class SprintTaskItems extends StatelessWidget {

  SprintTaskItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SprintTaskItemsViewModel>(
      converter: SprintTaskItemsViewModel.fromStore,
      builder: (context, viewModel) {
        return Scaffold(
          appBar: AppBar(
            title: Text('All Tasks'),
            actions: <Widget>[
              FilterButton(
                scheduledGetter: () => viewModel.showScheduled,
                completedGetter: () => viewModel.showCompleted,
                toggleScheduled: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowScheduledAction()),
                toggleCompleted: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowCompletedAction()),
              ),
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => StoreProvider.of<AppState>(context).dispatch(LoadDataAction())
              ),
            ],
          ),
          body: TaskItemList(
            taskItems: viewModel.taskItems,
            // onRemove: vm.onRemove,
            // onUndoRemove: vm.onUndoRemove,
          ),
          drawer: TaskMainMenu(),
          bottomNavigationBar: TabSelector(),
        );
      },
    );
  }
}

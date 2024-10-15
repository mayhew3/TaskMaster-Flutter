
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';
import '../presentation/add_edit_screen.dart';
import '../presentation/filter_button.dart';
import '../presentation/task_item_list.dart';
import '../presentation/task_main_menu.dart';
import 'filtered_task_items_viewmodel.dart';


class FilteredTaskItems extends StatelessWidget {

  FilteredTaskItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FilteredTaskItemsViewModel>(
      converter: FilteredTaskItemsViewModel.fromStore,
      builder: (context, viewModel) {
        return Scaffold(
          appBar: AppBar(
            title: Text('All Tasks'),
            actions: <Widget>[
              IconButton(
                  onPressed: () => viewModel.offlineMode ?
                    StoreProvider.of<AppState>(context).dispatch(GoOnline()) :
                    StoreProvider.of<AppState>(context).dispatch(GoOffline()),
                  icon: Icon(viewModel.offlineMode ? Icons.account_circle_outlined : Icons.account_circle)),
              FilterButton(
                scheduledGetter: () => viewModel.showScheduled,
                completedGetter: () => viewModel.showCompleted,
                toggleScheduled: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowScheduledAction()),
                toggleCompleted: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowCompletedAction()),
              ),
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => StoreProvider.of<AppState>(context).dispatch(DataNotLoadedAction())
              ),
            ],
          ),
          body: TaskItemList(
            taskItems: viewModel.taskItems,
            sprintMode: false,
            // onRemove: vm.onRemove,
            // onUndoRemove: vm.onUndoRemove,
          ),
          drawer: TaskMainMenu(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddEditScreen(timezoneHelper: viewModel.timezoneHelper))
              );
            },
            child: Icon(Icons.add),
          ),
          bottomNavigationBar: TabSelector(),
        );
      },
    );
  }
}

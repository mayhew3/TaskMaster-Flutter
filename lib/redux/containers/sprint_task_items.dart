
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/sprint_task_items_viewmodel.dart';
import 'package:taskmaster/typedefs.dart';

import '../actions/actions.dart';
import '../app_state.dart';
import '../presentation/add_edit_screen.dart';
import '../presentation/filter_button.dart';
import '../presentation/task_item_list.dart';
import '../presentation/task_main_menu.dart';


class SprintTaskItems extends StatelessWidget {
  final BottomNavigationBarGetter bottomNavigationBarGetter;

  SprintTaskItems({
    Key? key,
    required this.bottomNavigationBarGetter,
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
                toggleScheduled: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowScheduled()),
                toggleCompleted: () => StoreProvider.of<AppState>(context).dispatch(ToggleTaskListShowCompleted()),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddEditScreen(timezoneHelper: viewModel.timezoneHelper))
              );
            },
            child: Icon(Icons.add),
          ),
          bottomNavigationBar: this.bottomNavigationBarGetter(),
        );
      },
    );
  }
}

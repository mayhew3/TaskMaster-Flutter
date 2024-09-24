import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/planning_home_viewmodel.dart';
import 'package:taskmaster/redux/containers/sprint_task_items.dart';
import 'package:taskmaster/redux/presentation/new_sprint.dart';

import '../../keys.dart';
import '../actions/task_item_actions.dart';
import '../app_state.dart';
import '../presentation/loading_indicator.dart';

class PlanningHome extends StatelessWidget {
  PlanningHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlanningHomeViewModel>(
        builder: (context, PlanningHomeViewModel viewModel) {
          if (viewModel.isLoading) {
            return LoadingIndicator(key: TaskMasterKeys.tasksLoading);
          } else if (viewModel.loadFailed) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    const Text(
                        "Could not load tasks from server. Please try again."),
                    ElevatedButton(
                      child: const Text('RETRY'),
                      onPressed: () {
                        StoreProvider.of<AppState>(context).dispatch(LoadDataAction());
                      },
                    ),
                  ],
                )
            );
          } else if (viewModel.activeSprint == null) {
            print('Planning loaded, no sprint. (DEBUG)');
            return NewSprint();
          } else {
            print('Planning loaded, active sprint: ${viewModel.activeSprint!.id}. (DEBUG)');
            return SprintTaskItems();
          }
        },
        converter: PlanningHomeViewModel.fromStore
    );
  }
}

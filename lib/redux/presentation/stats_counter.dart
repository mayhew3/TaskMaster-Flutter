
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';
import 'package:taskmaster/redux/presentation/stats_counter_viewmodel.dart';
import 'package:taskmaster/redux/presentation/task_main_menu.dart';

class StatsCounter extends StatelessWidget {

  StatsCounter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, StatsCounterViewModel>(
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Stats'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Completed Tasks',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      '${viewModel.numCompleted}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Active Tasks',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      "${viewModel.numActive}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  )
                ],
              ),
            ),
            drawer: TaskMainMenu(),
            bottomNavigationBar: TabSelector(),
          );
        },
        converter: StatsCounterViewModel.fromStore);
  }
}

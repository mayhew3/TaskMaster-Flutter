import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/planning_home_viewmodel.dart';
import 'package:taskmaster/redux/containers/sprint_task_items.dart';
import 'package:taskmaster/redux/presentation/new_sprint.dart';

import '../app_state.dart';

class PlanningHome extends StatelessWidget {
  PlanningHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlanningHomeViewModel>(
        builder: (context, PlanningHomeViewModel viewModel) {
          if (viewModel.activeSprint == null) {
            return NewSprint();
          } else {
            return SprintTaskItems();
          }
        },
        converter: PlanningHomeViewModel.fromStore
    );
  }
}
// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/timezone_helper.dart';
import 'package:taskmaster/typedefs.dart';

import '../presentation/delayed_checkbox.dart';
import '../presentation/details_screen.dart';
import '../app_state.dart';
import '../actions/actions.dart';
import '../../models/models.dart';

class TaskItemDetailScreen extends StatelessWidget {
  final int id;

  TaskItemDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<TimezoneHelper> createLocal = TimezoneHelper.createLocal();
    return StoreConnector<AppState, _ViewModel>(
      ignoreChange: (state) => taskItemSelector(state.taskItems, id) != null,
      converter: (Store<AppState> store) {
        return _ViewModel.from(store, id);
      },
      builder: (context, vm) {
        return FutureBuilder(future: createLocal,
            builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DetailsScreen(
              taskItem: vm.taskItem,
              onDelete: vm.onDelete,
              toggleCompleted: vm.toggleCompleted,
              timezoneHelper: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: const Text("Error setting time zone"),
            );
          } else {
            return Center(
              child: const Text("Loading timezone..."),
            );
          }
        });
      },
    );
  }
}

class _ViewModel {
  final TaskItem taskItem;
  final Function onDelete;
  final CheckCycleWaiter toggleCompleted;

  _ViewModel({
    required this.taskItem,
    required this.onDelete,
    required this.toggleCompleted,
  });

  factory _ViewModel.from(Store<AppState> store, int id) {
    final taskItem = taskItemSelector(taskItemsSelector(store.state), id)!;

    return _ViewModel(
      taskItem: taskItem,
      onDelete: () => store.dispatch(DeleteTaskItemAction(taskItem.id)),
      toggleCompleted: (checkState) => store.dispatch(CompleteTaskItemAction(taskItem, CheckState.inactive == checkState)),
    );
  }
}

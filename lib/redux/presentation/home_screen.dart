// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/filtered_task_items.dart';
import 'package:taskmaster/redux/containers/sprint_task_items.dart';
import 'package:taskmaster/redux/presentation/add_edit_screen.dart';
import 'package:taskmaster/redux/presentation/home_screen_viewmodel.dart';
import 'package:taskmaster/redux/presentation/stats_counter.dart';
import 'package:taskmaster/redux/presentation/task_main_menu.dart';

import '../../keys.dart';
import '../../models/models.dart';
import '../actions/actions.dart';
import '../app_state.dart';
import '../containers/tab_selector.dart';
import 'filter_button.dart';

class HomeScreen extends StatefulWidget {
  final void Function() onInit;

  HomeScreen({required this.onInit}) : super(key: TaskMasterKeys.homeScreen);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeScreenViewModel>(
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text("TaskMaster 3000"),
              actions: [
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
            body:
              (viewModel.activeTab == AppTab.tasks) ? FilteredTaskItems() :
              (viewModel.activeTab == AppTab.stats) ? StatsCounter() :
                SprintTaskItems(),
            bottomNavigationBar: TabSelector(),
            drawer: TaskMainMenu(),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddEditScreen(timezoneHelper: viewModel.timezoneHelper))
                );
              },
              child: Icon(Icons.add),
            ),
          );
        },
        converter: HomeScreenViewModel.fromStore
    );

  }
}

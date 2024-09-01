// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/filtered_task_items.dart';
import 'package:taskmaster/redux/presentation/task_main_menu.dart';
import '../../models/models.dart';

import '../../keys.dart';
import '../actions/actions.dart';
import '../app_state.dart';
import '../containers/active_tab.dart';
import '../containers/tab_selector.dart';

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
    return ActiveTab(
      builder: (BuildContext context, AppTab activeTab) {
        return Scaffold(
          appBar: AppBar(
            title: Text("TaskMaster 3000"),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  StoreProvider.of<AppState>(context).dispatch(LoadTaskItemsAction());;
                },
              ),
            ],
          ),
          body: activeTab == AppTab.tasks ? FilteredTaskItems() : FilteredTaskItems(),
          bottomNavigationBar: TabSelector(),
          drawer: TaskMainMenu(),
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/task_main_menu_viewmodel.dart';

class TaskMainMenu extends Drawer {

  TaskMainMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TaskMainMenuViewModel>(
        builder: (BuildContext context, TaskMainMenuViewModel viewModel) {
          return Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Actions'),
                    decoration: BoxDecoration(
                        color: TaskColors.pendingBackground
                    ),
                  ),
                  ListTile(
                    title: Text('Sign Out'),
                    onTap: () {
                      viewModel.onPressedCallback();
                    },
                  )
                ],
              )
          );
        },
        converter: TaskMainMenuViewModel.fromStore
    );
  }

}
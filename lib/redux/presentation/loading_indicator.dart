// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/models/task_colors.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/presentation/loading_screen_viewmodel.dart';

import '../../keys.dart';
import '../app_state.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        onInitialBuild: (viewModel) => StoreProvider.of<AppState>(context).dispatch(LoadDataAction()),
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('TaskMaster 3000'),
            ),
            body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircularProgressIndicator(
                      key: TaskMasterKeys.tasksLoading,
                      color: TaskColors.highlight,
                    ),
                    const Text('Loading tasks...'),
                  ],
                )
            ),
          );
        },
        converter: LoadingScreenViewModel.fromStore
    );
  }
}

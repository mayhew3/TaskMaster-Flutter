// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/routes.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

class LoadFailedScreen extends StatelessWidget {
  LoadFailedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TaskMaster 3000'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text(
                  "Could not load tasks from server. Please try again."),
              ElevatedButton(
                child: const Text('RETRY'),
                onPressed: () {
                  StoreProvider.of<AppState>(context).dispatch(LoadDataAction());
                  Navigator.of(context).pushReplacementNamed(TaskMasterRoutes.home);
                },
              ),
            ],
          )
      ),
    );
  }
}

// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:taskmaster/models/task_colors.dart';

import '../../keys.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({Key? key}) : super(key: key);

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
              CircularProgressIndicator(
                key: TaskMasterKeys.tasksLoading,
                color: TaskColors.highlight,
              ),
              const Text("Loading tasks..."),
            ],
          )
      ),
    );
  }
}

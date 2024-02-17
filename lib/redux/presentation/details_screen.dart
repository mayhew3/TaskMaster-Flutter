// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

import '../../keys.dart';
import '../../models/models.dart';

class DetailsScreen extends StatelessWidget {
  final TaskItem taskItem;
  final Function onDelete;
  final Function(bool?) toggleCompleted;

  DetailsScreen({
    Key? key,
    required this.taskItem,
    required this.onDelete,
    required this.toggleCompleted,
  }) : super(key: key ?? TaskMasterKeys.taskItemDetailsScreen);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Task Item Details"),
        actions: [
          IconButton(
            tooltip: "Delete Task Item",
            key: TaskMasterKeys.deleteTaskItemButton,
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context, taskItem);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Checkbox(
                    value: taskItem.completionDate != null,
                    onChanged: toggleCompleted,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: '${taskItem.id}__heroTag',
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                            top: 8.0,
                            bottom: 16.0,
                          ),
                          child: Text(
                            taskItem.name,
                            key: TaskMasterKeys.detailsTaskItemItemTask,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      Text(
                        taskItem.description ?? '',
                        key: TaskMasterKeys.detailsTaskItemItemNote,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: TaskMasterKeys.editTaskItemFab,
        tooltip: "Edit Task Item",
        child: Icon(Icons.edit),
        onPressed: () {},
      ),
    );
  }
}

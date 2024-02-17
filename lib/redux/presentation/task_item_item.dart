// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import '../../keys.dart';
import '../../models/models.dart';

class TaskItemItem extends StatelessWidget {
  final DismissDirectionCallback onDismissed;
  final GestureTapCallback onTap;
  final ValueChanged<bool?> onCheckboxChanged;
  final TaskItem taskItem;

  TaskItemItem({
    required this.onDismissed,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.taskItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.id),
      onDismissed: onDismissed,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          key: TaskMasterKeys.taskItemCheckbox(taskItem.id),
          value: taskItem.completionDate != null,
          onChanged: onCheckboxChanged,
        ),
        title: Hero(
          tag: '${taskItem.id}__heroTag',
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              taskItem.name,
              key: TaskMasterKeys.taskItemTask(taskItem.id),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        subtitle: Text(
          taskItem.context ?? '',
          key: TaskMasterKeys.taskItemNote(taskItem.id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

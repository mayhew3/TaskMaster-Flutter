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

  const TaskItemItem({super.key, 
    required this.onDismissed,
    required this.onTap,
    required this.onCheckboxChanged,
    required this.taskItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: TaskMasterKeys.taskItem(taskItem.docId),
      onDismissed: onDismissed,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          key: TaskMasterKeys.taskItemCheckbox(taskItem.docId),
          value: taskItem.completionDate != null,
          onChanged: onCheckboxChanged,
        ),
        title: Hero(
          tag: '${taskItem.docId}__heroTag',
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              taskItem.name,
              key: TaskMasterKeys.taskItemTask(taskItem.docId),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        subtitle: Text(
          taskItem.context ?? '',
          key: TaskMasterKeys.taskItemNote(taskItem.docId),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

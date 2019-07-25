import 'package:flutter/material.dart';
import 'package:taskmaster/app.dart';
import 'package:taskmaster/task_repository.dart';

void main() => runApp(
  TaskMasterApp(repository: TaskRepository())
);

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/task_item.dart';

typedef UserUpdater(GoogleSignInAccount account);
typedef IdTokenUpdater(IdTokenResult idToken);

typedef TaskAdder(TaskItem taskItem);

typedef Future<TaskItem> TaskCompleter(TaskItem taskItem, bool completed);

typedef TaskDeleter(TaskItem taskItem);

typedef Future<TaskItem> TaskUpdater(TaskItem taskItem);

typedef EndLoadingCallback(BuildContext context);

typedef TaskListReloader();
typedef TaskItemRefresher(TaskItem taskItem);
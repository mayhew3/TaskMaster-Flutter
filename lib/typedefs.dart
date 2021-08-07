import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/task_field.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';

typedef UserUpdater(GoogleSignInAccount account);
typedef IdTokenUpdater(String idToken);

typedef EndLoadingCallback(BuildContext context);

typedef TaskItemRefresher(TaskItem taskItem);

typedef void StateCallback();
typedef void MyStateSetter(StateCallback stateCallback);

typedef BottomNavigationBar BottomNavigationBarGetter();

typedef List<TaskItem> TaskListGetter();

typedef Future<CheckState> CheckCycleWaiter(CheckState startingState);

typedef TaskFieldDate DateFieldGetter(TaskItem taskItem);

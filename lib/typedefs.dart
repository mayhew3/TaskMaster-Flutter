import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/widgets/delayed_checkbox.dart';

import 'models/task_item_blueprint.dart';

typedef UserUpdater(GoogleSignInAccount? account);
typedef IdTokenUpdater(String? idToken);

typedef EndLoadingCallback(BuildContext context);

typedef TaskItemRefresher(TaskItem taskItem);

typedef void StateCallback();
typedef void MyStateSetter(StateCallback stateCallback);

typedef BottomNavigationBar BottomNavigationBarGetter();

typedef List<TaskItem> TaskListGetter();

typedef Future<CheckState> CheckCycleWaiter(CheckState startingState);

typedef DateTime? DateFieldGetter(TaskItemBlueprint taskItem);
typedef void DateFieldSetter(TaskItemBlueprint taskItem, DateTime? newDate);

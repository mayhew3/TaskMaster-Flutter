import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_date_holder.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/containers/tab_selector.dart';
import 'package:taskmaster/redux/presentation/delayed_checkbox.dart';

import 'models/task_item_blueprint.dart';


typedef UserUpdater(GoogleSignInAccount? account);

typedef EndLoadingCallback(BuildContext context);

typedef TaskItemRefresher(TaskItem taskItem);

typedef void StateCallback();
typedef void MyStateSetter(StateCallback stateCallback);

typedef TabSelector BottomNavigationBarGetter();

typedef List<TaskItem> TaskListGetter();

typedef CheckState? CheckCycleWaiter(CheckState startingState);

typedef DateTime? DateFieldGetter(DateHolder dateHolder);
typedef void DateFieldSetter(TaskItemBlueprint blueprint, DateTime? newDate);

typedef Widget WidgetGetter();
typedef bool TaskItemFilter(SprintDisplayTask sprintDisplayTask);
typedef int TaskItemOrdering(SprintDisplayTask a, SprintDisplayTask b);

typedef Future<Response> GetApiOperation(Uri uri, {Map<String, String>? headers});
typedef Future<Response> BodyApiOperation(Uri uri, {Map<String, String>? headers, Object? body, Encoding? encoding});